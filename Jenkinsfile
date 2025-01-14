pipeline {
    agent any
    environment {
        VAULT_ADDR = credentials('VAULT_ADDR') // Fetch Vault address from Jenkins credentials
        VAULT_TOKEN = credentials('VAULT_TOKEN') // Fetch Vault token from Jenkins credentials
    }
    stages {
        stage('Fetch AWS Credentials from Vault') {
            steps {
                script {
                    // Fetch AWS credentials using Vault CLI
                    sh '''
                    export VAULT_ADDR=$VAULT_ADDR
                    export VAULT_TOKEN=$VAULT_TOKEN
                    vault read -format=json aws/creds/dev-role > aws_creds.json
                    jq '.data' aws_creds.json > aws_credentials.json
                    '''
                }
            }
        }
    }
    post {
        always {
            node {
                // Clean up temporary files inside a valid node context
                sh 'rm -f aws_creds.json aws_credentials.json'
            }
        }
    }
}
