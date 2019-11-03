FROM node:alpine

RUN apk add --no-cache tini bash git openssh-client curl jq \
    && yarn global add autoapply

COPY ./bin/* /usr/local/bin/

RUN adduser -D -g autoupdate autoupdate

USER autoupdate
WORKDIR /home/autoupdate

RUN git config --global user.name "autoupdate"
RUN git config --global user.email "autoupdate@autoapply.github.io"

ENTRYPOINT [ "/sbin/tini", "--", "autoapply" ]
