pipeline {
    agent any
    environment {
        VAULT_ADDR = credentials('VAULT_ADDR')
        VAULT_TOKEN = credentials('VAULT_TOKEN')
        PATH = "/opt/sonar-scanner/bin:$PATH"
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
                        tfsec . | tee tfscan-report.txt
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
                        echo "Applying Terraform..."
                        export AWS_ACCESS_KEY=$(cat ../access_key.txt)
                        export AWS_SECRET_KEY=$(cat ../secret_key.txt)
                        terraform init
                        terraform apply -auto-approve \
                            -var="aws_access_key=$AWS_ACCESS_KEY" \
                            -var="aws_secret_key=$AWS_SECRET_KEY"

                        echo "Creating dynamic inventory..."
                        terraform output -json public_ips > /opt/ansible/inventory/terraform_inventory.json
                        jq -r '.[] | @text "[all]\n" + .' /opt/ansible/inventory/terraform_inventory.json > /opt/ansible/inventory/hosts.ini
                        echo "Inventory created successfully at /opt/ansible/inventory/hosts.ini"
                        '''
                    }
                }
            }
        }
        stage('Ansible Deployment') {
            steps {
                script {
                    echo "Sleeping for 120 seconds before deployment..."
                    sh 'sleep 120'

                    echo "Running Ansible Playbook..."
                    sh '''
                    ansible-playbook -i /opt/ansible/inventory/hosts.ini /opt/ansible/ansible.yaml
                    '''
                }
            }
        }
    }
    post {
        always {
            script {
                echo "Cleaning up temporary files..."
                sh 'rm -f aws_creds.json access_key.txt secret_key.txt tfscan-report.txt'
            }
        }
        failure {
            script {
                echo "Pipeline failed. Check logs for details."
            }
        }
    }
}
