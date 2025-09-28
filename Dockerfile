# Dockerfile
FROM jenkins/jenkins:lts

USER root
RUN apt-get update && \
    apt-get install -y git docker.io \
    && rm -rf /var/lib/apt/lists/*
