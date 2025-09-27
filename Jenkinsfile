// Jenkinsfile (Declarative Pipeline)

pipeline {
    // Top-level agent runs all stages since there are no specialized Docker agents
    agent any 

    triggers {
        // Automatically trigger on GitHub PUSH events
        githubPush() 
    }

    environment {
        DOCKERHUB_REPO = 'syed048/node-ci-cd-app'
        GITHUB_USER = 'abrarsyedd'
        // This MUST match the ID of the Credentials configured in Jenkins UI
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-syed048-up' 
    }

    stages {
        // FIX: The 'Checkout Code' stage has been REMOVED.
        // Jenkins automatically performs the checkout based on the job configuration 
        // before the first stage. We rely on that.

        stage('Test') {
            // FIX: Using 'agent any' is correct to run on the controller.
            agent any 
            
            tools {
                // Must be configured in Global Tool Configuration
                nodejs 'NodeJS_20' 
            }
            steps {
                echo 'Running Node.js tests in workspace directory...'
                
                // CRITICAL ASSUMPTION: package.json is in the root of the workspace.
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
                    // Get commit hash for tagging
                    env.IMAGE_TAG = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                }
                // Build the image using the host's Docker daemon via the mounted socket
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
