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
                withCredentials([usernamePassword(credentialsId: 'aws-creds', 
                                                  usernameVariable: 'AWS_ACCESS_KEY_ID', 
                                                  passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    bat """
                        set AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY_ID%
                        set AWS_SECRET_ACCESS_KEY=%AWS_SECRET_ACCESS_KEY%
                        aws ecr get-login-password --region %AWS_REGION% | docker login --username AWS --password-stdin 464672143257.dkr.ecr.ap-south-1.amazonaws.com
                    """
                }
            }
        }

        stage('Build & Push Backend Image') {
            steps {
                script {
                    bat """
                        docker build -t $BACKEND_IMAGE:$IMAGE_TAG backend/
                        docker push $BACKEND_IMAGE:$IMAGE_TAG
                    """
                }
            }
        }

        stage('Build & Push Frontend Image') {
            steps {
                script {
                    bat """
                        docker build -t $FRONTEND_IMAGE:$IMAGE_TAG frontend/
                        docker push $FRONTEND_IMAGE:$IMAGE_TAG
                    """
                }
            }
        }
        stage('implementing infrastructure with terraform'){
            steps {
                dir('Infrastructure') {
                    bat """
                        terraform init
                        terraform plan -out=tfplan
                        terraform apply -auto-approve tfplan
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
