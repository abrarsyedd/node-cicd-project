# Dockerfile
FROM jenkins/jenkins:lts

# Default GID for 'docker' group in many distros. You MUST override this at build time.
# Assuming you found and used the correct GID (e.g., 998)
ARG DOCKER_GID=998 

USER root

# Install required tools: git, and the Docker CLI
RUN apt-get update && \
    apt-get install -y git docker.io && \
    rm -rf /var/lib/apt/lists/*

# Fix for "permission denied" by creating the 'docker' group with the host's GID
RUN groupadd -g $DOCKER_GID docker || true && \
    usermod -aG docker jenkins

# Switch back to the jenkins user
USER jenkins
