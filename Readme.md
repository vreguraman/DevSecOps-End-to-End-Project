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
```
```bash
# Install basic utilities
sudo yum install -y wget git
```

## Install OpenTelemetry and Project Dependencies

### 1. Install Node.js and npm

Node.js is required to run the project, and npm (Node Package Manager) manages the project's dependencies.

### Installation Commands:
```bash
curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo yum install nodejs -y
```

### Verify Installation:
```bash
node -v
npm -v
```
---

![](/Images/nodejs-version.jpg)

---

### 2. Install Project Dependencies

This project uses **OpenTelemetry (OTel)** for distributed tracing and observability. Install the necessary OpenTelemetry libraries:

#### Steps:
1. Navigate to the `src` directory:
   ```bash
   cd src
   ```

2. Install OpenTelemetry libraries:
   ```bash
   npm install @opentelemetry/sdk-trace-node
   ```
   ```bash
   npm install @opentelemetry/exporter-trace-otlp-http
   ```

#### Library Overview:
- **@opentelemetry/sdk-trace-node**: Enables OpenTelemetry tracing in the Node.js application.
- **@opentelemetry/exporter-trace-otlp-http**: Sends trace data from the application to the OpenTelemetry Collector over HTTP using the OTLP protocol.

---

### 3. Update the Collector URL in `server.js`

Configure the application to send trace data to the OpenTelemetry Collector.

#### Steps:
1. Open the `server.js` file:
   ```bash
   vi server.js
   ```

2. Locate and update the following line:
   ```javascript
   url: 'http://<collector-ip>:4318/v1/traces'
   ```

3. Replace `<collector-ip>` with the public IP address of your OpenTelemetry Collector:
   ```javascript
   url: 'http://public-ip:4318/v1/traces'
   ```

4. Save and exit the file.

---

#### 4. Start the Application

Run the application to generate and send telemetry data to the OpenTelemetry Collector.

#### Steps:
1. Start the server:
   ```bash
   node server.js
   ```

2. Access the application at:
   ```
   http://<public-ip>:3000
   ```

---
![](/Images/1.NodeJs.jpg)
---

3. To stop the server:
   ```bash
   Ctrl + C
   ```



## Jenkins Installation

1. Add the Jenkins repository:

```bash
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io-2023.key
```
```bash
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
```
```bash
sudo systemctl start jenkins
```
```bash
sudo systemctl status jenkins
```

### Access Jenkins

Once you access Jenkins at `http://<Jenkins-Instance-IP>:8080`, you will see the following page:

![](/Images/Jenkins/Jenkins-access.jpg)

---

### Retrieve the Initial Admin Password
Copy the file path shown on the page and run the following command in the terminal:
```bash
cat /var/lib/jenkins/secrets/initialAdminPassword
```
### Create Jenkins User
After entering the initial admin password, you will be redirected to a page to set up a Jenkins user account. Fill in the required details as shown below:

![](/Images/Jenkins/Jenkins-create-user.jpg)

---

Provide the necessary details to create your Jenkins account, then  select **Install the suggested plugins** and login to your account.

#### Configure Jenkins for CI/CD with Additional Tools

##### 1. Install Essential Plugins

1. Go to Jenkins Dashboard > Manage Jenkins > Manage Plugins.
   
2. Navigate to the **Available** tab and search for these plugins:
   
   - **Git Plugin**: For integrating Git repositories (pre-installed).

   - **Pipeline Plugin**: For creating declarative or scripted pipelines.
     - Pipeline: Stage View
     - Pipeline: Declarative Agent API

   - **Terraform Plugin**: For running Terraform commands in Jenkins.
   - **HashiCorp Vault**: To pull secrets from Vault (optional, based on your goals).
   - **HashiCorp Vault Pipeline**
   - **SonarQube Scanner Plugin**: For static code analysis integration.
   - **Docker**: To run Docker-related commands within Jenkins.
   - **Snyk Security**: For code and dependency scanning.
   - **Ansible Plugin**: To automate configuration management.
   - **Prometheus**: For Monitoring and Observability
   - **OpenTelemetry Agent Host Metrics Monitor Plugin**

Install plugins as showen below:

---
![](/Images/Jenkins/plugins.jpg)
![](/Images/Jenkins/plugins-1.jpg)
---


## Step 3: Install and Configure Tools

### Install Terraform:

```bash
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
```
```bash
sudo yum install -y terraform
```
```bash
terraform --version
```

### Install TFScan:

```bash
curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
```
```bash
tfsec --version
```
---
![](/Images/Scanners/tfsec-version.jpg)

---
### Install Trivy:

```bash
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh
```

```bash
sudo mv /root/bin/trivy /usr/local/bin/trivy
```
```bash
trivy --version
```
---
![](/Images/Scanners/trivy-version.jpg)

---

### Install Snyk CLI:

```bash
npm install -g snyk
snyk --version
```

### Install and Configure SonarQube:

1. Install Docker:

```bash
sudo yum install docker -y
```
```bash
sudo systemctl enable docker
sudo systemctl start docker
```

2. Run SonarQube Container:

```bash
docker run -d --name sonarcontainer -p 9000:9000 sonarqube:latest
```

3. Access SonarQube:

   - URL: `http://<your-ec2-ip>:9000`.
---

![](/Images/Sonar/9.sonar.jpg)

---

- Login: Username: `admin`, Password: `admin` (you will be prompted to reset the password).

   Provide a new Password : `Example@12345`

---
   ![](/Images/Sonar/10.sonar-update.jpg)

---

#### Add SonarQube Configuration to Jenkins
1. Go to **Manage Jenkins > Configure System**.
2. Scroll to **SonarQube Servers** and click **Add SonarQube**.
3. Enter the following details:
   - **Name**: SonarQube server (or any identifier).
   - **Server URL**: `http://<your-sonarqube-server-ip>:9000`.

---

![](/Images/Sonar/14.sonarserver-add.jpg)

---

Save the configuration.


 **Note:** Store `sonar.projectName`, `sonar.projectKey`, and `Token` in a separate place.

4. Install Sonar Scanner:

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

