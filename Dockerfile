FROM jenkins/jenkins:lts

# Set ARG for host's Docker GID (set to 988 for your EC2 instance)
ARG DOCKER_GID=988

USER root

# Install required tools
RUN apt-get update && \
    apt-get install -y git docker.io && \
    rm -rf /var/lib/apt/lists/*

# Add 'jenkins' user to 'docker' group for Docker socket permissions
RUN groupadd -g $DOCKER_GID docker || true && \
    usermod -aG docker jenkins

# Switch back to jenkins user
USER jenkins

