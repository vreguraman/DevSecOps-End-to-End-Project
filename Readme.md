# End-to-End DevSecOps Implementation with Monitoring and Scanning



## Table of Content:

[Project Overview](#Project-Overview)

[Key Objectives](#Key-Objectives)

[Architecture](#Architecture)

[Create Jenkins Server](#Create-Jenkins-Server)

[Install OpenTelemetry and Project Dependencies](#Install-OpenTelemetry-and-Project-Dependencies)

[Jenkins Installation](#Jenkins-Installation)

- [Configuring Jenkins for CI-CD with Additional Tools](#Configuring-Jenkins-for-CI-CD-with-Additional-Tools)

- [Troubleshooting Updating Jenkins IP Address](#Troubleshooting-Updating-Jenkins-IP-Address)

[Configure Tools](#Configure-Tools)

- [Install Terraform](#Install-Terraform)
- [Install TFScan](#Install-TFScan)
- [Install Trivy](#Install-Trivy)
- 





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

## Architecture
---
![](/Images/Devsecops.png)

---

### Cost Optimization Decisions

To ensure a cost-effective solution without compromising on functionality, all tools used in this DevSecOps project have been integrated into the Jenkins server. This approach avoids the need for additional servers or infrastructure, reducing operational costs.

#### Rationale
- **Centralized Integration**: Running all tools (e.g. Prometheus, Grafana, Trivy, TFsec, SonarQube, OWASP ZAP) on the same server minimizes resource utilization and eliminates the cost of multiple servers.
- **Simplified Management**: Centralized integration simplifies maintenance, monitoring, and updates for all tools.
- **Efficient Resource Usage**: Using the Jenkins server for multi-purpose tasks optimizes the allocated resources, leveraging idle capacity during pipeline executions.

#### Implementation
- All tools are installed and configured on the Jenkins server instance.
- Prometheus and Grafana are set up to run on separate ports to avoid conflicts.
- Tools like Trivy, TFsec, and OWASP ZAP are containerized or run as CLI tools, leveraging Docker where applicable.


---



## Create Jenkins Server

### Creating an EC2 Instance:

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

sudo yum update -y
```
```bash

sudo yum install git -y
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

### Clone the Project Repository


1. **Clone the Repository**:
   Run the following command to clone the GitHub repository:
   ```bash
   git clone https://github.com/DevopsProjects05/DevSecOps-End-to-End-Project.git
    ```
    ```bash
    cd DevSecOps-End-to-End-Project/src
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



#### 4. Start the Application

Run the application to generate and send telemetry data to the OpenTelemetry Collector.

#### Steps:
1. Executing node server.js in Background
   ```bash
   node server.js &
   ```

2. Access the application at:
   ```
   http://<public-ip>:3000
   ```
### Application Successfully Running on Port 3000
---
![](/Images/1.NodeJs.jpg)
---

3. To stop the server: (if you run without &)(optional)
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

### Command Line Execution Result
---
![](/Images/java-version.jpg)

---

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
### Terminal Display of Running Commands
---
![](/Images/Jenkins-status.jpg)

---

### Access Jenkins

Once you access Jenkins at `http://<Jenkins-Instance-IP>:8080`, you will see the following page:

### Jenkins Server is Up and Running on Port 8080
---
![](/Images/Jenkins/Jenkins-access.jpg)

---

### Retrieving the Initial Admin Password
Run the following command in the terminal:
```bash
cat /var/lib/jenkins/secrets/initialAdminPassword
```
### Terminal Output Screenshot
---
![](/Images/jennkins-credential.jpg)

---
Copy the output(initial admin password) and paste in **jenkins server** to continue

After entering the initial admin password, you will be redirected to a page to install pluggins as shown below:

---
![](/Images/jenkisn-suggested-pluggins.jpg)

---

 Select **Install suggested plugins** to install necessary plugins

### You will see the plugins are getting installed once you click on suggested plugins:
 ---
 ![](/Images/jenkins-install-plugins-started.jpg)

 ---

### Create Jenkins User
After installing plugins, you will be redirected to a page to set up a Jenkins user account. Fill in the required details:

### Here’s the Output You Should See

---
![](/Images/Jenkins/Jenkins-create-user.jpg)

---

Provide the necessary details to create your **Jenkins account.**

### Once the plugins installed you will see jenkins url as shown below:

---
![](/Images/jenkins-url.jpg)


**Save and Finish to start using Jenkins**

---

### Configuring Jenkins for CI-CD with Additional Tools

#### 1. Install Essential Plugins

1. Go to Jenkins **Dashboard** > **Manage Jenkins** > **Plugins**.
   
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

Install plugins as shown below:

---
![](/Images/Jenkins/plugins.jpg)
![](/Images/Jenkins/plugins-1.jpg)
---

### Restarting Jenkins

After installing plugins or making configuration changes, you may need to restart your Jenkins server. You can do this in one of the following ways:

1. **Using the systemctl command** (Linux systems):
   ```bash
   systemctl restart jenkins
    ```
2. **Using the Jenkins UI:**
If you're on the plugin installation page, check the *"Restart Jenkins when installation is complete and no jobs are running"* box at the bottom of the page.
Alternatively, navigate to the following URL in your browser to restart Jenkins:
```bash
http://<public-ip>:8080/restart
```
Replace <public-ip> with your Jenkins server's public IP address.
Ensure Jenkins has fully restarted before proceeding with further tasks.


### Troubleshooting: Updating Jenkins IP Address

If you stop the Jenkins instance and start it again, you may experience slowness when accessing Jenkins or making changes. This happens because the Jenkins IP address changes after restarting the instance.

To resolve this issue, follow these steps to update the latest IP address in Jenkins:

1. Open the Jenkins configuration file:
   ```bash
   vi /var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml
   ```
2. Update the `Jenkins URL` field with the new public IP address of the instance.

3. Save the changes and restart Jenkins:
   ```bash
   systemctl restart jenkins
   ```



## Configure Tools

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

### Command Output Snapshot
---
![](/Images/terraform/succesfull-installation%20.jpg)

---


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

### Troubleshooting Trivy Installation

If you encounter an issue where `trivy` is not found after installation, follow these steps to locate and move it manually:

### Issue
You may see the following error when trying to move `trivy`:
```bash
mv: cannot stat '/root/bin/trivy': No such file or directory
```
### Solution

### Find where `trivy` was installed by running:
```sh
find / -name trivy 2>/dev/null
```
This should return a path similar to:
```sh
/root/DevSecOps-End-to-End-Project/src/bin/trivy
```

### Move `trivy` to `/usr/local/bin/` for system-wide access:
```sh
mv /root/DevSecOps-End-to-End-Project/src/bin/trivy /usr/local/bin/trivy
```

### Verify the installation:
```sh
trivy --version
```
If the installation was successful, this should output the installed Trivy version.

### Command Execution Status
---
![](/Images/Scanners/trivy-version.jpg)

---

### Install Snyk CLI:

```bash
npm install -g snyk
```
```bash
snyk --version
```

### Terminal Session Output
---
![](/Images/snyk-version.jpg)

---

### Install Ansible

### Install `ansible` using `pip`:
```sh
yum install pip -y  
```
```bash
pip install ansible
```
```bash
ansible --version
```


### Execution Log in Terminal
---
![](/Images/ansible-version.jpg)

---



### Configuring Global Tools in Jenkins

1. **Git**:
   - Go to **Manage Jenkins > Global Tool Configuration**.
   - Under Git, click **Add Git** and set the path to `/usr/bin/git`.


---
![](/Images/git-path.jpg)

---
Refer to the above screenshot to configure **Terraform & Ansible.**

**Note**: Ensure that you uncheck `Install automatically.`

2. **Terraform**:
   - Add Terraform under Terraform installations.
   - Ensure the binary is installed at `/usr/bin/`.

3. **Ansible**:
   - Add Ansible installation and set the path to `/usr/bin/`.

Click on `Apply & Save` to continue.

---

### Create Your First Job to Verify Jenkins

Follow these steps to create a Freestyle Project in Jenkins to verify that Jenkins is properly configured with additional tools:

1. **Create a Freestyle Project:**
   - Go to the **Jenkins Dashboard** and click on **New Item**.
   - Enter a name for your job (e.g. `Verify-Jenkins`) and select Freestyle Project.

2. **Configure the Build Steps:**
   - Scroll down to the **Build** section and click **Add build step**.
   - Select **Execute shell** and add the following commands:
     ```bash
     echo "Jenkins is configured with additional tools!"
     tfsec --version
     trivy --version
     snyk --version
     ```

3. **Save and Build:**
   - Click **Save** to create the job.
   - Go back to the project dashboard and click **Build Now** to execute the job.

4. **Verify the Output:**
   - Navigate to the **Console Output** of the build to verify that the commands ran successfully and the versions of `tfsec`, `trivy`, and `snyk` are displayed.


2. Save and build the job.


### Check the console output to verify the installed versions.

---

![](/Images/version-verification.jpg)

---
## Deploying SonarQube as a Container

### Steps to Install and Configure SonarQube:

1. Install Docker:

```bash
sudo yum install docker -y
```
```bash
sudo systemctl enable docker
sudo systemctl start docker
```

2. Check Docker Status:
```bash
sudo systemctl status docker
```
### Terminal View of Executed Commands

---
![](/Images/docker-status.jpg)

---

###  Run the SonarQube Container

Execute the following command to pull and run the latest SonarQube container in detached mode (`-d`), mapping it to port **9000**:

```sh
docker run -d --name sonarcontainer -p 9000:9000 sonarqube:latest
```

- `-d` → Runs the container in detached mode (in the background).  
- `--name sonarcontainer` → Assigns a custom name (`sonarcontainer`) to the container for easy management.  
- `-p 9000:9000` → Maps port **9000** of the container to port **9000** of the host machine.  
- `sonarqube:latest` → Uses the latest available SonarQube image from Docker Hub.

Verify if the container is running using:

```sh
docker ps
```
### Command Execution Status

---

![](/Images/sonarqube-container.jpg)

---


### Sonarqube Successfully Running on Port 9000

Once the container is running, access the SonarQube web interface:

- Open a browser and navigate to:  
  ```bash
  http://<your-ec2-ip>:9000
   ```

### Console Output After Command Execution

---

![](/Images/Sonar/9.sonar.jpg)

---

### Default Credentials
- **Username:** `admin`  
- **Password:** `admin`  

Upon first login, you will be prompted to change the default password for security.

   Provide a new Password : `Example@12345` (Suggested)

---
   ![](/Images/Sonar/10.sonar-update.jpg)

---

### Adding SonarQube Configuration to Jenkins
1. Go to **Manage Jenkins > System**.
2. Scroll to **SonarQube Servers** and click **Add SonarQube**.
3. Enter the following details:
   - **Name**: SonarQube server (or any identifier).
   - **Server URL**: `http://<your-sonarqube-server-ip>:9000`.

---

![](/Images/Sonar/14.sonarserver-add.jpg)

---

**Save the configuration.**


 ### **Important Note:**  
Before proceeding, make sure to securely store the following values, as they will be required later:  
- `sonar.projectName`  
- `sonar.projectKey`  
- `Token`  

### Create a New Project in SonarQube

1. Log in to SonarQube.
2. Click **Create a local project** and provide the project name (e.g. `Sample E-Commerce Project`).
3. Branch should be `main` then `Next`
4. Select **Use the global setting**, then click **Create Project**.

### Generate an Authentication Token
1. Navigate to **My Account > Security**.
2. Under **Generate Tokens**, enter a token name (e.g. `Sample Project Token`).
3. Select **Global Analysis** from the dropdown.
4. Click **Generate** and copy the token (save it securely; it will not be displayed again).

### Install Sonar Scanner
1. Create a directory for Sonar Scanner:
   ```bash
   mkdir -p /downloads/sonarqube
   cd /downloads/sonarqube
   ```
2. Download the latest Sonar Scanner:
   ```bash
   wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
   unzip sonar-scanner-cli-5.0.1.3006-linux.zip
   ```
   ```bash
   sudo mv sonar-scanner-5.0.1.3006-linux /opt/sonar-scanner
   ```
3. Add Sonar Scanner to the PATH:
   ```bash
   vi ~/.bashrc
   ```
   ```bash
   export PATH="/opt/sonar-scanner/bin:$PATH"
   ```
  Add the path as shown below:

  ---

![](/Images/Sonar/sonar-path.jpg)

---

   ```bash
   source ~/.bashrc
   ```
   Verify the installation:
   ```bash
   sonar-scanner --version
   ```
### Execution Log in Terminal
---
![](/Images/sonarqube-version.jpg)

---


 Ensure `SonarQube Scanner` plugin is installed.
#### Analyze Code with Sonar Scanner
1. Navigate to the `src` directory.
   ```bash
   cd src
   ```
2. Create and edit the `sonar-project.properties` file:
   ```bash
   vi sonar-project.properties           
   ```
   Add the following content:
   ```
   # Unique project identifier in SonarQube
   sonar.projectKey=Sample-E-Commerce-Project     

   # Display name of the project
   sonar.projectName=Sample E-Commerce Project 

   # Directory where source code is located (relative to this file)
   sonar.sources=.

   # URL of the SonarQube server
   sonar.host.url=http://<your-sonarqube-server-ip>:9000    

   # Authentication token from SonarQube
   sonar.login=<your-authentication-token>    
   ```
   **Important**
   Ensure that you **replace Sonarqube server IP & token** before scanning

3. Run the Sonar Scanner:
   ```bash
   /opt/sonar-scanner/bin/sonar-scanner
   ```

  ### You will see below result after running sonar scanner:

  ---

  ![](/Images/Sonar/12.sonar-success.jpg)
   
   ---

1. For debugging issues, use:
   ```bash
   /opt/sonar-scanner/bin/sonar-scanner -X
   ```

   If you get an error:
   - Ensure your SonarQube server IP is configured in Jenkins.
   - Verify that your project key and authentication token are correct.
   - Make sure you are in the correct path (`/src`).
   - Confirm that the `sonar-project.properties` file exists in the `/src` directory.

### View Results in SonarQube
1. Open your browser and navigate to `http://<your-sonarqube-server-ip>:9000`.
2. Log in to the SonarQube dashboard.
3. Locate the project (e.g., `Sample E-Commerce Project`).
4. View analysis results, including security issues, reliability, maintainability, and code coverage.

### The following output will be visible upon successful execution:

---

![](/Images/Sonar/Sonarqube-passed.jpg)

---

## Installing HashiCorp Vault for Secure Secrets Management  

HashiCorp Vault is used to securely manage AWS credentials and other sensitive secrets, including:  

- **Nexus Credentials**  
- **Docker Hub Credentials**  
- **Snyk Token**  
- **SonarQube Token**  
- **Other Confidential Secrets**  

By integrating Vault, we ensure that secrets are securely stored and dynamically accessed, reducing security risks.

1. **Why Vault?**
   HashiCorp Vault is used to:
   - Securely store and manage sensitive information.
   - Dynamically generate AWS credentials for Terraform.

2. **Steps for Vault Integration**:
   Before proceeding, we need to integrate Vault:

   - **Install Vault**:
     ```bash
     sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
     sudo yum install -y vault
     ```

   - **Start Vault in Development Mode**:
     ```bash
     vault server -dev -dev-listen-address="0.0.0.0:8200"
     ```
   **Note:** Copy the Root token to login into Hashicorp vault server
   - **Run Vault in Background (Optional)**:
     ```bash
     vault server -dev -dev-listen-address="0.0.0.0:8200" &
     ```

3. **Access Vault Server**

      ```bash
      http://<public-ip>:8200
      ```

 ### Vault is Up and Running at IP:8200
   ---
   ![](/Images/vault-login.jpg)

   ---

Enter the **Root token** to login.

## Integrate Vault for Secrets Management

### Open a Separate Terminal for Configuration

1. Right-click on the tab of your terminal session.
2. From the context menu, select the option **'Duplicate Session'**.
3. This will open a new tab with a duplicate of your current terminal session, which you can use to continue the setup process.
4. After entering into the duplicate terminal, get sudo access and follow the steps below..

---

### Step-by-Step Configuration

1. **Set Vault's Environment Variables**:
   ```bash
   export VAULT_ADDR=http://0.0.0.0:8200
   ```
   ```bash
   export VAULT_TOKEN=<your-root-token>
   ```
2. **Enable the AWS Secrets Engine**:
   ```bash
   vault secrets enable -path=aws aws
   ```
3. **Configure AWS Credentials in Vault**:
   ```bash
   vault write aws/config/root \
    access_key=<your-Access-key> \
    secret_key=<your-Secret-key>
   ```
4. Create a Vault Role for AWS Credentials

```bash
vault write aws/roles/dev-role \
 credential_type=iam_user \
 policy_document=-<<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": ["ec2:*", "sts:GetCallerIdentity"],
            "Resource": "*"
        }
    ]
}
EOF
```
### Testing HashiCorp Vault in a Freestyle Jenkins Job

To verify Vault integration with Jenkins, follow these steps:

#### Add Vault URL to Jenkins
1. Go to **Manage Jenkins > System > Vault Plugin**.
2. Enter the Vault URL: `http://<public-ip>:8200`.
3. Click **Apply** and **Save**.

#### Steps to Create and Configure the Jenkins Job
1. **Create a New Freestyle Job**:
   - Go to **Jenkins Dashboard > New Item**.
   - Enter a job name (e.g., `Test-Vault`).
   - Select **Freestyle Project** and click **OK**.

2. **Add Build Step**:
   - Under **Build**, click on **Add Build Step**.
   - Select **Execute Shell**.

3. **Add the Following Shell Script**:
   ```bash
   # Export Vault address and token
   export VAULT_ADDR=http://<public-ip>:8200
   export VAULT_TOKEN=<YOUR_VAULT_TOKEN>

   echo "Testing Vault Connection..."
   # Read AWS credentials from Vault
   vault read -format=json aws/creds/dev-role > aws_creds.json
   jq -r '.data.access_key' aws_creds.json
   jq -r '.data.secret_key' aws_creds.json
   ```

4. **Run the Job:**

- Click Save and then Build Now.

5. **Verify the Output:**

- Check the Console Output to ensure:
- Vault connection is successful.
- The AWS credentials are retrieved and displayed below.

---
![](/Images/vault-job-success.jpg)

---

### Integrating `Tfsec` to Enhance Terraform Security Scanning

To scan Terraform files for potential security vulnerabilities using `tfsec`, follow these steps:

1. **Ensure a Terraform File Exists**:
   - Confirm that the required Terraform file (`.tf`) is available in the directory.

2. **Navigate to the Terraform Directory**:
   ```bash
   cd /root/DevSecOps-End-to-End-Project/terraform
   ```
3. **Run tfsec**:
- Execute the following command to perform the security scan:

   ```bash
   tfsec .
   ```
1. **Analyze the Output**:

- Review the results of the scan for any identified security issues and resolve them as needed.

---
![](/Images/tfsec-ouput.jpg)

---



## Integrating `Trivy` to Enhance Container Image Scanning

### Install Docker
If Docker is not already installed, use the following command to install Docker:
```bash
sudo yum install docker -y
```

### Steps to Integrate Trivy for Image Scanning

1. **Create the Dockerfile**:
   - The Dockerfile is already available in the `/Docker` directory. Below is an example of the Dockerfile:
   ```dockerfile
   FROM node:16-alpine
   WORKDIR /app
   COPY package.json .
   RUN npm install
   COPY . .
   EXPOSE 3000
   CMD ["npm", "start"]
   ```
   - Save this file in the root directory of your project.

2. **Build the Docker Image**:
   - Navigate to your project directory and run:
   ```bash
   docker build -t sample-ecommerce-app .
   ```

### What You Can Expect After Running the Command
---
![](/Images/docker-image-build.jpg)

---

3. **Run the Docker Container (Optional for Testing)**:
   - To test the container, run:
   ```bash
   docker run -p 3000:3000 sample-ecommerce-app
   ```
 - Access the application in your browser at:
   ```
   http://<your-server-ip>:3000
   ```

   ![](/Images/1.NodeJs.jpg)

4. **Scan the Image with Trivy**:
   - Use Trivy to scan the Docker image for vulnerabilities:
   ```bash
   trivy image sample-ecommerce-app
   ```

5. **Analyze the Output**:
   - Review the vulnerabilities identified in the scan and address them by updating dependencies or modifying the Dockerfile.

---

![](/Images/trivy-succes.jpg)
---

6. **Clean Up**:
   - Stop and remove the running container (if applicable):
   ```bash
   docker stop <container-id>
   docker rm <container-id>
   ```

### Push Docker Image to a Container Registry

To store and share your Docker image, push it to a container registry like Docker Hub, Amazon ECR, or Azure ACR.

1. **Log in to Docker Hub**:
   ```bash
   docker login -u <your-dockerhub-username> -p <your-dockerhub-password>
   ```

2. **Tag the Docker Image**:
   ```bash
   docker tag sample-ecommerce-app <your-registry>/sample-ecommerce-app:nodejs
   ```

3. **Push the Image to the Registry**:
   ```bash
   docker push <your-registry>/sample-ecommerce-app:nodejs
   ```
4. Verify on Docker Hub.
   
### After running the steps, the output will appear as follows:
---

![](/Images/dockerhub-success.jpg)

---


## Deploying Nexus Repository as a Docker Container

### Run the Nexus Container
To deploy the Nexus Repository as a container, run the following command:
```bash
docker run -d -p 8081:8081 --name nexus sonatype/nexus3
```

### Access Nexus
1. Open your browser and navigate to:
   ```
   http://<your-host-ip>:8081
   ```
 ---
   ![](/Images/nexus-launch.jpg)

   ---
2. Retrieve the Admin Password:
   - Run the following command to get the admin password:
     ```bash
     docker exec -it nexus cat /nexus-data/admin.password
     ```
   **Click on the sign icon in the top-right corner.**
3. The default credentials are:
   - **Username**: `admin`
   - **Password**: Retrived Password.
---

![](/Images/nexus-credentials.jpg)

---

4. Update your password after the first login as shown below
---
![](/Images/nexus-credentials-update.jpg)
---
1. Select: Enable anonymous access → Click Next → Finish the setup.

### Configure Nexus

#### Create a Docker Repository as shown below

![](/Images/nexus-config.jpg)

1. Navigate to Nexus Repositories:
   - Click on the "Settings" (gear icon) → "Repositories".

2. Create a New Repository:
   - Click on "Create repository".
   - Choose **"docker (hosted)"** for pushing Docker images.

3. Configure the Repository:
   - **Name**: Enter a name for the repository (e.g., `docker-hosted`).
   - Allow anonymous Docker pull: Enable this option if needed.

4. Click on `create repository`.


## Securely Managing Credentials with HashiCorp Vault

### Storing and Accessing Credentials in Vault

#### 1. Enable the KV Secrets Engine
Ensure the KV secrets engine is enabled in Vault to securely store credentials.
```bash
vault secrets enable -path=nexus kv
```


#### 2. Store Nexus Credentials
Use the `vault kv put` command to securely store your Nexus credentials and repository URL or token:
```bash
vault kv put nexus/credentials \
    username="your-nexus-username" \
    password="your-nexus-password" \
    repo_url=https://nexus.example.com
```
Replace `https://nexus.example.com` with your Nexus repository URL.

#### How to Find Your Nexus Repository URL

- Log in to your Nexus Repository.
- Navigate to Nexus Repositories:
   - Click on the "Settings" (gear icon) → "Repositories".
- Identify the repository that you previously created, click on it.
- Copy the repository URL displayed under the repository details as shown below.
---
![](/Images/nexus-url.jpg)

---

#### 3. Retrieve Nexus Credentials
To fetch the stored credentials:
- Retrieve all stored credentials:
  ```bash
  vault kv get nexus/credentials
  ```

---

#### Store Docker Credentials:
```bash
vault kv put secret/docker username="<user-name>" password="<your-password>"
```

#### Retrieve Docker Credentials:
- Fetch the username:
  ```bash
  vault kv get -field=username secret/docker
  ```
- Fetch the password:
  ```bash
  vault kv get -field=password secret/docker
  ```

---

### Storing Snyk Token

### 1. Sign In to Snyk
- Go to the [Snyk login page](https://snyk.io/).
- Log in using your preferred method (e.g., email/password, GitHub, GitLab, or SSO).

### 2. Navigate to Your API Token
- Click on your Organization bottom-left corner.
- Select **Account Settings** from the dropdown menu.
- Locate Auth token and click on `click to show` to view token.
- Below is the screenshot for your reference
---
![](/Images/snyk-token.jpg)

---

### 3. Enable the KV Secrets Engine (if not already enabled)
```bash
vault secrets enable -path=snyk kv
```
- `-path=snyk`: Specifies a custom path for storing Snyk-related secrets. You can customize this path as needed.

### 4. Store the Snyk Token
```bash
vault kv put snyk/token api_token="your-snyk-token"
```
Replace `your-snyk-token` with your actual Snyk token.

### 5. Retrieve the Snyk Token
To fetch the token programmatically or manually:
```bash
vault kv get -field=api_token snyk/token
```
The `-field=api_token` flag extracts only the token value.

---

## Monitoring with Prometheus and Grafana

### Add Prometheus to Node.js Application
1. Install Prometheus client:
   ```bash
   npm install prom-client
   ```
2. Expose metrics in `server.js`. (included expose metrics in server.js)

#### Next Steps
1. Test this updated `server.js`:
   ```bash
   node server.js 
   ```
If you want to run it in the background, use:

   ```bash
   node server.js &
   ```      


   Access **Prometheus metrics** at: `http://<public-ip>:3000/metrics` to ensure it is working as expected.

### You will see the metrics once you access the URL:

---

![](/Images/metrics.jpg)

---

### Open a Separate Terminal for Prometheus Setup 

**Important** : Jump to **Install and Configure Prometheus** if you run node js in Background

1. **Right-click** on the tab of your terminal session.
2. From the context menu, select the option **'Duplicate Session'**.
3. This will open a new tab with a duplicate of your current terminal session, which you can use to continue the setup process.
4. After entering into the duplicate terminal, get sudo access and navigate to:
   ```bash
   cd DevSecOps-End-to-End-Project/src
   ```



### Install and Configure Prometheus
1. Download and run Prometheus:
   ```bash
   wget https://github.com/prometheus/prometheus/releases/download/v2.47.0/prometheus-2.47.0.linux-amd64.tar.gz
   ```
   ```bash
   tar -xvzf prometheus-2.47.0.linux-amd64.tar.gz
   ```
   ```bash
   cd prometheus-2.47.0.linux-amd64
   ```
   

### Configure Prometheus

1. **Find the `prometheus.yml` File** 
Ensure the `prometheus.yml` configuration file exists in the current directory

2. **Verify the file**
   ```bash
   ls
   ```
2. **Edit the File**
   ```bash
   vi prometheus.yml
   ```

1. Locate the `scrape_configs:` section.
2. Find `- job_name:`.
3. Replace the job name with `"nodejs-app"`.

```yaml
scrape_configs:
  - job_name: "nodejs-app"
    # Additional configuration here
```
4. Save the file in the same directory as Prometheus.

#### Run Prometheus

- To start the Prometheus server, use the following command:

  ```bash
   ./prometheus --config.file=prometheus.yml
   ```
- If you want to run it in the background, use:

   ```bash
   ./prometheus --config.file=prometheus.yml &
   ```

- Open the Prometheus server in your browser.
   ```bash
   http://Public-ip:9090/
   ```
### Prometheus Successfully Running on Port 9090
---
![](/Images/prometheus-dashboard.jpg)

---

- Navigate to the Status tab.

- Choose Targets from the dropdown.


### Below is the result you can expect:

---

![](/Images/prometheus.jpg)

---

### Open a Separate Terminal for Grafana Setup

**Important** : Jump to **Install and Configure Grafana** if you run `Prometheus` in Background

1. **Right-click** on the tab of your terminal session.
2. From the context menu, select the option **'Duplicate Session'**.
3. This will open a new tab with a duplicate of your current terminal session, which you can use to continue the setup process.
4. After entering into the duplicate terminal, get sudo access and navigate to:
   ```bash
   cd DevSecOps-End-to-End-Project/src
   ```

### Install and Configure Grafana
1. Download and run Grafana:
   ```bash
   wget https://dl.grafana.com/oss/release/grafana-10.0.0.linux-amd64.tar.gz
   ```
   ```bash
   tar -xvzf grafana-10.0.0.linux-amd64.tar.gz
   ```
   ```bash
   cd grafana-10.0.0/bin
   ```
   Run Grafana

   ```bash
   ./grafana-server
   ```

### Resolve Port Conflict with Grafana

You may encounter the following error because Grafana tries to access port 3000, which is already occupied by Node.js. To resolve this, we need to change the Grafana port to 3001.

#### Steps to Change the Grafana Port

1.Find the `defaults.ini` file by running the following command:
```bash
find / -name defaults.ini 2>/dev/null
```

2.Navigate to the `conf` directory:
```bash
cd ../conf
```

3.Edit the `defaults.ini` file:
```bash
vi defaults.ini
```
4.Add the following line to set the `Grafana port` to 3001:
```bash
http_port = 3001
```
---

![](/Images/port-change.jpg)

--- 

#### Restart Grafana
Now, navigate back to the Grafana execution folder:

```bash
cd /root/DevSecOps-End-to-End-Project/src/prometheus-2.47.0.linux-amd64/grafana-10.0.0/bin
```
Run Grafana again:
```bash
./grafana-server  
```

   Access Grafana: `http://<server-ip>:3001`.

### You will see the below screen:

   ---
![](/Images/grafana-1.jpg)

   ---

Login using default credentials:

Username: admin

Password: admin

Change the password upon first login.


### Once you login you will see Grafana Dashboard as shown below:
---

![](/Images/grafana-dashboard.jpg)

---

#### Configure Prometheus as a Data Source
Add Prometheus as a data source.
 -  In Grafana, go to Configuration > **Data Sources**
 -  Click **Add data source.**

### The following page will appear:

   ---
   ![](/images/grafana-datasource.jpg)

   ---
   Select **`Prometheus`** from the list
   Enter Prometheus URL as shown below:

---
   ![](/Images/grafana-prometheus.jpg)

---

#### Import a Pre-Built Dashboard
Go to Dashboards > toggle menu > dashboards > new> Import in Grafana.


---
![](/Images/grafana-nodejs-id.jpg)

---

Enter a **Dashboard ID:**

Node js Dashboard: **11159** and click on load and select **`Prometheus`** in prometheus

#### The interface will appear as follows:

---
![](/Images/grafana-load-nodejs.jpg)

---

click on **import.**

### Here is the NodeJS Application Dashboard result after the process completes

---
![](/Images/Grafana-App-Dashboard.jpg)

---

## Bringing Visibility to Trivy & TFsec: Security Insights with Prometheus & Grafana

Trivy and TFsec are powerful security scanning tools for containers and Infrastructure as Code (IaC), but they lack a built-in graphical interface for visualizing vulnerabilities. This project bridges that gap by integrating Trivy and TFsec with Prometheus and Grafana, transforming raw security scan data into insightful, real-time dashboards for better monitoring and decision-making. 🚀

## Trivy Integration

### Scan Docker Image with Trivy
```sh
trivy image --format json --severity HIGH,CRITICAL <image-name> > trivy-results.json
```

After running this command, a `trivy-results.json` file will be created.

###  Generate Prometheus Metrics from Trivy Results
Create a file `generate-trivy-metrics.js` and add the following content:

```bash
vi generate-trivy-metrics.js
```
```javascript
const fs = require('fs');

try {
    console.log('Reading Trivy results...');
    const trivyResults = JSON.parse(fs.readFileSync('trivy-results.json', 'utf8'));

    console.log('Generating Prometheus metrics...');
    const metrics = [];
    trivyResults.Results.forEach((result) => {
        result.Vulnerabilities.forEach((vuln) => {
            metrics.push(`# HELP trivy_vulnerabilities Trivy vulnerability scan results`);
            metrics.push(`# TYPE trivy_vulnerabilities gauge`);
            metrics.push(`trivy_vulnerabilities{image="${result.Target}",severity="${vuln.Severity}",id="${vuln.VulnerabilityID}"} 1`);
        });
    });

    console.log('Writing metrics to trivy-metrics.prom...');
    fs.writeFileSync('trivy-metrics.prom', metrics.join('\n'));
    console.log('Metrics file trivy-metrics.prom created successfully.');
} catch (error) {
    console.error('Error:', error.message);
}
```
Run the script:
```sh
node generate-trivy-metrics.js
```
A `trivy-metrics.prom` file will be created.

Move the file to the `metrics` directory:
```sh
mv trivy-metrics.prom metrics
```

Start a simple HTTP server to expose metrics on **port 8085**:
```sh
python3 -m http.server 8085
```

### Add Trivy to Prometheus Configuration
Edit `prometheus.yaml`:
```yaml
scrape_configs:
  - job_name: "trivy"
    static_configs:
      - targets: ["<your-server-ip>:8085"]
```
Reload Prometheus to apply changes.

### Visualize Trivy Metrics in Grafana
1. Open Grafana (`http://<your-server-ip>:3000`)
2. Navigate to **Configuration → Data Sources**
3. Add **Prometheus** as a data source with URL `http://localhost:9090`
4. Create a new dashboard:
   - Add a new panel
   - Use PromQL query:
     ```
     trivy_vulnerabilities
     ```
   - Choose a visualization type (Table, Gauge, Time Series, etc.)
   - Save the dashboard
---

## TFsec Integration

###  Run TFsec and Generate JSON Output
```sh
cd /root/DevSecOps-End-to-End-Project/terraform
tfsec . --format=json > tfsec-results.json
```

###  Generate Prometheus Metrics from TFsec Results
Create a file `generate-tfsec-metrics.js` and add the following content:

```bash
vi generate-tfsec-metrics.js
```

```javascript
const fs = require('fs');

console.log("Reading TFsec results...");
const tfsecResults = JSON.parse(fs.readFileSync('tfsec-results.json', 'utf8'));

console.log("Generating Prometheus metrics...");
let metrics = "# HELP tfsec_vulnerabilities TFsec vulnerability scan results\n";
metrics += "# TYPE tfsec_vulnerabilities gauge\n";

tfsecResults.results.forEach(result => {
    metrics += `tfsec_vulnerabilities{severity="${result.severity}",rule_id="${result.rule_id}",description="${result.description.replace(/"/g, '\\"')}"} 1\n`;
});

console.log("Writing metrics to tfsec-metrics.prom...");
fs.writeFileSync('tfsec-metrics.prom', metrics);

console.log("Metrics file tfsec-metrics.prom created successfully.");
```
Run the script:
```sh
node generate-tfsec-metrics.js
```
A `tfsec-metrics.prom` file will be created.

Move the file to the `metrics` directory:
```sh
mv tfsec-metrics.prom metrics
```

Start a simple HTTP server to expose metrics  on **port 8086**:
```sh
python3 -m http.server 8086
```

### Add TFsec to Prometheus Configuration
Edit `prometheus.yaml`:
```yaml
scrape_configs:
  - job_name: "tfsec"
    static_configs:
      - targets: ["<your-server-ip>:8086"]
```
Reload Prometheus to apply changes.

### Step 4: Visualize TFsec Metrics in Grafana
1. Open Grafana (`http://<your-server-ip>:3000`)
2. Navigate to **Configuration → Data Sources**
3. Add **Prometheus** as a data source with URL `http://localhost:9090`
4. Create a new dashboard:
   - Add a new panel
   - Use PromQL query:
     ```
     tfsec_vulnerabilities
     ```
   - Choose a visualization type (Table, Gauge, Time Series, etc.)
   - Save the dashboard

Now, you can monitor security vulnerabilities detected by Trivy and TFsec in Grafana!

----


## OpenTelemetry Setup and Configuration
Since we have already installed the OpenTelemetry-related dependencies and updated the `collectorUrl` in `server.js` earlier, let's proceed with downloading the OpenTelemetry Collector.

 ### Download and Set Up OpenTelemetry Collector
The OpenTelemetry Collector processes and exports telemetry data from the application to a desired backend.

#### **Download the Collector**
```bash
wget https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.83.0/otelcol-contrib_0.83.0_linux_amd64.tar.gz
```
- **Why:** Downloads the OpenTelemetry Collector binary (Contrib version).
- **Result:** A `.tar.gz` file is downloaded.

#### **Extract the File**
```bash
tar -xvf otelcol-contrib_0.83.0_linux_amd64.tar.gz
```

#### Move the Binary to a System-Wide Location
```bash
sudo mv otelcol-contrib /usr/local/bin/otelcol
```
- **Why:** Places the binary in a directory included in your system’s PATH, so you can run it from anywhere.
- **Result:** The Collector is installed and ready to use.

#### Verify Installation
```bash
otelcol --version
```

![](/Images/otel-version.jpg)
- **Why:** Confirms that the Collector is installed correctly.
- **Result:** Displays the version of the Collector.

---

### Run the OpenTelemetry Collector
Ensure the `otel-collector-config.yaml` file is present in your directory. Run the Collector with the configuration file.
```bash
otelcol --config otel-collector-config.yaml
```

![](/Images/otel-success.jpg)
- **Why:** Starts the Collector with the specified configuration.
  - Receives traces from your application.
  - Processes and exports traces to the desired backend (e.g., logging, Jaeger).
- **Result:** The Collector is running and ready to process telemetry data.

Check the Collector logs to confirm traces are being received:
```
INFO    TracesExporter  {"kind": "exporter", "data_type": "traces", "resource spans": 1, "spans": 1}
```
### Metrics Endpoint

The OpenTelemetry Collector exposes its internal metrics at the /metrics endpoint. These metrics are in Prometheus format and provide insights into the Collector's performance and health.

Access the metrics at:
```bash
http://your-public-ip:8888/metrics
```
---
![](/Images/otel-metrics.jpg)

---

### 8. Enhance Tracing in the Application (*This step is already included in server.js*)
Add custom spans to improve the observability of specific routes.

#### **Edit `server.js` to Add Custom Spans**
```bash
vi /root/otel-ecommerce-integration/src/server.js
```
Add the following code to create a custom span for the `/custom` route:
```javascript
app.get('/custom', (req, res) => {
    const span = tracer.startSpan('Custom Route Span');
    res.send('This is a custom route');
    span.end();
});
```
- **Why:** Custom spans provide detailed observability for specific operations.
- **Result:** Requests to `/custom` will generate a new span named `Custom Route Span`.

#### **Restart the Application**
```bash
node server.js
```
- **Why:** Applies the changes to the server.
- **Result:** The application restarts with the new custom span functionality.

#### **Test the Custom Route**
Visit the custom route in your browser or using `curl`:
```bash
http://<your-server-ip>:3000/custom
```
---

![](/Images/otel-custom-metrics.jpg)

---
- **Why:** Generates traffic to test the new custom span.
- **Result:** A span is created for the `/custom` route and sent to the Collector.

---

### **9. Verify Traces**
Check the OpenTelemetry Collector logs to confirm that the custom span is being collected:
```bash
INFO    TracesExporter  {"kind": "exporter", "data_type": "traces", "resource spans": 1, "spans": 1}
```

---

## Conclusion:

This setup ensures a complete CI/CD pipeline with integrated security tools for DevSecOps practices. Modify and scale as needed for specific project requirements.

