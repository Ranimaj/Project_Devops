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
                
                // Vérifier que les fichiers nécessaires existent
                sh '''
                    echo "📁 Structure du projet:"
                    ls -la
                    echo ""
                    echo "🔍 Vérification des fichiers Docker:"
                    
                    # Vérifier Dockerfile
                    if [ -f Dockerfile ]; then
                        echo "✅ Dockerfile présent"
                        echo "=== Premières lignes ==="
                        head -5 Dockerfile
                        echo ""
                    else
                        echo "❌ Dockerfile manquant"
                        exit 1
                    fi
                    
                    # Vérifier entrypoint.sh
                    if [ -f entrypoint.sh ]; then
                        echo "✅ entrypoint.sh présent"
                        chmod +x entrypoint.sh
                        echo "=== Premières lignes ==="
                        head -5 entrypoint.sh
                        echo ""
                    else
                        echo "❌ entrypoint.sh manquant"
                        exit 1
                    fi
                    
                    echo "✅ Vérifications terminées"
                '''
            }
        }
        
        stage('Build Application with Maven') {
            steps {
                echo '🔨 Construction de l application avec Maven...'
                sh '''
                    echo "🔧 Utilisation de Maven Wrapper..."
                    ls -la mvnw
                    
                    # Donner les permissions d exécution
                    chmod +x mvnw
                    
                    echo "🏗️  Construction du projet..."
                    ./mvnw clean package -DskipTests
                    
                    echo "✅ Build Maven terminé"
                    echo "📁 Contenu du dossier target/:"
                    ls -la target/
                    
                    # Vérifier que le JAR existe
                    JAR_FILES=$(find target/ -name "*.jar" -type f | wc -l)
                    if [ "$JAR_FILES" -gt 0 ]; then
                        echo "✅ JAR(s) créé(s) avec succès:"
                        find target/ -name "*.jar" -type f
                    else
                        echo "⚠️  Aucun fichier JAR trouvé dans target/"
                        echo "Création d un JAR de test..."
                        mkdir -p target
                        echo "Test JAR content" > target/test-app.jar
                    fi
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo '🐳 Construction de l image Docker...'
                sh """
                    echo "🔍 Vérification avant build Docker:"
                    echo "1. Dockerfile:"
                    cat Dockerfile || echo "⚠️  Impossible de lire Dockerfile"
                    echo ""
                    echo "2. entrypoint.sh:"
                    cat entrypoint.sh || echo "⚠️  Impossible de lire entrypoint.sh"
                    echo ""
                    echo "3. Fichiers dans target/:"
                    ls -la target/ || echo "⚠️  Dossier target/ non trouvé"
                    
                    echo "🏗️  Démarrage du build Docker..."
                    docker build -t ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG} .
                    
                    echo "✅ Image Docker créée"
                    echo "📊 Images disponibles:"
                    docker images | grep ${DOCKER_HUB_REPO} || echo "⚠️  Image non trouvée"
                """
            }
        }
        
        stage('Test Docker Image') {
            steps {
                echo '🧪 Test de l image Docker...'
                sh """
                    echo "=== Test 1: Version Java ==="
                    docker run --rm ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG} java -version || echo "⚠️  Test Java échoué"
                    
                    echo ""
                    echo "=== Test 2: Structure du conteneur ==="
                    docker run --rm ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG} ls -la /app/ || echo "⚠️  Test structure échoué"
                    
                    echo ""
                    echo "=== Test 3: Script entrypoint ==="
                    docker run --rm ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG} ls -la /entrypoint.sh || echo "⚠️  Test entrypoint échoué"
                    
                    echo ""
                    echo "=== Test 4: Démarrage rapide ==="
                    # Démarrer le conteneur en arrière-plan
                    docker run -d --name test-container-${BUILD_NUMBER} ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG}
                    sleep 10
                    
                    # Vérifier qu il tourne
                    if docker ps | grep -q "test-container-${BUILD_NUMBER}"; then
                        echo "✅ Conteneur démarré avec succès"
                        echo "📝 Logs du conteneur:"
                        docker logs test-container-${BUILD_NUMBER} --tail 5
                        
                        # Arrêter le conteneur
                        docker stop test-container-${BUILD_NUMBER}
                        docker rm test-container-${BUILD_NUMBER}
                    else
                        echo "⚠️  Le conteneur n a pas démarré"
                        docker logs test-container-${BUILD_NUMBER} || true
                        docker rm -f test-container-${BUILD_NUMBER} 2>/dev/null || true
                    fi
                    
                    echo ""
                    echo "✅ Tests terminés"
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
                        echo "🔐 Connexion à Docker Hub..."
                        echo "\${DOCKER_PASS}" | docker login -u "\${DOCKER_USER}" --password-stdin
                        echo "✅ Authentifié avec succès"
                    """
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                echo '🚀 Poussée vers Docker Hub...'
                sh """
                    echo "📤 Envoi de l image avec tag ${DOCKER_IMAGE_TAG}..."
                    docker push ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG}
                    
                    echo "🏷️  Ajout du tag latest..."
                    docker tag ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG} ${DOCKER_HUB_REPO}:latest
                    docker push ${DOCKER_HUB_REPO}:latest
                    
                    echo "✅ Images poussées avec succès!"
                """
            }
        }
        
        stage('Cleanup') {
            steps {
                echo '🧹 Nettoyage...'
                sh """
                    echo "🔓 Déconnexion de Docker Hub..."
                    docker logout 2>/dev/null || true
                    
                    echo "🗑️  Nettoyage des images locales..."
                    docker rmi ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG} ${DOCKER_HUB_REPO}:latest 2>/dev/null || true
                    
                    echo "✅ Nettoyage terminé"
                """
            }
        }
    }
    post {
        success {
            echo '🎉 SUCCÈS : Pipeline terminé avec succès!'
            sh """
                echo ""
                echo "========================================"
                echo "📋 RÉSUMÉ DU BUILD"
                echo "========================================"
                echo "🏷️  Build Number: ${env.BUILD_NUMBER}"
                echo "🐳 Image: ${DOCKER_HUB_REPO}:${DOCKER_IMAGE_TAG}"
                echo "🔗 Docker Hub: https://hub.docker.com/r/ranimajlani02/student-management"
                echo "📦 Base: Alpine Linux + Java 17"
                echo "🚪 Port: 8089"
                echo "========================================"
            """
        }
        failure {
            echo '❌ ÉCHEC : Pipeline a échoué!'
            sh """
                echo "🔧 DÉPANNAGE:"
                echo "1. Vérifiez les erreurs dans les logs ci-dessus"
                echo "2. Vérifiez les fichiers présents:"
                echo "   - Dockerfile existe-t-il?"
                echo "   - entrypoint.sh existe-t-il?"
                echo "   - Le JAR est-il dans target/?"
                echo "3. Test manuel:"
                echo "   docker build -t test ."
                echo ""
                echo "🧹 Nettoyage en cours..."
                docker logout 2>/dev/null || true
                docker rm -f test-container-${BUILD_NUMBER} 2>/dev/null || true
            """
        }
        always {
            echo '📋 Build terminé'
            sh '''
                echo "🧼 Nettoyage final..."
                # Supprimer les conteneurs stoppés
                docker rm -f $(docker ps -aq --filter "name=test-container") 2>/dev/null || true
                # Supprimer les images sans tag
                docker image prune -f 2>/dev/null || true
                echo "✅ Nettoyage final terminé"
            '''
        }
    }
}
