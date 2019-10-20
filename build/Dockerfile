FROM golang:alpine AS go

RUN apk add --no-cache git \
    && go get github.com/mikefarah/yq \
    && go get github.com/jwilder/dockerize \
    && go get github.com/ivanilves/lstags \
    && go get github.com/github/hub

FROM node:alpine

COPY --from=go /go/bin/* /usr/local/bin/

RUN apk add --no-cache tini bash git openssh-client curl jq xmlstarlet \
    && yarn global add autoapply mustache

RUN adduser -D -g autoupdate autoupdate

USER autoupdate
WORKDIR /home/autoupdate
ENTRYPOINT [ "/sbin/tini", "--", "autoapply" ]
