pipeline {
    agent any
    environment {
        VAULT_ADDR = credentials('VAULT_ADDR') // HashiCorp Vault address
        VAULT_TOKEN = credentials('VAULT_TOKEN') // HashiCorp Vault token
        PATH = "/opt/sonar-scanner/bin:$PATH" // Adding Sonar Scanner to PATH
    }
    stages {
        // Test Vault Connection
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

        // Terraform Security Scan (TFScan)
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

        // Terraform Plan
        stage('Terraform Plan') {
            steps {
                script {
                    dir('terraform') {
                        sh '''
                        echo "Initializing Terraform..."
                        terraform init

                        echo "Planning Terraform changes..."
                        terraform plan \
                            -var="aws_access_key=$(cat ../access_key.txt)" \
                            -var="aws_secret_key=$(cat ../secret_key.txt)" | tee terraform-plan.txt
                        '''
                    }
                }
            }
        }

        // Terraform Apply
        stage('Terraform Apply') {
            steps {
                input {
                    message "Review the Terraform Plan and approve deployment."
                }
                script {
                    dir('terraform') {
                        sh '''
                        echo "Applying Terraform changes..."
                        terraform apply -auto-approve \
                            -var="aws_access_key=$(cat ../access_key.txt)" \
                            -var="aws_secret_key=$(cat ../secret_key.txt)"
                        '''
                    }
                }
            }
        }

        // Run Node.js Tests
        stage('Run Tests') {
            steps {
                echo "Running npm tests and creating application artifact..."
                dir('src') {
                    sh '''
                        echo "Installing dependencies..."
                        npm install

                        echo "Running tests..."
                        npm test

                        echo "Creating app.tar.gz artifact..."
                        tar -czf app.tar.gz *
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
                            -Dsonar.host.url=http://3.91.226.9:9000/ \
                            -Dsonar.login=sqa_c89317d4b88fd2b1fa3a4c3f09e57cb0e67226d0 | tee sonar-report.txt
                        '''
                    }
                }
            }
        }

        // Docker Build, Scan & Push
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
                    docker build -t $DOCKER_USERNAME/sample-ecommerce-nodejs-app:latest .

                    echo "Scanning Docker image with Trivy..."
                    trivy image --severity HIGH,CRITICAL $DOCKER_USERNAME/sample-ecommerce-nodejs-app:latest | tee trivy-report.txt

                    echo "Logging in to Docker Hub..."
                    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin

                    echo "Pushing Docker image to Docker Hub..."
                    docker push $DOCKER_USERNAME/sample-ecommerce-nodejs-app:latest
                    '''
                }
            }
        }

        // Nexus Integration
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

                    echo "Uploading Node.js application archive to Nexus..."
                    ARTIFACT=src/app.tar.gz
                    tar -czf $ARTIFACT src/

                    curl -u $NEXUS_USERNAME:$NEXUS_PASSWORD \
                        --upload-file $ARTIFACT \
                        $NEXUS_REPO_URL/repository/nodejs-app/

                    echo "Artifact uploaded successfully to Nexus."
                    '''
                }
            }
        }

        // Snyk Security Scan
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
        stage('Deploy Prometheus') {
            steps {
                script {
                    echo "Deploying Prometheus for monitoring..."
                    // Use Docker Compose or Terraform to deploy Prometheus
                    sh '''
                    docker run -d \
                        --name prometheus \
                        -p 9090:9090 \
                        -v /path/to/prometheus.yml:/etc/prometheus/prometheus.yml \
                        prom/prometheus
                    '''
                }
            }
        }

        // Send Reports to Developers
        stage('Send Reports to Developers') {
            steps {
                script {
                    echo "Sending scan reports to developers..."
                    sh '''
                    echo "SonarQube Analysis Results:" > email-body.txt
                    cat sonar-report.txt >> email-body.txt

                    echo "\nTerraform Security Scan Results:" >> email-body.txt
                    cat tfscan-report.txt >> email-body.txt

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
                sh 'rm -f aws_creds.json access_key.txt secret_key.txt tfscan-report.txt terraform-plan.txt trivy-report.txt snyk-report.txt sonar-report.txt email-body.txt'
            }
        }
        failure {
            script {
                echo "Pipeline failed. Check logs for details."
            }
        }
    }
}
