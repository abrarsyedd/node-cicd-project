// Jenkinsfile (Declarative Pipeline)

pipeline {
    // We use the 'any' agent for stages that don't need a specific tool (like Checkout)
    agent any
    
    // Define environment variables for the pipeline
    environment {
        // !!! REPLACE with your actual DockerHub username/repository name
        DOCKERHUB_REPO = 'syed048/node-ci-cd-app'
        // !!! REPLACE with your actual GitHub username
        GITHUB_USER = 'abrarsyedd'
        // Jenkins Secret Text credentials ID for DockerHub login (must be set in Jenkins!)
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-syed048' // Set this ID in Jenkins Secrets
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Checkout code from the SCM (e.g., the GitHub repo that contains this Jenkinsfile)
                git branch: 'master', url: "https://github.com/${env.GITHUB_USER}/node-cicd-project.git"
            }
        }
        
        stage('Test') {
            // Use the Node.js image as the build/test environment
            agent {
                docker {
                    image 'node:20-alpine'
                    args '-u root' // Use root user to prevent potential permission issues
                }
            }
            steps {
                echo 'Running Node.js tests inside the node:20-alpine container...'
                
                // Install dependencies
                sh 'npm --prefix app install'
                
                // Run the test script defined in package.json
                sh 'npm --prefix app run test'
            }
        }

        stage('Build Docker Image') {
            steps {
                // Get the current git commit SHA for the image tag
                script {
                    env.IMAGE_TAG = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                }
                
                // Build the Docker image (uses the host's Docker daemon via docker.sock)
                sh "docker build -t ${env.DOCKERHUB_REPO}:${env.IMAGE_TAG} -t ${env.DOCKERHUB_REPO}:latest ."
            }
        }
        
        stage('Push Docker Image') {
            steps {
                // Use the withCredentials block to securely access DockerHub login
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
        
        stage('Deploy') {
            steps {
                echo "Deployment step: Would deploy ${env.DOCKERHUB_REPO}:${env.IMAGE_TAG} here."
            }
        }
    }
}
