// Jenkinsfile (Declarative Pipeline)

pipeline {
    // Top-level agent runs all stages since the test stage uses 'agent any'
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
        // REMOVED THE EXPLICIT 'Checkout Code' STAGE
        // The repository is now checked out automatically by the Declarative Pipeline engine.

        stage('Test') {
            // FIX: Using 'agent any' to avoid master label errors.
            agent any 
            
            tools {
                // Relies on NodeJS_20 being configured in Global Tool Configuration
                nodejs 'NodeJS_20' 
            }
            steps {
                echo 'Running Node.js tests in workspace directory...'
                
                // CRITICAL FIX: The workspace should now be correctly set by the tool block.
                // Running pwd to confirm the directory is correct: /var/jenkins_home/workspace/node-cicd-project
                sh 'pwd' 
                
                // 1. Install dependencies
                sh 'npm install'  
                
                // 2. Run the test script
                sh 'npm run test' 
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
