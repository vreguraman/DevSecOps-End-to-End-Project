pipeline {
    agent any
    environment {
        VAULT_ADDR = credentials('VAULT_ADDR') // Vault address fetched from Jenkins credentials
        VAULT_TOKEN = credentials('VAULT_TOKEN') // Vault token stored in Jenkins credentials
        PATH = "/opt/sonar-scanner/bin:$PATH" // Ensure Sonar Scanner is in PATH
    }
    stages {
        stage('Test Vault') {
            steps {
                sh '''
                echo "Testing Vault Connection..."
                export VAULT_ADDR=${VAULT_ADDR}
                export VAULT_TOKEN=${VAULT_TOKEN}
                vault read -format=json aws/creds/dev-role > aws_creds.json
                jq -r '.data.access_key' aws_creds.json > access_key.txt
                jq -r '.data.secret_key' aws_creds.json > secret_key.txt
                '''
            }
        }
        stage('TFScan') {
            steps {
                script {
                    dir('terraform') {
                        sh '''
                        echo "Running TFScan..."
                        tfsec .
                        '''
                    }
                }
            }
        }
        stage('Build WAR') {
            steps {
                script {
                    sh '''
                    echo "Building project with Maven..."
                    mvn clean install
                    '''
                }
            }
        }
        stage('SonarQube Analysis') {
            steps {
                script {
                    withSonarQubeEnv('SonarQube') {
                        sh '''
                        sonar-scanner \
                            -Dsonar.projectKey=Sample-Ecommerce-Project \
                            -Dsonar.sources=src \
                            -Dsonar.java.binaries=target/classes \
                            -Dsonar.host.url=http://3.92.186.110:9000/ \
                            -Dsonar.login=sqa_c89317d4b88fd2b1fa3a4c3f09e57cb0e67226d0
                        '''
                    }
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                script {
                    dir('terraform') {
                        sh '''
                        export AWS_ACCESS_KEY=$(cat ../access_key.txt)
                        export AWS_SECRET_KEY=$(cat ../secret_key.txt)
                        terraform init
                        terraform apply -auto-approve \
                            -var="aws_access_key=$AWS_ACCESS_KEY" \
                            -var="aws_secret_key=$AWS_SECRET_KEY"
                        '''
                    }
                }
            }
        }
    }
    post {
        always {
            script {
                echo "Cleaning up temporary files..."
                sh 'rm -f aws_creds.json access_key.txt secret_key.txt'
            }
        }
        failure {
            script {
                echo "Pipeline failed. Check logs for details."
            }
        }
    }
}
