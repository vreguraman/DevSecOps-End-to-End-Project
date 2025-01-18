pipeline {
    agent any
    environment {
        VAULT_ADDR = credentials('VAULT_ADDR')
        VAULT_TOKEN = credentials('VAULT_TOKEN')
        PATH = "/opt/sonar-scanner/bin:$PATH"
    }
    stages {
        // Stage 1: Test Vault Connection
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
        
        // Stage 2: Terraform Security Scan (TFScan)
        stage('TFScan') {
            steps {
                script {
                    dir('terraform') {
                        sh '''
                        echo "Running TFScan..."
                        tfsec .
                        '''
                    }
                }
            }
        }
        
        // Stage 3: Build WAR Package with Maven
        stage('Build WAR') {
            steps {
                script {
                    sh '''
                    echo "Building project with Maven..."
                    mvn clean install
                    '''
                }
            }
        }
        
        // Stage 4: SonarQube Code Analysis
        stage('SonarQube Analysis') {
            steps {
                script {
                    withSonarQubeEnv('SonarQube') {
                        sh '''
                        sonar-scanner \
                            -Dsonar.projectKey=Sample-Ecommerce-Project \
                            -Dsonar.sources=src \
                            -Dsonar.java.binaries=target/classes \
                            -Dsonar.host.url=http://18.212.7.243:9000/ \
                            -Dsonar.login=sqa_c89317d4b88fd2b1fa3a4c3f09e57cb0e67226d0
                        '''
                    }
                }
            }
        }
        
        // Stage 5: Terraform Apply
        stage('Terraform Apply') {
            steps {
                script {
                    dir('terraform') {
                        sh '''
                        export AWS_ACCESS_KEY=$(cat ../access_key.txt)
                        export AWS_SECRET_KEY=$(cat ../secret_key.txt)
                        terraform init
                        terraform apply -auto-approve \
                            -var="aws_access_key=$AWS_ACCESS_KEY" \
                            -var="aws_secret_key=$AWS_SECRET_KEY"
                        '''
                    }
                }
            }
        }
        
        // Stage 6: Docker Build, Scan, and Push
        stage('Docker Build, Scan & Push') {
            steps {
                script {
                    sh '''
                    echo "Fetching Docker credentials from Vault..."
                    export VAULT_ADDR=${VAULT_ADDR}
                    export VAULT_TOKEN=${VAULT_TOKEN}

                    # Fetch Docker credentials from Vault
                    export DOCKER_USERNAME=$(vault kv get -field=username secret/docker)
                    export DOCKER_PASSWORD=$(vault kv get -field=password secret/docker)

                    echo "Building Docker image..."
                    docker build -t $DOCKER_USERNAME/sample-ecommerce-java-app:latest .

                    echo "Scanning Docker image with Trivy..."
                    trivy image --severity HIGH,CRITICAL $DOCKER_USERNAME/sample-ecommerce-java-app:latest

                    echo "Logging in to Docker Hub..."
                    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin

                    echo "Tagging and pushing Docker image..."
                    docker push $DOCKER_USERNAME/sample-ecommerce-java-app:latest
                    '''
                }
            }
        }
        
        // Stage 7: Snyk Security Scan
        stage('Snyk Security Scan') {
            steps {
                script {
                    sh '''
                    echo "Fetching Snyk token from Vault..."
                    export VAULT_ADDR=${VAULT_ADDR}
                    export VAULT_TOKEN=${VAULT_TOKEN}

                    # Fetch Snyk token from Vault
                    export SNYK_TOKEN=$(vault kv get -field=api_token snyk/token)

                    if [ -z "$SNYK_TOKEN" ]; then
                        echo "Error: Snyk token is empty. Exiting..."
                        exit 1
                    fi

                    echo "Authenticating Snyk CLI with fetched token..."
                    snyk auth $SNYK_TOKEN

                    echo "Running Snyk Security Scan..."
                    snyk test || echo "Vulnerabilities found, continuing pipeline."
                    '''
                }
            }
        }
        
        // Stage 8: Generate Ansible Inventory
        stage('Generate Ansible Inventory') {
            steps {
                script {
                    def terraformOutputs = sh(returnStdout: true, script: '''
                    terraform output -json
                    ''').trim()
                    def outputs = readJSON text: terraformOutputs
                    def instanceIps = outputs.instance_ips.value

                    def inventoryContent = "[servers]\n"
                    for (ip in instanceIps) {
                        inventoryContent += "${ip} ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/ansible_key\n"
                    }
                    writeFile(file: 'ansible_inventory.txt', text: inventoryContent)
                }
            }
        }
        
        // Stage 9: Deploy with Ansible
        stage('Deploy with Ansible') {
            steps {
                script {
                    sh '''
                    echo "Deploying application with Ansible..."
                    ansible-playbook -i ansible_inventory.txt deploy-app.yml
                    '''
                }
            }
        }
    }
    
    // Post Actions
    post {
        always {
            script {
                echo "Cleaning up temporary files..."
                sh 'rm -f aws_creds.json access_key.txt secret_key.txt terraform_outputs.json ansible_inventory.txt'
            }
        }
        failure {
            script {
                echo "Pipeline failed. Check logs for details."
            }
        }
    }
}
