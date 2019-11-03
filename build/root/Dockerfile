FROM node:alpine

RUN apk add --no-cache tini bash git openssh-client curl jq \
    && yarn global add autoapply

COPY ./bin/* /usr/local/bin/
