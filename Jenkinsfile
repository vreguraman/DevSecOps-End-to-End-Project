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
        stage('Run Tests') {
            steps {
                echo "Running npm tests in the 'src' directory..."
                dir('src') {
                    sh '''
                        npm install
                        npm test
                    '''
                }
            }
        }
        // SonarQube Analysis
        stage('SonarQube Analysis') {
            steps {
                script {
                    withSonarQubeEnv('SonarQube') {
                        sh '''
                        echo "Running SonarQube Analysis..."
                        sonar-scanner \
                            -Dsonar.projectKey=Sample-Ecommerce-Project \
                            -Dsonar.sources=src \
                            -Dsonar.java.binaries=target/classes \
                            -Dsonar.host.url=http://3.91.226.9:9000/ \
                            -Dsonar.login=sqa_c89317d4b88fd2b1fa3a4c3f09e57cb0e67226d0 | tee sonar-report.txt
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
        stage('Docker Build, Scan & Push') {
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
                    trivy image --severity HIGH,CRITICAL $DOCKER_USERNAME/sample-ecommerce-java-app:latest | tee trivy-report.txt

                    echo "Logging in to Docker Hub..."
                    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin

                    echo "Pushing Docker image to Docker Hub..."
                    docker push $DOCKER_USERNAME/sample-ecommerce-java-app:latest
                    '''
                }
            }
        }
        stage('Nexus Integration') {
            steps {
                script {
                    sh '''
                    echo "Fetching Nexus credentials from Vault..."
                    export VAULT_ADDR=${VAULT_ADDR}
                    export VAULT_TOKEN=${VAULT_TOKEN}

                    # Fetch credentials from Vault
                    export NEXUS_USERNAME=$(vault kv get -field=username nexus/credentials)
                    export NEXUS_PASSWORD=$(vault kv get -field=password nexus/credentials)
                    export NEXUS_REPO_URL=$(vault kv get -field=repo_url nexus/credentials)

                    echo "Uploading artifact to Nexus..."
                    ARTIFACT=/var/lib/jenkins/workspace/vault/target/project-0.0.1-SNAPSHOT.jar
                    if [ ! -f "$ARTIFACT" ]; then
                        echo "Error: Artifact $ARTIFACT not found. Exiting..."
                        exit 1
                    fi

                    curl -u $NEXUS_USERNAME:$NEXUS_PASSWORD \
                        --upload-file $ARTIFACT \
                        $NEXUS_REPO_URL/repository/e-commerce/

                    echo "Artifact uploaded successfully to Nexus."
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
                    snyk test | tee snyk-report.txt || echo "Vulnerabilities found, continuing pipeline."
                    '''
                }
            }
        }
        stage('Send Reports to Developers') {
            steps {
                script {
                    echo "Sending scan reports to developers..."
                    sh '''
                    echo "SonarQube Analysis Results:" > email-body.txt
                    cat sonar-report.txt >> email-body.txt

                    echo "\nTerraform Security Scan Results:" >> email-body.txt
                    cat terraform/tfscan-report.txt >> email-body.txt

                    echo "\nTrivy Docker Image Scan Results:" >> email-body.txt
                    cat trivy-report.txt >> email-body.txt

                    echo "\nSnyk Vulnerabilities Report:" >> email-body.txt
                    cat snyk-report.txt >> email-body.txt

                    echo "Emailing Reports..."
                    mail -s "Security Scan Reports from CI/CD Pipeline" panny.gatla@gmail.com < email-body.txt
                    '''
                }
            }
        }
    }
    post {
        always {
            script {
                echo "Cleaning up temporary files..."
                sh 'rm -f aws_creds.json access_key.txt secret_key.txt tfscan-report.txt trivy-report.txt snyk-report.txt sonar-report.txt email-body.txt'
            }
        }
        failure {
            script {
                echo "Pipeline failed. Check logs for details."
            }
        }
    }
}
