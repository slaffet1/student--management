pipeline {
    agent any
    
    triggers {
        githubPush()
    }
    
    tools {
        maven 'maven'
    }
    
    environment {
        SONAR_TOKEN = credentials('sonarqube-token')
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKERHUB_REPO = 'laffetsaid/student-management'
        IMAGE_TAG = "${BUILD_NUMBER}"
        K8S_NAMESPACE = 'devops'
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
                    sh '''
                        mvn sonar:sonar \
                        -Dsonar.projectKey=student-management \
                        -Dsonar.projectName="Student Management" \
                        -Dsonar.host.url=http://localhost:9000 \
                        -Dsonar.token=${SONAR_TOKEN}
                    '''
                }
                echo 'Analyse envoyée à SonarQube'
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
                sh """
                    docker build -t ${DOCKERHUB_REPO}:${IMAGE_TAG} .
                    docker tag ${DOCKERHUB_REPO}:${IMAGE_TAG} ${DOCKERHUB_REPO}:latest
                """
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                echo 'Connexion et push vers Docker Hub...'
                sh """
                    echo \$DOCKERHUB_CREDENTIALS_PSW | docker login -u \$DOCKERHUB_CREDENTIALS_USR --password-stdin
                    docker push ${DOCKERHUB_REPO}:${IMAGE_TAG}
                    docker push ${DOCKERHUB_REPO}:latest
                    docker logout
                """
            }
        }
        
        stage('Deploy MySQL to Kubernetes') {
            steps {
                echo 'Déploiement de MySQL sur Kubernetes...'
                sh """
                    kubectl apply -f k8s/mysql-deployment.yaml
                    kubectl wait --for=condition=ready pod -l app=mysql -n ${K8S_NAMESPACE} --timeout=300s || true
                """
            }
        }
        
        stage('Deploy App to Kubernetes') {
            steps {
                echo 'Déploiement de l\'application sur Kubernetes...'
                sh """
                    kubectl apply -f k8s/spring-deployment.yaml
                    kubectl set image deployment/student-management student-management=${DOCKERHUB_REPO}:${IMAGE_TAG} -n ${K8S_NAMESPACE}
                    kubectl rollout status deployment/student-management -n ${K8S_NAMESPACE} --timeout=300s
                """
            }
        }
        
        stage('Verify Deployment') {
            steps {
                echo 'Vérification du déploiement...'
                sh """
                    echo '=== Pods ==='
                    kubectl get pods -n ${K8S_NAMESPACE}
                    echo '=== Services ==='
                    kubectl get svc -n ${K8S_NAMESPACE}
                    echo '=== Deployments ==='
                    kubectl get deployments -n ${K8S_NAMESPACE}
                """
            }
        }
    }
    
    post {
        success {
            echo '✅ Pipeline réussi avec succès'
            echo "📦 Image Docker: ${DOCKERHUB_REPO}:${IMAGE_TAG}"
            echo '🌐 Application accessible via: http://127.0.0.1:30080'
        }
        failure {
            echo '❌ Pipeline échoué - Vérifiez les logs'
            sh 'kubectl get pods -n devops || true'
            sh 'kubectl logs -l app=student-management -n devops --tail=50 || true'
        }
        always {
            echo 'Nettoyage des images locales...'
            sh """
                docker rmi ${DOCKERHUB_REPO}:${IMAGE_TAG} || true
                docker rmi ${DOCKERHUB_REPO}:latest || true
            """
        }
    }
}     
