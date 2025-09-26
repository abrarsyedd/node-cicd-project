// Jenkinsfile (Declarative Pipeline)

pipeline {
    agent any
    
    // Define environment variables for the pipeline
    environment {
        // !!! REPLACE with your actual DockerHub username/repository name
        DOCKERHUB_REPO = 'syed048/node-ci-cd-app'
        // !!! REPLACE with your actual GitHub username
        GITHUB_USER = 'abrarsyedd'
        // Jenkins Secret Text credentials ID for DockerHub login (must be set in Jenkins!)
        // This ID must point to a 'Username with password' credential
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-syed048-up' // Renamed the ID for clarity
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Checkout code from the SCM (e.g., the GitHub repo that contains this Jenkinsfile)
                git branch: 'master', url: "https://github.com/${env.GITHUB_USER}/node-cicd-project.git"
            }
        }
        
        stage('Test') {
            // Use the node:20-alpine image to run tests in a clean environment
            agent {
                docker {
                    image 'node:20-alpine'
                    args '-u root' // Run as root to avoid permission issues during install/test
                }
            }
            steps {
                echo 'Running Node.js tests inside the node:20-alpine container...'
                // Run placeholder tests
                sh 'npm --prefix app install'
                sh 'npm --prefix app run test'
            }
        }

        stage('Build Docker Image') {
            steps {
                // Get the current git commit SHA for the image tag
                script {
                    env.IMAGE_TAG = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                }
                
                // Build the Docker image
                sh "docker build -t ${env.DOCKERHUB_REPO}:${env.IMAGE_TAG} -t ${env.DOCKERHUB_REPO}:latest ."
            }
        }
        
        stage('Push Docker Image') {
            steps {
                // Use the withCredentials block to securely access DockerHub login
                // Ensure you have configured a 'Username with password' credential in Jenkins
                withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CREDENTIALS_ID, passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    // Login to DockerHub
                    sh "echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin"
                    
                    // Push the tagged image
                    sh "docker push ${env.DOCKERHUB_REPO}:${env.IMAGE_TAG}"
                    
                    // Push the 'latest' image
                    sh "docker push ${env.DOCKERHUB_REPO}:latest"
                }
            }
        }
        
        // This stage is a placeholder for Deployment (e.g., to a cloud VM, Kubernetes, etc.)
        tage('Deploy') {
            steps {
                echo "Deployment step: Deploying ${env.DOCKERHUB_REPO}:latest..."
                
                // 1. Pull the new 'latest' image (Ensures we have the newest code locally)
                sh "docker pull ${env.DOCKERHUB_REPO}:latest"

                // 2. Stop the old running container (if it exists)
                // The '|| true' allows the build to continue if the container doesn't exist yet
                sh 'docker stop node-app-running || true'

                // 3. Remove the stopped container
                sh 'docker rm node-app-running || true'

                // 4. Start the new container using the latest image
                sh "docker run -d -p 3000:3000 --name node-app-running ${env.DOCKERHUB_REPO}:latest"
                
                echo "Deployment complete. Application is running on port 3000."
            }
        }
    }
}
