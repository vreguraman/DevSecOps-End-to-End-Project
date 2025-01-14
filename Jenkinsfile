pipeline {
    agent any
    environment {
        VAULT_ADDR = credentials('VAULT_ADDR') // Vault address from Jenkins credentials
        VAULT_TOKEN = credentials('VAULT_TOKEN') // Vault token from Jenkins credentials
    }
    stages {
        stage('Test Vault Connection') {
            steps {
                sh '''
                echo "Vault Address: $VAULT_ADDR"
                echo "Vault Token: $VAULT_TOKEN"
                vault read -format=json aws/creds/dev-role > aws_creds.json
                cat aws_creds.json
                '''
            }
        }
    }
}
