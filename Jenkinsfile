pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = 'syed048/node-ci-cd-app' // Docker Hub repo
        GITHUB_USER = 'abrarsyedd'                // GitHub username
        GITHUB_BRANCH = 'master'                  // Branch to build
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-syed048-up' // Jenkins Docker credentials
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Cloning GitHub repository..."
                checkout([$class: 'GitSCM',
                          branches: [[name: env.GITHUB_BRANCH]],
                          userRemoteConfigs: [[url: "https://github.com/${env.GITHUB_USER}/node-cicd-project.git"]]])
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
                sh 'npm --prefix app install'
                sh 'npm --prefix app run test'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    env.IMAGE_TAG = sh(returnStdout: true, script: "git rev-parse --short HEAD").trim()
                }
                sh "docker build -t ${env.DOCKERHUB_REPO}:${env.IMAGE_TAG} -t ${env.DOCKERHUB_REPO}:latest ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CREDENTIALS_ID,
                                                 passwordVariable: 'DOCKER_PASSWORD',
                                                 usernameVariable: 'DOCKER_USERNAME')]) {
                    sh "echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin"
                    sh "docker push ${env.DOCKERHUB_REPO}:${env.IMAGE_TAG}"
                    sh "docker push ${env.DOCKERHUB_REPO}:latest"
                }
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying ${env.DOCKERHUB_REPO}:latest..."
                sh "docker pull ${env.DOCKERHUB_REPO}:latest"
                sh "docker stop node-app-running || true"
                sh "docker rm node-app-running || true"
                sh "docker run -d -p 3000:3000 --name node-app-running ${env.DOCKERHUB_REPO}:latest"
                echo "Deployment complete. Application is running on port 3000."
            }
        }
    }
}

