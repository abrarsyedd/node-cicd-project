version: '3.8'
services:
  # Jenkins Controller Service
  jenkins:
    # We will use the official Jenkins LTS Docker image
    image: jenkins/jenkins:lts
    # Run the container as root to avoid permissions issues with the mounted /var/run/docker.sock
    user: root 
    # Map container ports to host ports
    ports:
      - "8080:8080" # Jenkins web UI
      - "50000:50000" # Jenkins agent communication
    # Mount local directories for persistence and Docker access
    volumes:
      # Persistent storage for Jenkins data
      - jenkins_home:/var/jenkins_home
      # Mount the Docker socket for Jenkins to run Docker commands
      - /var/run/docker.sock:/var/run/docker.sock
    # Set necessary environment variables for Docker operations within Jenkins
    environment:
      - DOCKER_HOST=unix:///var/run/docker.sock
    container_name: jenkins-server
    restart: unless-stopped

volumes:
  jenkins_home:
