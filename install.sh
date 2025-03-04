sudo yum install git -y
curl -sL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install nodejs -y
node -v
npm -v
git clone https://github.com/DevopsProjects05/DevSecOps-End-to-End-Project.git
cd DevSecOps-End-to-End-Project/src
npm install @opentelemetry/sdk-trace-node
npm install @opentelemetry/exporter-trace-otlp-http
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io-2023.key
sudo yum upgrade -y
amazon-linux-extras enable corretto17
sudo yum install -y java-17-amazon-corretto
java --version
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins

sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install -y terraform
terraform --version
curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
tfsec --version
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh
sudo mv ./bin/trivy /usr/local/bin/trivy
trivy --version
npm install -g snyk
snyk --version
yum install pip -y
pip install ansible
ansible --version
sudo yum install docker -y
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker
docker run -d --name sonarcontainer -p 9000:9000 sonarqube:latest
docker ps


mkdir -p /downloads/sonarqube
cd /downloads/sonarqube
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
unzip sonar-scanner-cli-5.0.1.3006-linux.zip
sudo mv sonar-scanner-5.0.1.3006-linux /opt/sonar-scanner

nexus 
=====
docker run -d -p 8081:8081 --name nexus sonatype/nexus3
docker exec -it nexus cat /nexus-data/admin.password


prometheus & grafana
==================

npm install prom-client
wget https://dl.grafana.com/oss/release/grafana-10.0.0.linux-amd64.tar.gz
tar -xvzf grafana-10.0.0.linux-amd64.tar.gz
cd grafana-10.0.0/bin
./grafana-server


