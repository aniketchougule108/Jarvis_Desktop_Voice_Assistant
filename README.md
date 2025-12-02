# 🚀 Deploying Jarvis Desktop Voice Assistant on AWS EC2 using Terraform & Jenkins
This project demonstrates how to deploy the Jarvis Desktop Voice Assistant on an AWS EC2 instance using Terraform for Infrastructure as Code (IaC) and Jenkins for CI/CD automation. Updates to the application are automatically triggered via GitHub Webhooks, ensuring seamless deployment.

![](./img/ReadmeHeader.gif)

---
## 📌 Project Overview
* The goal of this project is to:
* Provision AWS infrastructure using Terraform
* Deploy the Jarvis Voice Assistant on an EC2 instance
* Automate deployment using a Jenkins CI/CD pipeline
* Enable GitHub webhook to trigger pipelines on every code push
* Run the Jarvis application automatically using systemd service
---

## 🛠️ Technologies Used
<table border="1" cellpadding="8" cellspacing="0">
  <tr>
    <th>Technology</th>
    <th>Purpose</th>
  </tr>
  <tr>
    <td><b>Terraform</b></td>
    <td>Provision EC2, Security Groups, Key Pair, IAM Roles</td>
  </tr>
  <tr>
    <td><b>AWS EC2</b></td>
    <td>Host the Jarvis Desktop Voice Assistant</td>
  </tr>
  <tr>
    <td><b>Jenkins</b></td>
    <td>Automate deployment & updates</td>
  </tr>
  <tr>
    <td><b>GitHub</b></td>
    <td>Source code + webhook trigger</td>
  </tr>
  <tr>
    <td><b>Python</b></td>
    <td>Application runtime</td>
  </tr>
  <tr>
    <td><b>Systemd</b></td>
    <td>Run Jarvis app automatically on boot</td>
  </tr>
</table>

---

## 🏗️ 1. Terraform Setup
### 📁 File Structure  
* `provider.tf` → AWS region\
* `variables.tf` → Variables (ami, instance type, key, CIDR)\
* `main.tf` → EC2 + SG + KeyPair\
* `outputs.tf` → Output EC2 Public IP\
* `user_data.sh` → Bootstrap installation

### provider.tf

```
provider "aws" {
  region = var.aws_region
}
```

### variables.tf

```
variable "my_ami" {
  default = "ami-02d26659fd82cf299"
}

variable "my_instance" {
  default = "t2.micro"
}

variable "my_key" {
    default = "terraform"
}

variable "user_data" {
  description = "Path to the user_data file"
}
```
### main.tf (Important parts)
```
resource "aws_instance" "jarvis-2-0" {
  ami = var.my_ami
  instance_type = var.my_instance
  key_name = var.my_key
  vpc_security_group_ids = [aws_security_group.jarvis-2-0.id]
  user_data = file("userdata.sh")
  tags = {
    Name = "jarvis-2-0"
  }
}

resource "aws_security_group" "jarvis-2-0" {
 name = "jarvis-2-0" 

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

}
```
### user_data.sh (Example)
```
#!/bin/bash
apt update -y
apt upgrade -y
apt install -y git python3 python3-venv python3-pip rsync curl openjdk-11-jdk

mkdir -p /home/ubuntu/jarvis
chown -R ubuntu:ubuntu /home/ubuntu/jarvis
```

**Example Terraform Execution:**
```
terraform init
terraform plan
terraform apply -auto-approve
```

![](./img/Screenshot%20(280).png)

---

## 🔑 2. Jenkins Installation on EC2
SSH into instance:
```
ssh -i key.pem ubuntu@PUBLIC_IP
```
Install Jenkins:
```
sudo apt update
sudo apt install -y openjdk-11-jdk
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install -y jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
```

Access Jenkins:
```
http://PUBLIC_IP:8080
```
Initial Password:

```
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

![](./img/Screenshot%20(277).png)


---
## 3. Adding Jenkinsfile to GitHub + Webhook Setup
**Jenkinsfile Example**

![](./img/Screenshot%20(278).png)

**GitHub Webhook Setup**  
GitHub → Repo Settings → Webhooks → Add

Payload URL:
```
http://JENKINS_IP:8080/github-webhook/
```
Content Type: application/json
Event: **Push**

![](./img/Screenshot%20(282).png)

---

## 4. Adding Credentials in Jenkins
Navigate:  
Jenkins → Credentials → Global → Add Credentials
* Kind: SSH Username with Private Key
* Username: ubuntu
* Private Key: Paste your PEM
* ID: `jarvis-key`

![](./img/Screenshot%20(275).png)
---
## 4. Deployment
**Create Pipeline Job in Jenkins**
* New Item → Pipeline
* Pipeline from SCM
* Repository: `https://github.com/you/Jarvis-Desktop-Voice-Assistant.git`
* Branch: `main`
* Script Path: `Jenkinsfile`

![](./img/Screenshot%20(283).png)

Click **Build Now**  
Webhook triggers build on new GitHub pushes.

![](./img/Screenshot%20(274).png)

---

## Checklist
✓ Terraform instance created  
✓ Jenkins installed  
✓ Jenkinsfile pushed  
✓ Webhook configured  
✓ SSH credentials added  
✓ Pipeline created  
✓ Deployment working

---
🏁 Conclusion

This project successfully delivers a fully automated, production-ready deployment pipeline for the Jarvis Desktop Voice Assistant. Using Terraform, the infrastructure is consistent, repeatable, and easy to manage. With Jenkins automation and GitHub webhooks, every code update is deployed instantly to the EC2 instance without manual effort. The application runs continuously using systemd, ensuring stable operation.

Overall, this setup provides:

* Zero manual deployment
* Complete end-to-end automation
* Scalable & reproducible AWS infrastructure
* Efficient CI/CD workflow for real-time updates

This approach can be reused and expanded for any similar Python-based or desktop application deployment on AWS.