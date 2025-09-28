# Dockerfile
FROM jenkins/jenkins:lts

# Default GID for 'docker' group in many distros. You MUST override this at build time.
ARG DOCKER_GID=988 

USER root

# Install required tools: git, and the Docker CLI
RUN apt-get update && \
    apt-get install -y git docker.io && \
    rm -rf /var/lib/apt/lists/*

# Fix for "permission denied"
# 1. Create a group named 'docker' inside the container using the host's GID
# 2. Add the 'jenkins' user to this new 'docker' group
RUN groupadd -g $DOCKER_GID docker || true && \
    usermod -aG docker jenkins

# Switch back to the jenkins user
USER jenkins
