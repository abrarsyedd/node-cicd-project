# Dockerfile
FROM jenkins/jenkins:lts

# Install required tools: git, and the Docker CLI
USER root
RUN apt-get update && \
    apt-get install -y git docker.io \
    && rm -rf /var/lib/apt/lists/*

# Note: We are NOT switching back to 'jenkins' or modifying the 'docker' group 
# because the docker-compose.yml forces the container to run as 'root'.
# Leaving the last USER command as root for clarity.
USER root
