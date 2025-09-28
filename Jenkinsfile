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

<<<<<<< HEAD
volumes:
  jenkins_home:
=======
pipeline {
    // Agent 'any' means the build runs on the master Jenkins node (your EC2 instance)
    agent any 

    environment {
        // !! UPDATE THESE VALUES !!
        DOCKERHUB_REPO = 'syed048/node-ci-cd-app' // Your Docker Hub username/repo
        GITHUB_USER = 'abrarsyedd' // Your GitHub username
        GITHUB_BRANCH = 'master' // Explicit branch
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-syed048-up' // Your Jenkins credentials ID for Docker Hub
    }

    // The code is checked out by the Jenkins job SCM configuration before the pipeline starts.

    stages {
        stage('Test') {
            // Run tests inside a Node.js container for a clean, consistent environment
            agent {
                docker {
                    image 'node:20-alpine'
                    args '-u root'
                }
            }
            steps {
                echo 'Running Node.js tests inside the node:20-alpine container...'
                // Install and run tests for the 'app' directory within the workspace
                sh 'npm --prefix app install'
                sh 'npm --prefix app run test'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Get the short Git commit hash for the image tag
                    env.IMAGE_TAG = sh(returnStdout: true, script: "git rev-parse --short HEAD").trim()
                }
                // The '.' references the current workspace 
                sh "docker build -t ${env.DOCKERHUB_REPO}:${env.IMAGE_TAG} -t ${env.DOCKERHUB_REPO}:latest ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CREDENTIALS_ID, passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh "echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin"
                    sh "docker push ${env.DOCKERHUB_REPO}:${env.IMAGE_TAG}"
                    sh "docker push ${env.DOCKERHUB_REPO}:latest"
                }
            }
        }

        stage('Deploy') {
            steps {
                echo "Deployment step: Deploying ${env.DOCKERHUB_REPO}:latest..."

                // Pull, stop, remove old container, and run new one on the EC2 host
                sh "docker pull ${env.DOCKERHUB_REPO}:latest"
                sh "docker stop node-app-running || true"
                sh "docker rm node-app-running || true"
                sh "docker run -d -p 3000:3000 --name node-app-running ${env.DOCKERHUB_REPO}:latest"

                echo "Deployment complete. Application is running on port 3000."
            }
        }
    }
}
>>>>>>> 142101d (Initial Commit)
