# terraform-cloud-vsphere

## Requirements

* Terraform
* Internet connection on the Kubernetes nodes to download the Kubernetes binaries.
* vSphere environment with a vCenter. An enterprise plus license is needed if you would like to configure anti-affinity between the Kubernetes master nodes.
* A Ubuntu 16.04 vSphere template. If linked clone is used, the template needs to have one and only one snapshot.
* A resource pool to place the Kubernetes virtual machines.

## Usage

$ vim terraform.tfvars

$ terraform init

$ terraform plan

$ terraform apply

