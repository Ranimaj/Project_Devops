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
                echo '🔨 Construction du projet Maven avec accès réseau...'
                sh '''
                    docker run --rm \
                        --network=host \
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
                    ls -la target/
                    find target/ -name "*.jar" -type f
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo '🐳 Construction de l image Docker...'
                sh """
                    docker build -t ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG} .
                    echo "Image créée : ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG}"
                """
            }
        }
        
        stage('Test Docker Image') {
            steps {
                echo '🧪 Test de l image Docker...'
                sh """
                    docker run --rm -d --name test-container -p 8089:8089 ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG} &
                    sleep 20
                    echo "Test sur le port 8089..."
                    curl -f http://localhost:8089 || echo "Application en démarrage..."
                    docker stop test-container
                """
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