pipeline {
    agent any
    environment {
        VAULT_ADDR = 'http://<Vault_Server_IP>:8200'
        VAULT_TOKEN = credentials('VAULT_TOKEN')
    }
    stages {
        stage('Test Vault') {
            steps {
                sh '''
                vault read -format=json aws/creds/dev-role > aws_creds.json
                jq '.data' aws_creds.json
                '''
            }
        }
        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh '''
                    terraform init
                    terraform plan
                    terraform apply -auto-approve
                    '''
                }
            }
        }
    }
}
