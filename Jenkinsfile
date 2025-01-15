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
                export VAULT_ADDR=${VAULT_ADDR}
                export VAULT_TOKEN=${VAULT_TOKEN}
                vault read -format=json aws/creds/dev-role
                '''
            }
        }
        stage('Terraform Apply') {
            steps {
                script {
                    dir('terraform') {
                        sh '''
                        terraform init
                        terraform apply -auto-approve
                        '''
                    }
                }
            }
        }
    }
}