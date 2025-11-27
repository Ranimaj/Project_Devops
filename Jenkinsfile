pipeline {
    agent any
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
                sh '''
                    docker run --rm \
                        -v "$PWD":/app \
                        -w /app \
                        maven:3.8.6-openjdk-11 \
                        mvn clean package -DskipTests
                '''
            }
        }
        
        stage('Verify Build') {
            steps {
                echo '✅ Vérification du build...'
                sh '''
                    ls -la target/
                    find target/ -name "*.jar" -type f
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t student-management:latest .'
                sh 'docker images | grep student-management'
            }
        }
    }
        stage('Push to Docker Hub') {
            steps {
                echo '📤 Envoi vers Docker Hub...'
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-hub-credentials',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )]) {
                        sh """
                            docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
                            docker push ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG}
                        """
                    }
                }
            }
        }
    }
    post {
        success {
            echo '🎉 SUCCÈS : Pipeline terminé avec succès!'
            sh """
                echo 'Image Docker créée : ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG}'
                docker images | grep student-management
            """
        }
        failure {
            echo '❌ ÉCHEC : Pipeline a échoué!'
        }
    }
}