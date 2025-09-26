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
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-syed048' // Set this ID in Jenkins Secrets
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Checkout code from the SCM (e.g., the GitHub repo that contains this Jenkinsfile)
                git branch: 'main', url: "https://github.com/${env.GITHUB_USER}/node-cicd-project.git"
            }
        }
        
        stage('Test') {
            steps {
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
                // Ensure you have configured a 'Secret Text' credential in Jenkins
                // with the ID 'dockerhub-syed048' (or your chosen ID)
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
        stage('Deploy') {
            steps {
                echo "Deployment step: Would deploy ${env.DOCKERHUB_REPO}:${env.IMAGE_TAG} here."
                // Example: sh 'ssh user@yourserver "docker pull ${env.DOCKERHUB_REPO}:latest && docker-compose up -d"'
            }
        }
    }
}
