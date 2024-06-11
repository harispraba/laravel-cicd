pipeline {
    agent any

    environment {
        DOCKER_REGISTRY='ghcr.io'
        DOCKER_IMAGE='jawaracloud/laravel-filament'
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
        stage('Scanning Source Code') {
            steps {
                script {
                    // Run Trivy to scan the source code
                    def trivyOutput = sh(script: "trivy fs --scanners vuln,secret,misconfig .", returnStdout: true).trim()

                    // Display Trivy scan results
                    println trivyOutput

                    // Check if vulnerabilities were found
                    if (trivyOutput.contains("Total: 0")) {
                        echo "No vulnerabilities found in the Docker image."
                    } else {
                        echo "Vulnerabilities found in the Docker image."
                        currentBuild.result = 'FAILURE'
                    }
                }
            }
        }
        stage('Build') {
            steps {
                script {
                    echo 'Building Docker image...'
                    sh "docker build -t $DOCKER_REGISTRY/$DOCKER_IMAGE:${GIT_TAG} ."
                }
            }
        }
        stage('Scan Docker Image') {
            steps {
                script {
                    // Run Trivy to scan the Docker image
                    def trivyOutput = sh(script: "trivy image --exit-code 1 --severity CRITICAL --light $DOCKER_REGISTRY/$DOCKER_IMAGE:${GIT_TAG}", returnStdout: true).trim()

                    // Display Trivy scan results
                    println trivyOutput

                    // Check if vulnerabilities were found
                    if (trivyOutput.contains("Total: 0")) {
                        echo "No vulnerabilities found in the Docker image."
                    } else {
                        echo "Vulnerabilities found in the Docker image."
                        currentBuild.result = 'FAILURE'
                    }
                }
            }
        }
        stage('Docker Login') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'github', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASSWORD')]) {
                        echo 'Logging in to Docker registry...'
                        sh 'echo $DOCKER_PASSWORD | docker login $DOCKER_REGISTRY -u $DOCKER_USER --password-stdin'
                    }
                }
            }
        }
        stage('Image Push') {
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
