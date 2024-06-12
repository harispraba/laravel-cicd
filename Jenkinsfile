pipeline {
    agent any
    stages {
        stage('Info') {
            steps {
                echo 'Starting the pipeline...'
            }
        }
        stage('Checkout') {
            steps {
                checkout scm: [
                    $class: 'GitSCM',
                    branches: [[name: '*/main']]
                ]
            }
        }
        stage('Get Git Tag') {
            steps {
                script {
                    GIT_TAG = sh(script: "git describe --tags --match 'v[0-9]*' --abbrev=0 || echo 'latest'", returnStdout: true).trim()
                    echo "Git Tag: ${GIT_TAG}"
                }
            }
        }
        // Parse the configuration file
        stage('Parse Config') {
            steps {
                script {
                    // Set the configuration variables App
                    APP_NAME = sh(script: "cat build-config.yaml | /usr/bin/yq -C .config.app.name", returnStdout: true).trim()
                    APP_DESCRIPTION = sh(script: "cat build-config.yaml | /usr/bin/yq -C .config.app.description", returnStdout: true).trim()
                    MAINTAINER = sh(script: "cat build-config.yaml | /usr/bin/yq -C .config.maintainer", returnStdout: true).trim()
                    // Set the configuration variables Docker
                    DOCKER_REGISTRY = sh(script: "cat build-config.yaml | /usr/bin/yq -C .config.registry.url", returnStdout: true).trim()
                    DOCKER_IMAGE = sh(script: "cat build-config.yaml | /usr/bin/yq -C .config.registry.image", returnStdout: true).trim()
                    DOCKER_USERNAME = sh(script: "cat build-config.yaml | /usr/bin/yq -C .config.registry.username", returnStdout: true).trim()
                    DOCKER_URL = sh(script: "echo ${DOCKER_REGISTRY}/${DOCKER_USERNAME}/${DOCKER_IMAGE}:${GIT_TAG}", returnStdout: true).trim()
                    // Set the configuration SonarQube
                    SONAR_PROJECT_KEY = sh(script: "cat build-config.yaml | /usr/bin/yq -C .config.sonarqube.project_key", returnStdout: true).trim()
                    // Display the configuration
                    echo "App Name: ${APP_NAME}"
                    echo "App Description: ${APP_DESCRIPTION}"
                    echo "Maintainer: ${MAINTAINER}"
                    echo "Docker URL: ${DOCKER_URL}"
                    echo "Version: ${GIT_TAG}"
                }
            }
        }
        stage('Parallel Scanning') {
            parallel {
                stage('Scanning Source Code with Trivy') {
                    steps {
                        script {
                            // Run Trivy to scan the source code
                            def trivyOutput = sh(script: "trivy fs --scanners vuln,secret,misconfig .", returnStdout: true).trim()
                            // Display Trivy scan results
                            println trivyOutput
                            // Check if vulnerabilities were found
                            if (trivyOutput.contains("Failures: 0")) {
                                echo "No vulnerabilities found in the source code."
                            } else {
                                echo "Vulnerabilities found in the source code."
                                // error "Vulnerabilities found in the source code."
                            }
                        }
                    }
                }
                stage('Scanning Source Code with SonarQube') {
                    steps {
                        script {
                            withSonarQubeEnv('SonarQube') {
                                echo 'Running SonarQube Scanner...'
                                sh "/opt/sonar-scanner/bin/sonar-scanner -Dsonar.projectKey=${SONAR_PROJECT_KEY} -Dsonar.sources=."
                            }
                        }
                    }
                }
            }
        }
        stage('Build') {
            steps {
                script {
                    echo 'Building Docker image...'
                    sh "docker build -t ${DOCKER_URL} ."
                }
            }
        }
        stage('Scan Docker Image') {
            steps {
                script {
                    // Run Trivy to scan the Docker image
                    def trivyOutput = sh(script: "trivy image --scanners vuln ${DOCKER_URL}", returnStdout: true).trim()
                    // Display Trivy scan results
                    println trivyOutput
                    // Check if vulnerabilities were found
                    if (trivyOutput.contains("Total: 0")) {
                        echo "No vulnerabilities found in the Docker image."
                    } else {
                        echo "Vulnerabilities found in the Docker image."
                        // error "Vulnerabilities found in the Docker image."
                    }
                }
            }
        }
        stage('Docker Login') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'container_registry', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASSWORD')]) {
                        echo "Logging in to Docker registry ${DOCKER_REGISTRY}"
                        sh "echo $DOCKER_PASSWORD | docker login ${DOCKER_REGISTRY} -u $DOCKER_USER --password-stdin"
                    }
                }
            }
        }
        stage('Image Push') {
            steps {
                script {
                    echo 'Pushing Docker image...'
                    sh "docker push ${DOCKER_URL}"
                }
            }
        }
        stage('Deploy to Server') {
           steps {
               script {
                    withCredentials([sshUserPrivateKey(credentialsId: 'server_deployment', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
                        echo 'Deploying to server...'
                        sh "sed -i 's|DOCKER_URL|${DOCKER_URL}|g' docker-compose.yml"
                        // sh "scp docker-compose.yml user@server:/path/to/deploy"
                        // sh "ssh user@server 'docker compose -f /path/to/deploy/docker-compose.yml up -d'"
                    }
               }
           }
        }
    }
    post {
        always {
            echo "I will always say Hello again!"
        }
        success {
            echo "I will only say Hello if the pipeline is successful!"
        }
        failure {
            echo "I will only say Hello if the pipeline has failed!"
        }
    }
}
