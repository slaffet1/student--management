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
                echo 'Compilation du projet Maven...'
                sh 'mvn clean compile'
            }
        }
        
        stage('Test') {
            steps {
                echo 'Exécution des tests...'
                sh 'mvn test -DskipTests'
            }
        }
        
        stage('Package') {
            steps {
                echo 'Création du fichier JAR...'
                sh 'mvn package -DskipTests'
            }
        }
    }
    
    post {
        success {
            echo '✅ Build réussi !'
        }
        failure {
            echo '❌ Build échoué !'
        }
    }
}
