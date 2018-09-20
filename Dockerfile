FROM alpine

RUN apk add --no-cache bash

RUN mkdir -p /app
WORKDIR /app

COPY wait.sh /app