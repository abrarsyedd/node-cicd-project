// Jenkinsfile (Declarative Pipeline)

pipeline {
    // Setting agent any at the top allows the initial Checkout and final Deploy stages 
    // to run directly on the Jenkins controller/agent machine.
    agent any 

    triggers {
        // Explicitly tells Jenkins to listen for GitHub PUSH events on this job
        // Requires 'GitHub hook trigger for GITScm polling' to be selected in job config
        githubPush() 
    }

    environment {
        DOCKERHUB_REPO = 'syed048/node-ci-cd-app'
        GITHUB_USER = 'abrarsyedd'
        // This MUST match the ID of the Credentials configured in Jenkins
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-syed048-up' 
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Ensure you are checking out the correct branch (master)
                git branch: 'master', url: "https://github.com/${env.GITHUB_USER}/node-cicd-project.git"
            }
        }

        stage('Test') {
            // Overrides the top-level 'agent any' to use a clean Docker container for node commands
            agent {
                docker {
                    image 'node:20-alpine' // Use the desired Node.js version
                    args '-u root' // Helps with potential file permission issues
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
            // This deployment runs on the EC2 machine where Jenkins is running 
            // and where the Docker daemon is accessible.
            steps {
                echo "Deployment step: Deploying ${env.DOCKERHUB_REPO}:latest..."
                
                // 1. Pull the image we just pushed from Docker Hub 
                // (Ensures the latest version is downloaded if the local cache is stale)
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
