// Jenkinsfile (Declarative Pipeline)

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
                sh 'npm --prefix app install'
                sh 'npm --prefix app run test'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Added a check for git executable path, just in case
                    def git_exec = sh(returnStdout: true, script: 'which git || true').trim()
                    echo "Using git executable: ${git_exec}"
                    
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
                sh "docker pull ${env.DOCKERHUB_REPO}:latest"
                sh "docker stop node-app-running || true"
                sh "docker rm node-app-running || true"
                sh "docker run -d -p 3000:3000 --name node-app-running ${env.DOCKERHUB_REPO}:latest"
                echo "Deployment complete. Application is running on port 3000."
            }
        }
    }
}
