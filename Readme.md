# End-to-End DevSecOps Implementation with Monitoring and Scanning

### Project Overview
This **DevSecOps project** demonstrates the implementation of a secure and automated CI/CD pipeline using industry-leading tools. It combines automation, security, and observability practices to streamline application delivery while maintaining robust security standards.

### Key Objectives:

**Continuous Integration/Delivery (CI/CD):** Automate application builds, testing, and deployments using **Jenkins, Docker,** and **Node.js.**

**Secrets Management:** Securely handle sensitive data and credentials with **HashiCorp Vault.**

**Infrastructure as Code (IaC):** Automate infrastructure provisioning and management using **Terraform** and enhance security with **tfsec.**

**Static and Dependency Analysis:** Use **SonarQube, Snyk,** and **Trivy** for code quality, vulnerability scanning, and container image security.

**Monitoring and Observability:** Implement comprehensive observability using 
**Prometheus, Grafana,** and **OpenTelemetry.**

**Artifact Management:** Manage and distribute application artifacts through **Nexus Repository.**

**Configuration Management:** Automate system configurations with **Ansible.**

**Team Collaboration:** Streamline notifications and updates through Slack integrations.

## Create Jenkins Server

### Create an EC2 Instance:

1. Log in to the AWS Management Console.
2. Navigate to **EC2 > Instances > Launch Instances**.
3. Configure the instance:
   - **AMI**: Amazon Linux 2.
   - **Instance Type**: `t3.xlarge`.
   - **Storage**: 50 GiB gp2.
   - **Security Group**: Allow SSH (port 22) and HTTP (port 8080).
   - Assign a key pair.
4. Launch the instance and wait for it to initialize.

### Commands to Run After Launch:

```bash
# Update the instance
sudo yum update -y

# Install basic utilities
sudo yum install -y wget git
```

## Step 2: Jenkins Installation

1. Add the Jenkins repository:

```bash
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io-2023.key
sudo yum upgrade -y
```

2. Install Java 17:

```bash
amazon-linux-extras enable corretto17
sudo yum install -y java-17-amazon-corretto
java --version
```

3. Install Jenkins:

```bash
sudo yum install jenkins -y
```

4. Enable and start Jenkins:

```bash
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins
```

5. Access Jenkins:
   - Open your browser and navigate to `http://<Jenkins-Instance-IP>:8080`.
   - Unlock Jenkins using the password found at `/var/lib/jenkins/secrets/initialAdminPassword`.
   - Install suggested plugins.
   - Create an admin user.

## Step 3: Install and Configure Tools

### Install Terraform:

```bash
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install -y terraform
terraform --version
```

### Install TFScan:

```bash
curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
tfsec --version
```

### Install Trivy:

```bash
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh
sudo mv /root/bin/trivy /usr/local/bin/trivy
trivy --version
```

### Install Snyk CLI:

```bash
npm install -g snyk
snyk --version
```

### Install and Configure SonarQube:

1. Install Docker:

```bash
sudo yum install docker -y
sudo systemctl enable docker
sudo systemctl start docker
```

2. Run SonarQube Container:

```bash
docker run -d --name sonarcontainer -p 9000:9000 sonarqube:latest
```

3. Access SonarQube:

   - URL: `http://<your-ec2-ip>:9000`.

4. Configure SonarQube in Jenkins:

   - Add the SonarQube plugin.
   - Configure the server under **Manage Jenkins > Configure System**.

5. Install Sonar Scanner:

```bash
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
unzip sonar-scanner-cli-5.0.1.3006-linux.zip
sudo mv sonar-scanner-5.0.1.3006-linux /opt/sonar-scanner
export PATH="/opt/sonar-scanner/bin:$PATH"
sonar-scanner --version
```

### Install Vault:

```bash
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install -y vault
vault server -dev -dev-listen-address="0.0.0.0:8200"
```

### Configure Global Tools in Jenkins

1. **Git**:
   - Go to **Manage Jenkins > Global Tool Configuration**.
   - Under Git, click **Add Git** and set the path to `/usr/bin/git`.

2. **Terraform**:
   - Add Terraform under Terraform installations.
   - Ensure the binary is installed at `/usr/bin/`.

3. **Ansible**:
   - Add Ansible installation and set the path to `/usr/bin/`.

### Create Your First Job to Verify Jenkins

1. Add a build step to verify tool installations:

```bash
echo "Jenkins is configured with additional tools!"
tfsec --version
trivy --version
snyk --version
```

2. Save and build the job.
3. Check the console output to verify the installed versions.

## Step 4: Configure Jenkins for CI/CD

### Install Plugins:

1. Navigate to **Manage Jenkins > Manage Plugins > Available**.
2. Install the following plugins:
   - Git Plugin
   - Pipeline Plugin
   - Terraform Plugin
   - SonarQube Scanner Plugin
   - HashiCorp Vault Plugin
   - Docker Plugin
   - Snyk Security Plugin

## Step 5: Integrate Vault for Secrets Management

1. Enable AWS Secrets Engine:

```bash
vault secrets enable -path=aws aws
```

2. Configure AWS Credentials in Vault:

```bash
vault write aws/config/root \
  access_key=<your-access-key> \
  secret_key=<your-secret-key>
```

3. Retrieve Credentials in Jenkins Pipeline:
   - Use the Vault Plugin to pull secrets dynamically.

## Step 6: Integrate Trivy for Docker Image Scanning

1. Create a Dockerfile:

```dockerfile
FROM node:16-alpine
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

2. Build and Scan the Image:

```bash
docker build -t sample-app .
trivy image sample-app
```

3. Push the Image:

```bash
docker login
# Tag and push
```

## Step 7: Nexus Repository

1. Run Nexus as a Container:

```bash
docker run -d -p 8081:8081 -p 8082:8082 --name nexus sonatype/nexus3
```

2. Configure Nexus:

   - Create a Docker repository.

3. Store Nexus Credentials in Vault:

```bash
vault kv put nexus/credentials username="admin" password="<password>"
```

## Conclusion:

This setup ensures a complete CI/CD pipeline with integrated security tools for DevSecOps practices. Modify and scale as needed for specific project requirements.

