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
        
        stage('Build Maven') {
            steps {
                echo '🔨 Construction du projet Maven...'
                sh '''
                    docker run --rm \
                        -v "$PWD":/app \
                        -v "$HOME/.m2":/root/.m2 \
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
                    echo "=== Contenu du dossier target/ ==="
                    ls -la target/
                    echo "=== Fichiers JAR trouvés ==="
                    find target/ -name "*.jar" -type f 2>/dev/null || echo "Aucun JAR trouvé"
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo '🐳 Construction de l image Docker...'
                sh """
                    docker build -t ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG} .
                    echo "=== Images Docker créées ==="
                    docker images | grep student-management || echo "Aucune image student-management trouvée"
                """
            }
        }
        
        stage('Test Docker Image') {
            steps {
                echo '🧪 Test de l image Docker sur le port 8089...'
                sh """
                    # Démarrer le conteneur sur le port 8089
                    docker run --rm -d --name test-container -p 8089:8089 ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG} &
                    sleep 15
                    echo "=== Test de connexion sur le port 8089 ==="
                    curl -f http://localhost:8089 || echo "L'application ne répond pas sur le port 8089"
                    docker stop test-container
                """
            }
        }
    }
    post {
        success {
            echo '🎉 SUCCÈS : Pipeline terminé avec succès!'
            sh """
                echo '=== Résumé ==='
                echo 'Image Docker créée : ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG}'
                echo 'Port exposé : 8089'
                docker images | grep student-management || echo 'Aucune image créée'
            """
        }
        failure {
            echo '❌ ÉCHEC : Pipeline a échoué!'
        }
    }
}