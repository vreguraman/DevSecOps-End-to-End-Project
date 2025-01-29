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
                export VAULT_ADDR="${VAULT_ADDR}"
                export VAULT_TOKEN="${VAULT_TOKEN}"

                vault read -format=json aws/creds/dev-role > aws_creds.json || { echo "Vault read failed"; exit 1; }
                jq -r '.data.access_key' aws_creds.json > access_key.txt || { echo "Failed to extract access key"; exit 1; }
                jq -r '.data.secret_key' aws_creds.json > secret_key.txt || { echo "Failed to extract secret key"; exit 1; }
                '''
            }
        }

        // Terraform Security Scan (TFScan)
        stage('TFScan') {
            steps {
                dir('terraform') {
                    sh '''
                    echo "Running TFScan..."
                    tfsec . | tee tfscan-report.txt || echo "TFScan completed with warnings."

                    echo "Verifying TFScan report..."
                    ls -l tfscan-report.txt || { echo "TFScan report not found"; exit 1; }
                    '''
                }
                archiveArtifacts artifacts: 'terraform/tfscan-report.txt', allowEmptyArchive: true
            }
        }

        // Terraform Plan
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

        // Terraform Apply
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

        // Run Node.js Tests
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

        // SonarQube Analysis
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                    echo "Running SonarQube Analysis..."
                    sonar-scanner \
                        -Dsonar.projectKey=Project \
                        -Dsonar.sources=src \
                        -Dsonar.host.url=http://65.2.74.101:9000/ \
                        -Dsonar.login=sqa_ab787d1d52b8021ed2c47dc7681c5f17829195e1 || { echo "SonarQube analysis failed"; exit 1; }
                    '''
                }
            }
        }

        // Docker Build, Scan & Push
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
                    trivy image --format json --severity HIGH,CRITICAL $DOCKER_USERNAME/sample-ecommerce-nodejs-app:latest > trivy-results.json || echo "Trivy scan completed with warnings."

                    echo "Generating Trivy Prometheus Metrics..."
                    node generate-trivy-metrics.js || { echo "Failed to generate Trivy metrics"; exit 1; }

                    echo "Renaming Trivy metrics file for Prometheus..."
                    mv trivy-metrics.prom metrics || { echo "Failed to move Trivy metrics file"; exit 1; }

                    echo "Logging in to Docker Hub..."
                    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin || { echo "Docker login failed"; exit 1; }

                    echo "Pushing Docker image to Docker Hub..."
                    docker push $DOCKER_USERNAME/sample-ecommerce-nodejs-app:latest || { echo "Docker push failed"; exit 1; }
                    '''
                }
                archiveArtifacts artifacts: 'src/metrics', allowEmptyArchive: true
            }
        }

        // Generate TFSec Prometheus Metrics
        stage('Generate TFSec Metrics') {
            steps {
                dir('terraform') {
                    sh '''
                    echo "Running TFSec..."
                    tfsec . --format json > tfsec-results.json || { echo "TFSec scan failed"; exit 1; }

                    echo "Generating TFSec Prometheus Metrics..."
                    node ../src/generate-tfsec-metrics.js || { echo "Failed to generate TFSec metrics"; exit 1; }

                    echo "Renaming TFSec metrics file for Prometheus..."
                    mv tfsec-metrics.prom metrics || { echo "Failed to move TFSec metrics file"; exit 1; }
                    '''
                }
                archiveArtifacts artifacts: 'terraform/metrics', allowEmptyArchive: true
            }
        }

        // Deploy Trivy Metrics Exporter
        stage('Deploy Trivy Metrics Exporter') {
            steps {
                dir('src') {
                    sh '''
                    echo "Starting HTTP server for Trivy metrics..."
                    nohup python3 -m http.server 8085 &
                    '''
                }
            }
        }

        // Deploy TFSec Metrics Exporter
        stage('Deploy TFSec Metrics Exporter') {
            steps {
                dir('terraform') {
                    sh '''
                    echo "Starting HTTP server for TFSec metrics..."
                    nohup python3 -m http.server 8086 &
                    '''
                }
            }
        }

        // Update Prometheus Configuration
        stage('Update Prometheus Configuration') {
            steps {
                dir('Prometheus') {
                    sh '''
                    echo "Adding Trivy and TFSec targets to Prometheus configuration..."
                    cat >> prometheus.yaml <<EOL

  - job_name: 'trivy-metrics'
    static_configs:
      - targets: ['localhost:8085']

  - job_name: 'tfsec-metrics'
    static_configs:
      - targets: ['localhost:8086']

EOL
                    '''
                }
            }
        }

        // Reload Prometheus
        stage('Reload Prometheus') {
            steps {
                sh '''
                echo "Reloading Prometheus to apply new configuration..."
                docker exec prometheus kill -HUP 1 || { echo "Failed to reload Prometheus"; exit 1; }
                '''
            }
        }
    }
}
