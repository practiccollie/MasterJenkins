pipeline {
    agent any
    tools {
        maven 'Maven 3.5.2'
    }
    stages {
        stage('SAST Analysis With SonarCloud') {
            steps {
                withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
                    sh """
                        mvn clean verify sonar:sonar \
                        -Dsonar.projectKey=<YOUR USERNAME> \
                        -Dsonar.organization=<YOUR ORGANIZATION> \
                        -Dsonar.host.url=https://sonarcloud.io \
                        -Dsonar.login=${SONAR_TOKEN}
                    """
                }
            }
        }

        stage('SCA Analysis With Snyk') {
            steps {
                withCredentials([string(credentialsId: 'SNYK_TOKEN', variable: 'SNYK_TOKEN')]) {
                    sh 'mvn snyk:test -fn'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                withDockerRegistry([credentialsId: "DOCKER_LOGIN", url: ""]) {
                    script {
                        app = docker.build("practiccollie")
                    }
                }
            }
        }

        stage('Push Image To AWS ECR') {
            steps {
                script {
                    docker.withRegistry('https://<YOUR IMAGE>.dkr.ecr.us-west-2.amazonaws.com', 'ecr:us-west-2:AWS_CREDENTIALS') {
                        app.push("latest")
                    }
                }
            }
        }

        stage('Deploy Image to K8s') {
            steps {
                withKubeConfig([credentialsId: 'KUBE_LOGIN']) {
                    sh('kubectl delete all --all -n appsec')
                    sh('kubectl apply -f deploy.yaml --namespace=appsec')
                }
            }
        }

        stage('Wait For Deployment') {
            steps {
                sh 'pwd; sleep 180; echo "Application has been deployed on K8S"'
            }
        }

        stage('DAST Analysis With ZAP') {
            steps {
		withKubeConfig([credentialsId: 'KUBE_LOGIN']) {
			sh('zap.sh -cmd -quickurl http://$(kubectl get services/<YOUR APPLICATION> --namespace=appsec -o json| jq -r ".status.loadBalancer.ingress[] | .hostname") -quickprogress -quickout ${WORKSPACE}/zap_report.html')
			archiveArtifacts artifacts: 'zap_report.html'
                }
            }
        }
    }
}
