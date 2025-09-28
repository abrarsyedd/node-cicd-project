// Jenkinsfile (Declarative Pipeline)

pipeline {
    agent any

    environment {
        // !! UPDATE THESE VALUES !!
        DOCKERHUB_REPO = 'syed048/node-ci-cd-app' // Your Docker Hub username/repo
        GITHUB_USER = 'abrarsyedd' // Your GitHub username
        GITHUB_REPO_NAME = 'node-cicd-project' // Your GitHub repository name
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-syed048-up' // Your Jenkins credentials ID for Docker Hub
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Ensure the repository URL is correct
                git branch: 'master', url: "https://github.com/${env.GITHUB_USER}/${env.GITHUB_REPO_NAME}.git"
            }
        }

        stage('Test') {
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
                    env.IMAGE_TAG = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                }
                // The 'app' directory is the root of the application for the Docker build
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

                // Use double quotes for shell variable interpolation in 'sh' step
                sh "docker pull ${env.DOCKERHUB_REPO}:latest"
                sh "docker stop node-app-running || true"
                sh "docker rm node-app-running || true"
                sh "docker run -d -p 3000:3000 --name node-app-running ${env.DOCKERHUB_REPO}:latest"

                echo "Deployment complete. Application is running on port 3000."
            }
        }
    }
}
