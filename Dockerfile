# Use the official Jenkins LTS image as the base
FROM jenkins/jenkins:lts

# Switch to root user to install packages
USER root

# Install required tools: git, and the Docker CLI
# The Docker CLI is needed for the 'Build Docker Image' and 'Deploy' stages
RUN apt-get update \
    && apt-get install -y git default-jdk docker.io \
    && rm -rf /var/lib/apt/lists/*

# Add the 'jenkins' user to the 'docker' group
# This is necessary because the jenkins user inside the container needs permissions
# to access the mounted /var/run/docker.sock (which the user 'root' had in your original compose)
# We will revert to the 'jenkins' user instead of 'root' for better security practices.
RUN usermod -aG docker jenkins

# Switch back to the jenkins user
USER jenkins
