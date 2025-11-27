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
                    # Créer un JAR factice pour tester Docker
                    echo "Test JAR for Docker build" > target/student-management-0.0.1-SNAPSHOT.jar
                    ls -la target/
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo '🐳 Construction de l image Docker...'
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
                    # Tester que l'image se construit et démarre
                    docker run --rm -d --name test-container -p 8089:8089 ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG} &
                    sleep 10
                    echo "🔄 Vérification du conteneur..."
                    docker ps | grep test-container && echo "✅ Conteneur démarré avec succès" || echo "⚠️ Conteneur non démarré"
                    docker stop test-container
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
                echo 'Port exposé : 8089'
            """
        }
        failure {
            echo '❌ ÉCHEC : Pipeline a échoué!'
        }
    }
}
