// Jenkinsfile (Declarative Pipeline)

pipeline {
    agent any

    // Define environment variables for the pipeline
    environment {
        // DockerHub username and repository
        DOCKERHUB_REPO = 'syed048/node-ci-cd-app'

        // GitHub username for repository access
        GITHUB_USER = 'abrarsyedd'
        
        // Jenkins Credentials ID for DockerHub login
        // Must be a 'Username with password' credential with ID 'dockerhub-syed048-up'
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-syed048-up'
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Checkout the source code from the GitHub repository
                git branch: 'main', url: "https://github.com/${env.GITHUB_USER}/node-cicd-project.git"
            }
        }

        stage('Test') {
            // Use a Docker container as the build agent for this stage
            agent {
                docker {
                    image 'node:20-alpine'
                    args '-u root' // Run as root to avoid any permission issues with npm
                }
            }
            steps {
                echo 'Running Node.js tests inside the node:20-alpine container...'
                sh 'npm --prefix app install'
                sh 'npm --prefix app run test'
            }
        }

        stage('Build Docker Image') {
            steps {
                // Get the current git commit SHA for a unique image tag
                script {
                    env.IMAGE_TAG = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                }

                // Build the Docker image with both a unique tag and the 'latest' tag
                sh "docker build -t ${env.DOCKERHUB_REPO}:${env.IMAGE_TAG} -t ${env.DOCKERHUB_REPO}:latest ."
            }
        }

        stage('Push Docker Image') {
            steps {
                // Use Jenkins credentials to securely log in to DockerHub
                withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CREDENTIALS_ID, passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    // Login to DockerHub
                    sh "echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin"

                    // Push both the uniquely tagged and 'latest' images
                    sh "docker push ${env.DOCKERHUB_REPO}:${env.IMAGE_TAG}"
                    sh "docker push ${env.DOCKERHUB_REPO}:latest"
                }
            }
        }

        stage('Deploy') {
            steps {
                echo "Deployment step: Deploying ${env.DOCKERHUB_REPO}:latest..."

                // 1. Pull the new 'latest' image
                sh "docker pull ${env.DOCKERHUB_REPO}:latest"

                // 2. Stop the old running container if it exists (the '|| true' prevents failure if it's not running)
                sh 'docker stop node-app-running || true'

                // 3. Remove the old container
                sh 'docker rm node-app-running || true'

                // 4. Start a new container from the newly pulled image
                sh "docker run -d -p 3000:3000 --name node-app-running ${env.DOCKERHUB_REPO}:latest"

                echo "Deployment complete. Application is running on port 3000."
            }
        }
    }
}
