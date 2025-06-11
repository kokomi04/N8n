FROM n8nio/n8n:latest

USER root

RUN apk update && apk add --no-cache \
    bash \
    git \
    curl \
    make \
    openssh && \
    mkdir -p /usr/local/bin && \
    mkdir -p /usr/libexec/docker/cli-plugins && \
    mkdir -p /home/node/.docker && \
    addgroup -g 999 docker || true && \
    adduser node docker || true && \
    chown -R node:node /usr/local/bin && \
    chown -R node:node /home/node/.docker && \
    chmod -R 755 /home/node/.docker

# Default Docker config
RUN echo '{}' > /home/node/.docker/config.json && \
    chown node:node /home/node/.docker/config.json && \
    chmod 644 /home/node/.docker/config.json

USER node

ENV PATH="/usr/local/bin:${PATH}"
ENV DOCKER_HOST=unix:///var/run/docker.sock

