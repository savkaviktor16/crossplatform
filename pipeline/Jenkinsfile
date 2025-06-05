pipeline {
    agent any

    environment {
        DOCKER_REGISTRY_CREDENTIALS = 'ghcr-credentials'
    }

    stages {
        stage('Clone') {
            steps {
                echo 'Cloning repository...'
                checkout scm        
            }
        }

        stage('Run tests') {
            steps {
                echo 'Running tests...'
                sh 'make test'        
            }
        }   

        stage('Build') {
            steps {
                echo 'Building Docker image...'
                sh 'make image'        
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://ghcr.io', "${DOCKER_REGISTRY_CREDENTIALS}") {
                        echo 'Pushing Docker image...'
                        sh 'make push'
                    }
                }
            }
        }
    }
}