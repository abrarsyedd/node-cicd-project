// Jenkinsfile (Declarative Pipeline)

pipeline {
    agent any 

    triggers {
        githubPush() 
    }

    environment {
        DOCKERHUB_REPO = 'syed048/node-ci-cd-app'
        GITHUB_USER = 'abrarsyedd'
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-syed048-up' 
    }

    stages {
        stage('Checkout Code') {
            steps {
                // SCM checkout is already handled by the Pipeline definition
                // Removing explicit 'git branch' command here is cleaner
                echo 'Skipping explicit git checkout, using SCM definition.'
            }
        }

        stage('Test') {
            // FIX: Switching from 'docker' agent to 'tools' agent 
            // relying on the NodeJS Plugin configuration in Jenkins UI
            agent {
                // Requires the name 'NodeJS_20' to be configured in Global Tool Configuration
                label 'master'
            }
            tools {
                nodejs 'NodeJS_20' // Use the name from Global Tool Configuration
            }
            steps {
                echo 'Running Node.js tests using the installed NodeJS tool...'
                sh 'npm --prefix app install'
                sh 'npm --prefix app run test'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Ensure the 'docker' command is available on the agent here
                    env.IMAGE_TAG = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                }
                // This command now relies on the DOCKER_SOCK being mounted to the host's daemon
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
                sh 'docker stop node-app-running || true'
                sh 'docker rm node-app-running || true'
                sh "docker run -d -p 3000:3000 --name node-app-running ${env.DOCKERHUB_REPO}:latest"
                echo "Deployment complete. Application is running on http://<EC2_PUBLIC_IP>:3000"
            }
        }
    }
}
