FROM jenkins/jenkins:lts

# Use your EC2 Docker group GID
ARG DOCKER_GID=988

# Run as root for installation and user/group changes
USER root

# Install git and Docker CLI
RUN apt-get update && \
    apt-get install -y git docker.io && \
    rm -rf /var/lib/apt/lists/*

# Create docker group with host GID and add jenkins user to it
RUN groupadd -g $DOCKER_GID docker || true && \
    usermod -aG docker jenkins

# Switch back to jenkins user
USER jenkins
