# Project Authentications

## Change IP in Jenkins:
```
vi /var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml
```
```bash
systemctl restart jenkins
```

## Enable and Start Docker:
```
systemctl enable docker
```
```bash
systemctl start docker
```

## Start Containers:
```bash
docker ps -a
```
```bash
docker start sonar
```
```bash
docker start nexus
```
```bash
sudo usermod -aG docker jenkins
```
```bash
systemctl restart docker
```
```bash
systemctl restart jenkins
```

## Start Vault:
```
vault server -dev -dev-listen-address="0.0.0.0:8200" &
```
**Note Token:** `hvs.XXsPU4vTpRiphTpKeVWkxnbS`

## Change Sonar and Vault IPs in Jenkins

## Vault Configuration:
1. Set Vault Environment Variables:
```
export VAULT_ADDR=http://0.0.0.0:8200
```
```bash
export VAULT_TOKEN=hvs.XXsPU4vTpRiphTpKeVWkxnbS
```

2. Enable the AWS Secrets Engine:
```
vault secrets enable -path=aws aws
```

3. Configure AWS Credentials in Vault:
```
vault write aws/config/root \
 access_key=AKIA23WHUDH2UJMWFWW7 \
 secret_key=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
```

4. Create a Vault Role for AWS Credentials:
```
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

## Add or Change Vault Address and Token in Jenkins Credentials

## Add SonarQube Token to Jenkins Credentials

## Add Docker Credentials to Vault:
```
vault kv put secret/docker username="nuthan0530" password="Panny@123"
```

## Enable Nexus Secrets Engine:
```
vault secrets enable -path=nexus kv
```

## Add Nexus Credentials to Vault:
```
vault kv put nexus/credentials \
    username="admin" \
    password="Example@12345" \
    repo_url=http://65.2.74.101:8081/repository/Docker/
```

## Enable Snyk Secrets Engine:
```
vault secrets enable -path=snyk kv
```

## Add Snyk Token to Vault:
```
vault kv put snyk/token api_token="5c5a0fce-02ae-4f96-b941-d3e3888cea09"
```

