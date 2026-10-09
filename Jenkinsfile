pipeline {
    agent any

    environment {
        IMAGE_NAME = 'discoverdevops/aws-devops-demo'
        MINIKUBE_HOST = '10.0.11.158'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKERHUB_USERNAME',
                    passwordVariable: 'DOCKERHUB_PASSWORD'
                )]) {
                    sh '''
                        set -eu
                        docker build -t "$IMAGE_NAME:$BUILD_NUMBER" .
                        echo "$DOCKERHUB_PASSWORD" | docker login --username "$DOCKERHUB_USERNAME" --password-stdin
                        docker push "$IMAGE_NAME:$BUILD_NUMBER"
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'minikube-ssh',
                    keyFileVariable: 'SSH_KEY',
                    usernameVariable: 'SSH_USER'
                )]) {
                    sh '''
                        set -eu
                        REMOTE_DIR="/tmp/aws-devops-demo-$BUILD_NUMBER"
                        SSH_OPTS="-i $SSH_KEY -o StrictHostKeyChecking=no"

                        ssh $SSH_OPTS "$SSH_USER@$MINIKUBE_HOST" "mkdir -p '$REMOTE_DIR'"
                        scp $SSH_OPTS -r k8s "$SSH_USER@$MINIKUBE_HOST:$REMOTE_DIR/"
                        ssh $SSH_OPTS "$SSH_USER@$MINIKUBE_HOST" \
                            "kubectl apply -f '$REMOTE_DIR/k8s' &&
                             kubectl set image deployment/aws-devops-demo aws-devops-demo='$IMAGE_NAME:$BUILD_NUMBER' &&
                             kubectl rollout status deployment/aws-devops-demo"
                    '''
                }
            }
        }
    }
}
