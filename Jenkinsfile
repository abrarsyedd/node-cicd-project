// Jenkinsfile (Declarative Pipeline)

pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = 'syed048/node-ci-cd-app' 
        GITHUB_USER = 'abrarsyedd' 
        GITHUB_BRANCH = 'master' 
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-syed048-up' 
    }

    stages {
        stage('Prepare Workspace') { steps { echo "Workspace contents after SCM checkout:"; sh 'ls -a' } }

        stage('Test') {
            agent { docker { image 'node:20-alpine' } }
            steps {
                echo 'Running Node.js tests inside the node:20-alpine container...'
                sh 'npm --prefix app install' 
                sh 'npm --prefix app run test'
            }
        }

        stage('Build Docker Image') {
            steps {
                script { env.IMAGE_TAG = sh(returnStdout: true, script: "git rev-parse --short HEAD").trim() }
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
