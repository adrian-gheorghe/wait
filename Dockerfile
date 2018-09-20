FROM bash:4.4

RUN mkdir -p /app
WORKDIR /app

COPY wait.sh /app