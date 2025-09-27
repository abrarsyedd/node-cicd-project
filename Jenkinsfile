// Jenkinsfile (Declarative Pipeline)

pipeline {
    // Top-level agent runs the initial checkout and the final deployment steps.
    agent any 

    triggers {
        // Explicitly tells Jenkins to listen for GitHub PUSH events
        githubPush() 
    }

    environment {
        DOCKERHUB_REPO = 'syed048/node-ci-cd-app'
        GITHUB_USER = 'abrarsyedd'
        // This MUST match the ID of the Credentials configured in Jenkins UI
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
            agent {
                // Runs on the EC2 host (Jenkins Controller/Agent)
                label 'master' 
            }
            tools {
                // FIX: Use the configured NodeJS tool. Name MUST match Jenkins Global Tool Configuration.
                nodejs 'NodeJS_20' 
            }
            steps {
                echo 'Running Node.js tests using the installed NodeJS tool...'
                
                // 1. Install dependencies (in the root, without --prefix)
                sh 'npm install'  
                
                // 2. Run the test script defined in package.json
                sh 'npm run test' 
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Get the short Git commit hash for tagging the image
                    env.IMAGE_TAG = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                }
                // Build the image and tag it with the commit hash and 'latest'
                sh "docker build -t ${env.DOCKERHUB_REPO}:${env.IMAGE_TAG} -t ${env.DOCKERHUB_REPO}:latest ."
            }
        }

        stage('Push Docker Image') {
            steps {
                // Use the configured Jenkins credentials to securely log in
                withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CREDENTIALS_ID, passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh "echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin"
                    // Push both the unique tag and the latest tag
                    sh "docker push ${env.DOCKERHUB_REPO}:${env.IMAGE_TAG}"
                    sh "docker push ${env.DOCKERHUB_REPO}:latest"
                }
            }
        }

        stage('Deploy') {
            // Deployment runs on the EC2 machine where the Docker daemon is accessible.
            steps {
                echo "Deployment step: Deploying ${env.DOCKERHUB_REPO}:latest..."
                
                // 1. Pull the latest image
                sh "docker pull ${env.DOCKERHUB_REPO}:latest" 

                // 2. Stop and remove the old container instance (if it exists)
                sh 'docker stop node-app-running || true'
                sh 'docker rm node-app-running || true'

                // 3. Run the new container in detached mode (-d), mapping port 3000
                sh "docker run -d -p 3000:3000 --name node-app-running ${env.DOCKERHUB_REPO}:latest"
                echo "Deployment complete. Application is running on http://<EC2_PUBLIC_IP>:3000"
            }
        }
    }
}
