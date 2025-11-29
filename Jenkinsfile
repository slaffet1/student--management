pipeline {
    agent any
    
    tools {
        maven 'maven'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Récupération du code depuis GitHub...'
                git branch: 'main', url: 'https://github.com/slaffet1/student--management.git'
            }
        }
        
        stage('Build') {
            steps {
                echo 'Compilation du projet...'
                sh 'mvn clean compile'
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                echo 'Analyse de la qualité du code...'
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar'
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                echo 'Vérification du Quality Gate...'
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        
        stage('Package') {
            steps {
                echo 'Création du JAR...'
                sh 'mvn package -DskipTests'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Construction de l\'image Docker...'
                sh 'docker build -t student-management:latest .'
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Déploiement du conteneur...'
                sh 'docker stop student-app || true'
                sh 'docker rm student-app || true'
                sh 'docker run -d --name student-app -p 8090:8090 student-management:latest'
            }
        }
    }
    
    post {
        success {
            echo ' Pipeline réussi : Code de qualité déployé !'
        }
        failure {
            echo 'Pipeline échoué : Vérifiez les logs SonarQube ou Jenkins'
        }
    }
}
