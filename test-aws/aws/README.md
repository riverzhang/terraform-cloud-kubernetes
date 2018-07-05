## Kubernetes on AWS with Terraform

**Overview:**

This project will create:
* VPC with Public and Private Subnets in # Availability Zones
* Bastion Hosts and NAT Gateways in the Public Subnet
* A dynamic number of masters, etcd, and worker nodes in the Private Subnet
 * even distributed over the # of Availability Zones
* AWS ELB in the Public Subnet for accessing the Kubernetes API from the internet

**Requirements**
- Terraform 0.8.7 or newer

**How to Use:**

- Export the variables for your AWS credentials or edit `credentials.tfvars`:

```
export AWS_ACCESS_KEY_ID="www"
export AWS_SECRET_ACCESS_KEY ="xxx"
export AWS_SSH_KEY_NAME="yyy"
export AWS_DEFAULT_REGION="zzz"
```

- Edit `/aws/terraform.tfvars` with your data. By default, the Terraform scripts use ubuntu as base image. If you want to change this behaviour, modify terraform.tfvars
- Create an AWS EC2 SSH Key
- Run with `terraform apply --var-file="credentials.tfvars"` or `terraform apply` depending if you exported your AWS credentials

Example:
```commandline
terraform init -var-file=credentials.tfvars
terraform plan -var-file=credentials.tfvars
terraform apply -var-file=credentials.tfvars
```
- Terraform automatically creates an Ansible Inventory file called `hosts` with the created infrastructure in the directory `inventory`
