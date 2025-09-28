# Dockerfile
FROM jenkins/jenkins:lts

# Hardcoded GID for the 'docker' group, based on your confirmation (988)
ENV DOCKER_GID=988

USER root

# Install required tools: git, and the Docker CLI
RUN apt-get update && \
    apt-get install -y git docker.io \
    && rm -rf /var/lib/apt/lists/*

# CRITICAL FIX: Ensure the 'jenkins' user is in a group with the host's Docker GID (988)
# 1. Create a group named 'docker' inside the container using the host's GID (988). The '|| true' handles if the group already exists.
# 2. Add the 'jenkins' user to this new 'docker' group.
RUN groupadd -g ${DOCKER_GID} docker || true && \
    usermod -aG docker jenkins

# Switch back to the jenkins user for secure execution
USER jenkins
