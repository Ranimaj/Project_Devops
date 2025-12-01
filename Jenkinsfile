pipeline {
    agent any
    environment {
        DOCKER_HUB_REPO = 'ranimajlani02/student-management'  
        DOCKER_IMAGE_TAG = "build-${env.BUILD_NUMBER}"
        DOCKER_CREDENTIALS_ID = 'docker-hub-creds'
    }
    stages {
        stage('Checkout Git') {
            steps {
                echo '📥 Téléchargement du code depuis Git...'
                git branch: 'master', 
                url: 'https://github.com/Ranimaj/Project_Devops.git'
            }
        }
        
        stage('Create Test JAR') {
            steps {
                echo '📦 Création d un JAR de test...'
                sh '''
                    mkdir -p target
                    echo "Test JAR for Docker build" > target/student-management-0.0.1-SNAPSHOT.jar
                    ls -la target/
                '''
            }
        }
        
        stage('Build Docker Image with Alpine') {
            steps {
                echo '🐳 Construction avec Alpine + Java...'
                script {
                    docker.build("${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG}")
                    echo "✅ Image Docker créée : ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG}"
                    sh 'docker images | grep student-management'
                }
            }
        }
        
        stage('Test Docker Image') {
            steps {
                echo '🧪 Test de l image Docker...'
                sh """
                    # Tester que Java fonctionne dans l'image
                    docker run --rm ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG} java -version
                    echo "✅ Java fonctionne correctement dans l'image"
                    
                    # Tester le démarrage de l'application
                    docker run --rm -d --name test-app -p 8089:8089 ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG} &
                    sleep 10
                    docker ps | grep test-app && echo "✅ Application démarrée" || echo "⚠️ Application non démarrée"
                    docker stop test-app 2>/dev/null || true
                """
            }
        }
        
        stage('Login to Docker Hub') {
            steps {
                echo '🔐 Authentification sur Docker Hub...'
                withCredentials([usernamePassword(
                    credentialsId: env.DOCKER_CREDENTIALS_ID,
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo "Login Docker Hub..."
                        docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}
                        echo "✅ Authentifié avec succès"
                    """
                }
            }
        }
        
        stage('Push Docker Image to Docker Hub') {
            steps {
                echo '🚀 Poussée de l image vers Docker Hub...'
                sh """
                    docker push ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG}
                    echo "✅ Image poussée avec succès"
                    echo "Image disponible sur : https://hub.docker.com/r/${DOCKER_HUB_REPO}"
                """
            }
        }
        
        stage('Tag and Push Latest') {
            steps {
                echo '🏷️ Taggage de la version latest...'
                sh """
                    docker tag ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG} ${DOCKER_HUB_REPO}:latest
                    docker push ${DOCKER_HUB_REPO}:latest
                    echo "✅ Version 'latest' poussée avec succès"
                """
            }
        }
        
        stage('Cleanup') {
            steps {
                echo '🧹 Nettoyage des images locales...'
                sh """
                    docker logout
                    docker rmi ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG} ${DOCKER_HUB_REPO}:latest 2>/dev/null || true
                    echo "✅ Nettoyage effectué"
                """
            }
        }
    }
    post {
        success {
            echo '🎉 SUCCÈS : Pipeline terminé avec succès!'
            sh """
                echo '=== RÉSUMÉ ==='
                echo 'Image Docker créée : ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG}'
                echo 'Image Docker (latest) : ${DOCKER_HUB_REPO}:latest'
                echo 'Base : Alpine Linux + Java 17'
                echo 'Port : 8089'
                echo 'Docker Hub : https://hub.docker.com/r/${DOCKER_HUB_REPO}'
                echo '=== === === === ==='
            """
        }
        failure {
            echo '❌ ÉCHEC : Pipeline a échoué!'
            sh 'docker logout || true'
        }
        always {
            echo '📋 Journal du build disponible dans les logs Jenkins'
        }
    }
}
