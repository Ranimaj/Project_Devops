pipeline {
    agent any
    tools {
        maven 'M2_HOME'
    }
    environment {
        DOCKER_HUB_REPO = 'ranimajlani02/student-management'
        DOCKER_IMAGE_TAG = "build-${env.BUILD_NUMBER}"
    }
    stages {
        stage('Checkout Git') {
            steps {
                echo '📥 Téléchargement du code depuis Git...'
                git branch: 'master', 
                url: 'https://github.com/Ranimaj/Project_Devops.git'
            }
        }
        
        stage('Build Maven') {
    steps {
        echo '🔨 Construction du projet Maven avec Docker...'
        sh '''
            # Utiliser un conteneur Docker Maven pour bypass les problèmes réseau
            docker run --rm \
                -v "$PWD":/app \
                -v "$HOME/.m2":/root/.m2 \
                -w /app \
                maven:3.8.6-openjdk-17 \
                mvn clean package -DskipTests
        '''
    }
}
        
        stage('Build Docker Image') {
            steps {
                echo '🐳 Construction de l image Docker...'
                script {
                    dockerImage = docker.build("${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG}")
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                echo '📤 Envoi vers Docker Hub...'
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
                        dockerImage.push()
                        dockerImage.push('latest')
                    }
                }
            }
        }
    }
    post {
        success {
            echo '🎉 SUCCÈS : Pipeline terminé avec succès!'
        }
        failure {
            echo '❌ ÉCHEC : Pipeline a échoué!'
        }
    }
}