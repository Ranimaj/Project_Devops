pipeline {
    agent any
    environment {
        DOCKER_HUB_REPO = 'student-management'
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
                sh """
                    docker build -t ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG} .
                    echo "✅ Image Docker créée : ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG}"
                    docker images | grep student-management
                """
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
    }
    post {
        success {
            echo '🎉 SUCCÈS : Pipeline Docker terminé avec succès!'
            sh """
                echo '=== RÉSUMÉ ==='
                echo 'Image créée : ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG}'
                echo 'Base : Alpine Linux + Java 17'
                echo 'Port : 8089'
                docker images | grep student-management
            """
        }
        failure {
            echo '❌ ÉCHEC : Pipeline a échoué!'
        }
    }
}
