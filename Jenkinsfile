pipeline {
    agent any
    environment {
        GIT_TAG = ''
        APP_NAME = ''
        APP_DESCRIPTION = ''
        MAINTAINER = ''
        DOCKER_REGISTRY = ''
        DOCKER_IMAGE = ''
        DOCKER_USERNAME = ''
        DOCKER_URL = ''
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
                    env.GIT_TAG = sh(returnStdout: true, script: "git describe --tags --match 'v[0-9]*' --abbrev=0 || echo ''").trim()
                    if (env.GIT_TAG == '') {
                        env.GIT_TAG = 'latest'
                    }
                    echo "Git Tag: ${env.GIT_TAG}"
                }
            }
        }
        stage('Parse Config') {
            steps {
                script {
                    // Parse the configuration file
                    // Set the configuration variables App
                    env.APP_NAME = sh(script: "cat build-config.yaml | /usr/bin/yq -C .config.app.name", returnStdout: true).trim()
                    env.APP_DESCRIPTION = sh(script: "cat build-config.yaml | /usr/bin/yq -C .config.app.description", returnStdout: true).trim()
                    env.MAINTAINER = sh(script: "cat build-config.yaml | /usr/bin/yq -C .config.maintainer", returnStdout: true).trim()
                    // Set the configuration variables Docker
                    env.DOCKER_REGISTRY = sh(script: "cat build-config.yaml | /usr/bin/yq -C .config.registry.url", returnStdout: true).trim()
                    env.DOCKER_IMAGE = sh(script: "cat build-config.yaml | /usr/bin/yq -C .config.registry.image", returnStdout: true).trim()
                    env.DOCKER_USERNAME = sh(script: "cat build-config.yaml | /usr/bin/yq -C .config.registry.username", returnStdout: true).trim()
                    env.DOCKER_URL = sh(script: "echo ${env.DOCKER_REGISTRY}/${env.DOCKER_USERNAME}/${env.DOCKER_IMAGE}", returnStdout: true).trim()
                    // Display the configuration
                    echo "App Name: ${env.APP_NAME}"
                    echo "App Description: ${env.APP_DESCRIPTION}"
                    echo "Maintainer: ${env.MAINTAINER}"
                    echo "Docker URL: ${env.DOCKER_URL}"
                    echo "Version: ${env.GIT_TAG}"
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
                            if (trivyOutput.contains("Total: 0")) {
                                echo "No vulnerabilities found in the source code."
                            } else {
                                echo "Vulnerabilities found in the source code."
                            }
                        }
                    }
                }
                stage('Scanning Source Code with SonarQube') {
                    steps {
                        script {
                            withSonarQubeEnv('SonarQube') {
                                echo 'Running SonarQube Scanner...'
                                sh '/opt/sonar-scanner/bin/sonar-scanner -Dsonar.projectKey=jenkins-laravel -Dsonar.sources=.'
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
                    sh "docker build -t ${env.DOCKER_URL}:${env.GIT_TAG} ."
                }
            }
        }
        stage('Scan Docker Image') {
            steps {
                script {
                    // Run Trivy to scan the Docker image
                    def trivyOutput = sh(script: "trivy image --scanners vuln ${env.DOCKER_URL}:${env.GIT_TAG}", returnStdout: true).trim()
                    // Display Trivy scan results
                    println trivyOutput
                    // Check if vulnerabilities were found
                    if (trivyOutput.contains("Total: 0")) {
                        echo "No vulnerabilities found in the Docker image."
                    } else {
                        echo "Vulnerabilities found in the Docker image."
                    }
                }
            }
        }
        stage('Docker Login') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'container_registry', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASSWORD')]) {
                        echo 'Logging in to Docker registry ${env.DOCKER_REGISTRY}'
                        sh 'echo $DOCKER_PASSWORD | docker login ${env.DOCKER_REGISTRY} -u $DOCKER_USER --password-stdin'
                    }
                }
            }
        }
        stage('Image Push') {
            steps {
                script {
                    echo 'Pushing Docker image...'
                    sh "docker push ${env.DOCKER_URL}:${env.GIT_TAG}"
                }
            }
        }
    }
}
