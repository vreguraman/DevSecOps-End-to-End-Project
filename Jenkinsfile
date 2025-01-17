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
                        tfsec .
                        '''
                    }
                }
            }
        }
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
        stage('Docker Build, scan & Push') {
            steps {
                script {
                    sh '''
                    echo "Fetching Docker credentials from Vault..."
                    export VAULT_ADDR=${VAULT_ADDR}
                    export VAULT_TOKEN=${VAULT_TOKEN}

                    # Fetch credentials from Vault
                    export DOCKER_USERNAME=$(vault kv get -field=username secret/docker)
                    export DOCKER_PASSWORD=$(vault kv get -field=password secret/docker)

                    echo "Building Docker image..."
                    docker build -t $DOCKER_USERNAME/sample-ecommerce-java-app:latest .

                    echo "Scanning Docker image with Trivy..."
                    trivy image --severity HIGH,CRITICAL $DOCKER_USERNAME/sample-ecommerce-java-app:latest

                    echo "Logging in to Docker Hub..."
                    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin

                    echo "Tagging and pushing Docker image..."
                    docker tag sample-ecommerce-app $DOCKER_USERNAME/sample-ecommerce-java-app:latest
                    docker push $DOCKER_USERNAME/sample-ecommerce-java-app:latest
                    '''
                }
            }
        }
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
    }
    post {
        always {
            script {
                echo "Cleaning up temporary files..."
                sh 'rm -f aws_creds.json access_key.txt secret_key.txt'
            }
        }
        failure {
            script {
                echo "Pipeline failed. Check logs for details."
            }
        }
    }
}
