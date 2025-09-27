// Jenkinsfile (Declarative Pipeline)

pipeline {
    // Top-level agent runs the initial checkout and final deployment steps.
    // This allows the Git and Docker commands to run on the primary Jenkins environment.
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
                // Ensure correct repo and branch are explicitly checked out
                git branch: 'master', url: "https://github.com/${env.GITHUB_USER}/node-cicd-project.git"
            }
        }

        stage('Test') {
            // FIX: Using 'agent any' to resolve the 'label master' scheduling error.
            // This runs on the built-in controller, which is the only agent.
            agent any 
            
            tools {
                // This ensures the NodeJS_20 tool is prepared and available for the steps.
                nodejs 'NodeJS_20' 
            }
            steps {
                echo 'Running Node.js tests in workspace directory...'
                
                // Ensure commands run within the workspace where package.json is located.
                dir('.') {
                    sh 'pwd' // Verify current directory
                    sh 'npm install'  
                    sh 'npm run test' 
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    env.IMAGE_TAG = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                }
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
