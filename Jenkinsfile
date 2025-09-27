// Jenkinsfile (Declarative Pipeline)

pipeline {
    // Top-level agent runs all stages
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
        // Rely on the initial SCM checkout
        
        stage('Test') {
            steps {
                echo 'Running Node.js tests in workspace directory (Forced context)...'
                
                // CRITICAL FIX: Use the 'tool' and 'dir' directives within a 'script' block 
                // to explicitly force the commands into the main workspace and Node environment.
                script {
                    // 1. Explicitly set up the NodeJS environment using the configured tool
                    def nodeHome = tool 'NodeJS_20'
                    env.PATH = "${nodeHome}/bin:${env.PATH}"
                    
                    // 2. Execute commands in the main workspace directory
                    dir (pwd()) { // Ensure we are in the main workspace path
                        sh 'pwd' 
                        
                        // 3. Install dependencies
                        sh 'npm install'  
                        
                        // 4. Run the test script
                        sh 'npm run test' 
                    }
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
