FROM bash:4.4

RUN apk add --update netcat-openbsd && rm -rf /var/cache/apk/* \
    && mkdir -p /app
WORKDIR /app

COPY wait.sh /app