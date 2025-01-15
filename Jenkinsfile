pipeline {
    agent any
    environment {
        VAULT_ADDR = credentials('VAULT_ADDR') // Fetch the Vault address from credentials
        VAULT_TOKEN = credentials('VAULT_TOKEN') // Fetch the Vault token from credentials
    }
    stages {
        stage('Test Vault Connection') {
            steps {
                script {
                    sh '''
                    echo "Vault Address: $VAULT_ADDR"
                    echo "Vault Token: $VAULT_TOKEN"
                    vault read -format=json aws/creds/dev-role > aws_creds.json
                    jq '.data' aws_creds.json > aws_credentials.json
                    '''
                }
            }
        }
    }
}
