pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'ghcr.io/jawaracloud'
        DOCKER_IMAGE = 'laravel-filament'
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
                    GIT_TAG = sh(returnStdout: true, script: "git describe --tags --match 'v[0-9]*' --abbrev=0 || echo ''").trim()
                    if (GIT_TAG == '') {
                        GIT_TAG = 'latest'
                    }
                    echo "Git Tag: ${GIT_TAG}"
                }
            }
        }
        stage('Print Branch') {
            steps {
                script {
                    echo "Current branch is: ${env.BRANCH_NAME}"
                    sh 'echo Branch name: ${GIT_BRANCH}'
                }
            }
        }
        stage('Build') {
            when {
                branch 'main'
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
            }
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker_credentials_id', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASSWORD')]) {
                        echo 'Logging in to Docker registry...'
                        sh 'echo $DOCKER_REGISTRY_PASSWORD | docker login $DOCKER_REGISTRY -u $DOCKER_REGISTRY_USERNAME --password-stdin'
                    }
                }
            }
        }
        stage('Image Push') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo 'Pushing Docker image...'
                    sh "docker push $DOCKER_REGISTRY/$DOCKER_IMAGE:${GIT_TAG}"
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
