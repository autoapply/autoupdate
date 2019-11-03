# autoupdate

[![Docker build status](https://img.shields.io/docker/build/autoapply/autoupdate.svg?style=flat-square)](https://hub.docker.com/r/autoapply/autoupdate/) [![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://github.com/autoapply/autoupdate/blob/master/LICENSE)

Automatically update Git repositories.

## Usage

The common use case for autoupdate is to update Git repositories which contain Kubernetes resource files.
The resources are then deployed automatically via [autoapply](https://github.com/autoapply/autoapply) (or [similar projects](https://github.com/autoapply/autoapply#related-projects)).

### Example 1: Trigger repository updates from a CircleCI build

In this first example, we will setup autoupdate in our Kubernetes cluster and configure CirlceCI to trigger the action during each build.

You can use [minikube](https://github.com/kubernetes/minikube) or [kind](https://github.com/kubernetes-sigs/kind) to quickly setup a test cluster.

First, create a _ConfigMap_ in the cluster. If you save the file as `config.yaml`, you can create the object via `kubectl apply -f ./config.yaml`.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: autoupdate-config
data:
  REPOSITORY_URL: https://git.example.com/repository
  DEPLOYMENT_FILE: app.yaml
```

Then create a _Secret_ with the credentials for authenticating autoupdate users.
Make sure to use a custom password (you can use `pwgen 30 1` or `openssl rand -hex 20` to generate a random string).

```sh
kubectl create secret generic autoupdate-secret \
  --from-literal=USERS="username:password123"
```

Next, create the autoupdate deployment:

```sh
kubectl apply -f https://raw.githubusercontent.com/autoapply/autoupdate/master/docs/example-1/autoupdate-1.yaml
```

When the deployment is running, [find the external IP address](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#finding-your-ip-address) of the autoupdate service. We will need this for the last step.

After autoupdate has been setup, we need to adapt the CircleCI configuration.
For this example, we assume that the CircleCI setup is similar to the one described in [building-docker-images](https://circleci.com/docs/2.0/building-docker-images/).

Add the following step to your configuration (`.circleci/config.yml`).
Make sure to use the credentials from the earlier step and replace `IP` with the external IP address of the autoupdate service.
Also, be careful to add this step _after_ the step where the Docker image is pushed!

```yaml
    steps:
      - run: curl -sS -u "username:password123" "http://IP/update?image=myapp&tag=0.1.${CIRCLE_BUILD_NUM}"
```

Now, whenever the CircleCI build runs, the autoupdate call will update the Git repository with the new Docker tag.

### Example 2: Trigger repository updates with a GitHub comment

Based on the previous example, the update can also happen manually, whenever someone comments `/deploy` on a pull request.
This could be achieved using [GitHub Actions](https://github.com/features/actions).

First, add the autoupdate username and password (see example 1) to the [repository secrets](https://help.github.com/en/github/automating-your-workflow-with-github-actions/virtual-environments-for-github-actions#creating-and-using-secrets-encrypted-variables).
The secret name should be `AUTOUPDATE_AUTH` and the value needs to be in the form `username:password`.

Then create the file `.github/workflows/deploy.yml` in the GitHub repository where the comments should be given:

```yaml
name: Deploy on comment
on:
  issue_comment:
    types: created
jobs:
  deploy:
    name: Deploy
    if: github.event.comment.body == '/deploy'
    runs-on: ubuntu-latest
    steps:
      - name: Deploy
        env:
          AUTOUPDATE_URL: http://IP/update
          AUTOUPDATE_AUTH: ${{ secrets.AUTOUPDATE_AUTH }}
        run: |
          pull_request="$(jq -er .issue.number "${GITHUB_EVENT_PATH}")"
          curl -sS -u "${AUTOUPDATE_AUTH}" "${AUTOUPDATE_URL}?image=myapp&tag=pr-${pull_request}"
```

Remember to replace the `IP` with the external IP address of the autoupdate service (see example 1).
Now the autoupdate call will be triggered every time someone adds a new comment with the text `/deploy` in a pull request.

This example assumes that your Docker images are tagged with the pull request number, like `myapp:pr-123`. For another example, where the branch name is used instead, see [example-2/deploy-2.yml](docs/example-2/deploy-2.yml).

### Example 3: Restart deployment when a new image has been pushed

When a new Docker image is pushed to the registry, it will not be used automatically by Kubernetes until the deployment is restarted.
This can be done manually using `kubectl rollout restart`, but it could also be automated.

First, create a _Secret_ with the credentials for authenticating autoupdate users.
Make sure to use a custom password (you can use `pwgen 30 1` or `openssl rand -hex 20` to generate a random string).

```sh
kubectl create secret generic autoupdate-secret \
  --from-literal=USERS="username:password123"
```

Then create the autoupdate deployment:

```sh
kubectl apply -f https://raw.githubusercontent.com/autoapply/autoupdate/master/docs/example-3/autoupdate.yaml
```

When the deployment is running, [find the external IP address](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#finding-your-ip-address) of the autoupdate service.

The last step is to setup a trigger in the Docker registry.

This is different for each registry, the following is an example for the [Azure Container Registry](https://azure.microsoft.com/en-us/services/container-registry/):

```sh
az acr webhook create \
    --actions push \
    --name autoupdate \
    --registry myacr \
    --scope "myapp:latest" \
    --headers "Authorization=Basic 000000" \
    --uri "http://IP/restart?deployment=mydeployment"
```

Make sure to set the correct authorization header. You can get the value from Kubernetes using `kubectl get secret autoupdate-secret -o 'jsonpath={.data.USERS}'`.
Also remember to set `IP` to the external IP address of the autoupdate service and use the correct values instead of `myacr`, `myapp` and `mydeployment`.

Now, whenever the `latest` tag is pushed to the registry, autoupdate will restart the deployment, so that Kubernetes will run the new image.

### DNS and TLS

In the previous examples, we used the external IP address of the service.
To use the DNS name instead, you could have a look at the [external-dns project](https://github.com/kubernetes-sigs/external-dns).

To automatically setup TLS for the service, you could use [caddy](https://github.com/caddyserver/caddy) or [traefik](https://github.com/containous/traefik).

## Docker tags

- `autoupdate/autoupdate:latest` provides the basic image, running as _autoupdate_ user ([Dockerfile](build/Dockerfile))
- `autoupdate/autoupdate:root` provides the basic image, but running as _root_. This can be useful as a base for custom builds ([Dockerfile](build/root/Dockerfile))

## License

[MIT](LICENSE)
