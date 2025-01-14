pipeline {
    agent any
    environment {
        VAULT_ADDR = 'http://35.175.182.176:8200/' // Replace with your Vault server's address
        VAULT_TOKEN = credentials('hvs.dV5UcfRvRMzdG7OXqUZUtJVm') // Replace with Jenkins Vault token credential ID
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
            // Clean up temporary files
            sh 'rm -f aws_creds.json aws_credentials.json'
        }
    }
}
