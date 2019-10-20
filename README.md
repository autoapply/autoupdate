# autoupdate

[![Docker build status](https://img.shields.io/docker/build/autoapply/autoupdate.svg?style=flat-square)](https://hub.docker.com/r/autoapply/autoupdate/) [![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://github.com/autoapply/autoupdate/blob/master/LICENSE)

Automatically update git repositories.

## Docker tags

* `autoupdate/autoupdate:latest` provides the basic image, running as *autoupdate* user ([Dockerfile](build/Dockerfile))
* `autoupdate/autoupdate:root` provides the basic image, but running as *root*. This can be useful as a base for custom builds ([Dockerfile](build/root/Dockerfile))

## Tools

- bash, git, ssh, curl
- [jq](https://github.com/stedolan/jq)
- [yq](https://github.com/mikefarah/yq)
- [xmlstarlet](http://xmlstar.sourceforge.net/)
- [dockerize](https://github.com/jwilder/dockerize)
- [lstags](https://github.com/ivanilves/lstags)
- [hub](https://github.com/github/hub)
- [autoapply](https://github.com/autoapply/autoapply)
- [mustache](https://github.com/janl/mustache.js)

## License

[MIT](LICENSE)
