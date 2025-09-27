// Jenkinsfile (Declarative Pipeline)

pipeline {
    // CRITICAL FIX: Keep agent 'any' ONLY at the top level
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
                echo 'Checking out code using job SCM configuration...'
                // Ensure the initial checkout is complete and populates the workspace
                checkout scm 
            }
        }

        stage('Test') {
            // CRITICAL FIX: Remove 'agent any' from this stage.
            // This forces the stage to use the top-level agent (and workspace), 
            // avoiding the problematic second checkout and the '@2' suffix workspace.
            
            tools {
                nodejs 'NodeJS_20' 
            }
            steps {
                echo 'Running Node.js tests in workspace directory...'
                
                // dir is kept but should now be running in the correct location
                dir('.') {
                    sh 'pwd' 
                    
                    // 1. Install dependencies
                    sh 'npm install'  
                    
                    // 2. Run the test script
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
