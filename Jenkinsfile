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
        echo '🔨 Construction du projet Maven...'
        sh '''
            # Essayer d'abord avec le mirror Alibaba
            mvn clean package -DskipTests \
            -Dmaven.repo.remote=https://maven.aliyun.com/repository/public || \
            
            # Si échec, essayer avec ignore SSL complet
            mvn clean package -DskipTests \
            -Dmaven.wagon.http.ssl.insecure=true \
            -Dmaven.wagon.http.ssl.allowall=true \
            -Dmaven.wagon.httpprovider=apache
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
