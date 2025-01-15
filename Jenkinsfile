pipeline {
    agent any
    environment {
        VAULT_ADDR = 'http://52.90.125.142:8200'
        VAULT_TOKEN = credentials('VAULT_TOKEN') // Vault token stored in Jenkins credentials
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
        stage('Terraform Apply') {
            steps {
                script {
                    dir('terraform') {
                        sh '''
                        export AWS_ACCESS_KEY=$(cat ../access_key.txt)
                        export AWS_SECRET_KEY=$(cat ../secret_key.txt)
                        terraform init
                        terraform plan -var="aws_access_key=$AWS_ACCESS_KEY" -var="aws_secret_key=$AWS_SECRET_KEY"
                        terraform apply -auto-approve -var="aws_access_key=$AWS_ACCESS_KEY" -var="aws_secret_key=$AWS_SECRET_KEY"
                        '''
                    }
                }
            }
        }
    }
}
