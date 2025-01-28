pipeline {
    agent any
    environment {
        VAULT_ADDR = credentials('VAULT_ADDR') // HashiCorp Vault address
        VAULT_TOKEN = credentials('VAULT_TOKEN') // HashiCorp Vault token
        PATH = "/opt/sonar-scanner/bin:$PATH" // Adding Sonar Scanner to PATH
    }
    stages {
        stage('Test Vault') {
            steps {
                sh '''
                echo "Testing Vault Connection..."
                export VAULT_ADDR="${VAULT_ADDR}"
                export VAULT_TOKEN="${VAULT_TOKEN}"

                vault read -format=json aws/creds/dev-role > aws_creds.json || { echo "Vault read failed"; exit 1; }
                jq -r '.data.access_key' aws_creds.json > access_key.txt || { echo "Failed to extract access key"; exit 1; }
                jq -r '.data.secret_key' aws_creds.json > secret_key.txt || { echo "Failed to extract secret key"; exit 1; }
                '''
            }
        }

        stage('TFScan') {
            steps {
                dir('terraform') {
                    sh '''
                    echo "Running TFScan..."
                    tfsec . > tfscan-report.txt || echo "TFScan completed with warnings."
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh '''
                    echo "Initializing Terraform..."
                    terraform init || { echo "Terraform init failed"; exit 1; }

                    echo "Planning Terraform changes..."
                    terraform plan \
                        -out=tfplan \
                        -var="aws_access_key=$(cat ../access_key.txt)" \
                        -var="aws_secret_key=$(cat ../secret_key.txt)" | tee terraform-plan.txt || { echo "Terraform plan failed"; exit 1; }
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh '''
                    echo "Applying Terraform changes..."
                    terraform apply -auto-approve tfplan || { echo "Terraform apply failed"; exit 1; }
                    '''
                }
            }
        }

        stage('Run Node.js Tests') {
            steps {
                dir('src') {
                    sh '''
                    echo "Cleaning up existing node_modules..."
                    rm -rf node_modules package-lock.json

                    echo "Installing dependencies..."
                    npm install || { echo "npm install failed"; exit 1; }

                    echo "Running tests..."
                    npm test || { echo "Tests failed"; exit 1; }

                    echo "Creating app.tar.gz artifact..."
                    tar -czf app.tar.gz * || { echo "Failed to create artifact"; exit 1; }
                    '''
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                    echo "Running SonarQube Analysis..."
                    sonar-scanner \
                        -Dsonar.projectKey=Project \
                        -Dsonar.sources=src \
                        -Dsonar.host.url=http://15.207.71.232:9000/ \
                        -Dsonar.login=sqa_ab787d1d52b8021ed2c47dc7681c5f17829195e1 || { echo "SonarQube analysis failed"; exit 1; }
                    '''
                }
            }
        }

        stage('Docker Build, Scan & Push') {
            steps {
                dir('src') {
                    sh '''
                    echo "Fetching Docker credentials from Vault..."
                    export VAULT_ADDR="${VAULT_ADDR}"
                    export VAULT_TOKEN="${VAULT_TOKEN}"

                    DOCKER_USERNAME=$(vault kv get -field=username secret/docker) || { echo "Failed to fetch Docker username"; exit 1; }
                    DOCKER_PASSWORD=$(vault kv get -field=password secret/docker) || { echo "Failed to fetch Docker password"; exit 1; }

                    echo "Building Docker image..."
                    docker build -t $DOCKER_USERNAME/sample-ecommerce-nodejs-app:latest . || { echo "Docker build failed"; exit 1; }

                    echo "Scanning Docker image with Trivy..."
                    trivy image --severity HIGH,CRITICAL $DOCKER_USERNAME/sample-ecommerce-nodejs-app:latest | tee trivy-report.txt || { echo "Trivy scan completed with warnings."; }

                    echo "Logging in to Docker Hub..."
                    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin || { echo "Docker login failed"; exit 1; }

                    echo "Pushing Docker image to Docker Hub..."
                    docker push $DOCKER_USERNAME/sample-ecommerce-nodejs-app:latest || { echo "Docker push failed"; exit 1; }
                    '''
                }
            }
        }

        stage('Nexus Integration') {
            steps {
                sh '''
                echo "Fetching Nexus credentials from Vault..."
                export VAULT_ADDR="${VAULT_ADDR}"
                export VAULT_TOKEN="${VAULT_TOKEN}"

                NEXUS_USERNAME=$(vault kv get -field=username nexus/credentials) || { echo "Failed to fetch Nexus username"; exit 1; }
                NEXUS_PASSWORD=$(vault kv get -field=password nexus/credentials) || { echo "Failed to fetch Nexus password"; exit 1; }
                NEXUS_REPO_URL=$(vault kv get -field=repo_url nexus/credentials) || { echo "Failed to fetch Nexus repo URL"; exit 1; }

                echo "Uploading Node.js application archive to Nexus..."
                ARTIFACT=src/app.tar.gz
                tar -czf $ARTIFACT src/ || { echo "Failed to create artifact"; exit 1; }

                curl -u $NEXUS_USERNAME:$NEXUS_PASSWORD \
                    --upload-file $ARTIFACT \
                    $NEXUS_REPO_URL/repository/nodejs-app/ || { echo "Failed to upload artifact to Nexus"; exit 1; }
                '''
            }
        }

        stage('Deploy Prometheus') {
            steps {
                dir('Prometheus') {
                    sh '''
                    echo "Removing existing Prometheus container if it exists..."
                    docker rm -f prometheus || echo "No existing Prometheus container to remove."

                    echo "Deploying Prometheus for monitoring..."
                    docker run -d \
                        --name prometheus \
                        -p 9090:9090 \
                        -v $(pwd)/prometheus.yaml:/etc/prometheus/prometheus.yaml \
                        prom/prometheus || { echo "Failed to deploy Prometheus"; exit 1; }
                    '''
                }
            }
        }

        stage('Send Reports to Developers') {
            steps {
                sh '''
                echo "Consolidating reports..."
                echo "SonarQube Analysis Results:" > email-body.txt
                cat sonar-report.txt >> email-body.txt

                echo "\nTerraform Security Scan Results:" >> email-body.txt
                cat tfscan-report.txt >> email-body.txt

                echo "\nTrivy Docker Image Scan Results:" >> email-body.txt
                cat trivy-report.txt >> email-body.txt

                echo "\nSnyk Vulnerabilities Report:" >> email-body.txt
                cat snyk-report.txt >> email-body.txt

                echo "Emailing reports to developers..."
                mail -s "Security Scan Reports from CI/CD Pipeline" panny.gatla@gmail.com < email-body.txt || { echo "Failed to send email"; exit 1; }
                '''
            }
        }
    }
    post {
        always {
            sh 'rm -f aws_creds.json access_key.txt secret_key.txt tfscan-report.txt terraform-plan.txt trivy-report.txt snyk-report.txt sonar-report.txt email-body.txt'
        }
        failure {
            echo "Pipeline failed. Check logs for details."
        }
    }
}
