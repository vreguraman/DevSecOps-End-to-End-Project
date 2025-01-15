pipeline {
    agent any
    environment {
        VAULT_ADDR = credentials('VAULT_ADDR') // Vault address fetched from Jenkins credentials
        VAULT_TOKEN = credentials('VAULT_TOKEN') // Vault token stored in Jenkins credentials
    }
    stages {
        stage('Test Vault') {
            steps {
                script {
                    try {
                        sh '''
                        echo "Testing Vault Connection..."
                        export VAULT_ADDR=${VAULT_ADDR}
                        export VAULT_TOKEN=${VAULT_TOKEN}
                        vault read -format=json aws/creds/dev-role > aws_creds.json
                        jq -r '.data.access_key' aws_creds.json > access_key.txt
                        jq -r '.data.secret_key' aws_creds.json > secret_key.txt
                        '''
                    } catch (Exception e) {
                        error "Vault connection failed: ${e.message}"
                    }
                }
            }
        }
        stage('TFScan') {
            steps {
                script {
                    dir('terraform') {
                        try {
                            sh '''
                            tfscan .
                            '''
                            if (fileExists('tfscan-results.txt')) {
                                def results = readFile('tfscan-results.txt')
                                if (results.contains('CRITICAL')) {
                                    error "TFScan detected critical issues."
                                }
                            }
                        } catch (Exception e) {
                            error "TFScan failed: ${e.message}"
                        }
                    }
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                script {
                    dir('terraform') {
                        try {
                            sh '''
                            export AWS_ACCESS_KEY=$(cat ../access_key.txt)
                            export AWS_SECRET_KEY=$(cat ../secret_key.txt)
                            terraform init
                            terraform plan -var="aws_access_key=$AWS_ACCESS_KEY" -var="aws_secret_key=$AWS_SECRET_KEY"
                            terraform apply -auto-approve -var="aws_access_key=$AWS_ACCESS_KEY" -var="aws_secret_key=$AWS_SECRET_KEY"
                            '''
                        } catch (Exception e) {
                            error "Terraform execution failed: ${e.message}"
                        }
                    }
                }
            }
        }
        stage('Cleanup') {
            steps {
                sh '''
                echo "Cleaning up temporary files..."
                rm -f aws_creds.json access_key.txt secret_key.txt
                '''
            }
        }
    }
}
