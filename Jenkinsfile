pipeline {
    agent any

    environment {
        AWS_REGION = "ap-south-1"
        BACKEND_IMAGE = "464672143257.dkr.ecr.ap-south-1.amazonaws.com/backend"
        FRONTEND_IMAGE = "464672143257.dkr.ecr.ap-south-1.amazonaws.com/frontend"
        IMAGE_TAG = "${GIT_COMMIT}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Authenticate with ECR') {
            steps {
                script {
                    sh """
                        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin 464672143257.dkr.ecr.ap-south-1.amazonaws.com
                    """
                }
            }
        }

        stage('Build & Push Backend Image') {
            steps {
                script {
                    sh """
                        docker build -t $BACKEND_IMAGE:$IMAGE_TAG backend/
                        docker push $BACKEND_IMAGE:$IMAGE_TAG
                    """
                }
            }
        }

        stage('Build & Push Frontend Image') {
            steps {
                script {
                    sh """
                        docker build -t $FRONTEND_IMAGE:$IMAGE_TAG frontend/
                        docker push $FRONTEND_IMAGE:$IMAGE_TAG
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Images pushed successfully with tag: $IMAGE_TAG"
        }
        failure {
            echo "Image build or push failed."
        }
    }
}
