# Dockerfile
FROM jenkins/jenkins:lts

# Install required tools: git, and the Docker CLI
USER root
RUN apt-get update && \
    apt-get install -y git docker.io \
    && rm -rf /var/lib/apt/lists/*
