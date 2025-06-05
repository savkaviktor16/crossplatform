pipeline {
    agent any

    environment {
        DOCKER_REGISTRY_CREDENTIALS = 'ghcr-credentials'
    }

    parameters {
        choice(name: 'TARGETOS', choices: ['linux', 'windows', 'darwin'], description: 'Target OS')
        choice(name: 'TARGETARCH', choices: ['amd64', 'arm64'], description: 'Target Arch')
    }

    stages {
        stage('Clone') {
            steps {
                echo 'Cloning repository...'
                checkout scm        
            }
        }

        stage('Build') {
            steps {
                echo 'Building Docker image...'
                sh "make image TARGETOS=${params.TARGETOS} TARGETARCH=${params.TARGETARCH}"    
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