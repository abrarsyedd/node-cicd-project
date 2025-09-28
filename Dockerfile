# Dockerfile
FROM jenkins/jenkins:lts

ARG DOCKER_GID=988

USER root

RUN apt-get update && \
    apt-get install -y git docker.io && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -g $DOCKER_GID docker || true && \
    usermod -aG docker jenkins

USER jenkins
