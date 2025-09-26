// Jenkinsfile (Declarative Pipeline)

pipeline {
    // Default agent for administrative tasks like SCM checkout (will use the Jenkins container)
    agent any 
    
    // Define environment variables for the pipeline
    environment {
        // !!! REPLACE with your actual DockerHub username/repository name
        DOCKERHUB_REPO = 'syed048/node-ci-cd-app' 
        // !!! REPLACE with your actual GitHub username
        GITHUB_USER = 'abrarsyedd' 
        // Jenkins Secret Text credentials ID for DockerHub login (must be set in Jenkins!)
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-syed048' 
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Checkout code from the SCM (e.g., the GitHub repo that contains this Jenkinsfile)
                // The code is checked out into the Jenkins workspace
                git branch: 'master', url: "https://github.com/${env.GITHUB_USER}/node-cicd-project.git"
            }
        }
        
        stage('Test & Install Dependencies') {
            // *** FIX: Run this stage INSIDE a Node.js Docker container ***
            agent {
                docker {
                    image 'node:20-alpine' // Use the same base image as your Dockerfile
                    args '-u root' // Sometimes needed if the default user doesn't have permissions
                }
            }
            steps {
                // The workspace directory is mounted into the container automatically
                // The commands now run inside the Node.js container, where 'npm' exists!
                sh 'npm --prefix app install'
                sh 'npm --prefix app run test'
            }
        }

        stage('Build Docker Image') {
            // *** Note: This stage runs on the Jenkins container/host again.
            // Since we mounted the Docker socket in docker-compose.yml,
            // 'docker' commands work here, using the dependencies installed in the previous step.
            agent any 
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
            agent any
            steps {
                // ... (rest of the push stage remains the same)
                withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CREDENTIALS_ID, passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh "echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin"
                    sh "docker push ${env.DOCKERHUB_REPO}:${env.IMAGE_TAG}"
                    sh "docker push ${env.DOCKERHUB_REPO}:latest"
                }
            }
        }
        
        stage('Deploy') {
            agent any
            steps {
                echo "Deployment step: Would deploy ${env.DOCKERHUB_REPO}:${env.IMAGE_TAG} here."
            }
        }
    }
}
