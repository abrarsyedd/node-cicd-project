// Jenkinsfile (Declarative Pipeline)

pipeline {
    // Run the pipeline on the main node, which is the container itself
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
                // Checkout code from the SCM (uses the configuration defined in the Jenkins Job settings)
                // The explicit 'git' step is generally redundant if 'Pipeline script from SCM' is used, 
                // but kept for clarity on where the code comes from.
                git branch: 'master', url: "https://github.com/${env.GITHUB_USER}/node-cicd-project.git"
            }
        }
        
        stage('Install & Test') { // Renamed for clarity, matching your log's intent
            steps {
                // Use the 'sh' step to execute shell commands
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
                
                // Build the Docker image (using the Dockerfile in the root context)
                sh "docker build -t ${env.DOCKERHUB_REPO}:${env.IMAGE_TAG} -t ${env.DOCKERHUB_REPO}:latest ."
            }
        }
        
        stage('Push Docker Image') {
            steps {
                // Use the withCredentials block to securely access DockerHub login
                withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CREDENTIALS_ID, passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    // Login to DockerHub
                    sh "echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin"
                    
                    // Push the images
                    sh "docker push ${env.DOCKERHUB_REPO}:${env.IMAGE_TAG}"
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
