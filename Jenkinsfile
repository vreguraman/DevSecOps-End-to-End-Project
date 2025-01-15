pipeline {
    agent any
    environment {
        VAULT_ADDR = 'http://52.90.125.142:8200'
        VAULT_TOKEN = credentials('VAULT_TOKEN') // Assuming the Vault token is stored in Jenkins credentials
    }
    stages {
        stage('Test Vault') {
            steps {
                sh '''
                echo "Testing Vault Connection..."
                export VAULT_ADDR=${VAULT_ADDR}
                export VAULT_TOKEN=${VAULT_TOKEN}
                vault read -format=json aws/creds/dev-role
                '''
            }
        }
        stage('Terraform Init') {
            steps {
                script {
                    dir('terraform') {
                        sh '''
                        echo "Initializing Terraform..."
                        terraform init
                        '''
                    }
                }
            }
        }
        stage('Terraform Plan') {
            steps {
                script {
                    dir('terraform') {
                        sh '''
                        echo "Running Terraform Plan..."
                        terraform plan -out=tfplan
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
                        echo "Applying Terraform Configuration..."
                        terraform apply -auto-approve tfplan
                        '''
                    }
                }
            }
        }
    }
    post {
        always {
            echo "Pipeline completed."
        }
        success {
            echo "Terraform applied successfully!"
        }
        failure {
            echo "Pipeline failed. Check the logs for details."
        }
    }
}
