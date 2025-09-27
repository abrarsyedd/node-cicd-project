// Jenkinsfile (Declarative Pipeline)

pipeline {
    // Top-level agent runs all stages
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
        // FIX: REMOVED 'Checkout Code' stage. Rely on initial SCM checkout.

        stage('Test') {
            // CRITICAL FIX: Removed 'agent any' from the stage. 
            // This forces the stage to run in the main workspace 
            // (/var/jenkins_home/workspace/node-cicd-project)
            // which contains the code checked out by the SCM block.
            
            tools {
                // Must be configured in Global Tool Configuration
                nodejs 'NodeJS_20' 
            }
            steps {
                echo 'Running Node.js tests in workspace directory...'
                
                // The 'dir' command is no longer strictly necessary but kept for safety.
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
