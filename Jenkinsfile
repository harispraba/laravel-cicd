pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'your_docker_registry'
        DOCKER_IMAGE = 'your_image_name'
        DOCKER_CREDENTIALS_ID = 'your_docker_credentials_id'
        SONARQUBE_SERVER = 'your_sonarqube_server'
        SONARQUBE_CREDENTIALS_ID = 'your_sonarqube_credentials_id'
        DEPLOY_SERVER = 'your_deploy_server'
        SSH_CREDENTIALS_ID = 'your_ssh_credentials_id'
    }

    stages {
        stage('Info') {
            steps {
                echo 'Starting the pipeline...'
            }
        }
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Get Git Tag') {
            steps {
                script {
                    GIT_TAG = sh(returnStdout: true, script: "git describe --tags --match 'v[0-9]*' --abbrev=0").trim()
                    echo "Git Tag: ${GIT_TAG}"
                }
            }
        }
        stage('Build') {
            when {
                branch 'main'
                expression {
                    return GIT_TAG =~ /^v\d+\.\d+\.\d+$/
                }
            }
            steps {
                script {
                    echo 'Building Docker image...'
                    sh "docker build -t $DOCKER_REGISTRY/$DOCKER_IMAGE:${GIT_TAG} ."
                }
            }
        }
        stage('Docker Login') {
            when {
                branch 'main'
                expression {
                    return GIT_TAG =~ /^v\d+\.\d+\.\d+$/
                }
            }
            steps {
                script {
                    echo 'Logging in to Docker registry...'
                    sh 'echo $DOCKER_REGISTRY_PASSWORD | docker login $DOCKER_REGISTRY -u $DOCKER_REGISTRY_USERNAME --password-stdin'
                }
            }
        }
        stage('Image Push') {
            when {
                branch 'main'
                expression {
                    return GIT_TAG =~ /^v\d+\.\d+\.\d+$/
                }
            }
            steps {
                script {
                    echo 'Pushing Docker image...'
                    sh "docker push $DOCKER_REGISTRY/$DOCKER_IMAGE:${GIT_TAG}"
                }
            }
        }
        stage('Test') {
            when {
                branch 'main'
                expression {
                    return GIT_TAG =~ /^v\d+\.\d+\.\d+$/
                }
            }
            steps {
                script {
                    echo 'Running SonarQube analysis...'
                    withSonarQubeEnv('SonarQube') {
                        sh 'sonar-scanner'
                    }

                    echo 'Running Trivy scan...'
                    sh "trivy image $DOCKER_REGISTRY/$DOCKER_IMAGE:${GIT_TAG}"
                }
            }
        }
        stage('Deploy') {
            when {
                branch 'main'
                expression {
                    return GIT_TAG =~ /^v\d+\.\d+\.\d+$/
                }
            }
            steps {
                script {
                    echo 'Deploying to server...'
                    sshagent (credentials: [SSH_CREDENTIALS_ID]) {
                        sh """
                            ssh -o StrictHostKeyChecking=no $DEPLOY_SERVER <<EOF
                            docker pull $DOCKER_REGISTRY/$DOCKER_IMAGE:${GIT_TAG}
                            docker stop laravel_app || true
                            docker rm laravel_app || true
                            docker run -d --name laravel_app -p 80:80 $DOCKER_REGISTRY/$DOCKER_IMAGE:${GIT_TAG}
                            EOF
                        """
                    }
                }
            }
        }
        stage('Healthcheck') {
            when {
                branch 'main'
                expression {
                    return GIT_TAG =~ /^v\d+\.\d+\.\d+$/
                }
            }
            steps {
                script {
                    echo 'Performing health check...'
                    sh 'curl -f http://$DEPLOY_SERVER/ || exit 1'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
