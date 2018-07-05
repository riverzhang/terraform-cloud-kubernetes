variable "AWS_ACCESS_KEY_ID" {
  description = "AWS Access Key"
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS Secret Key"
}

variable "AWS_SSH_KEY_NAME" {
  description = "Name of the SSH keypair to use in AWS."
}

variable "AWS_DEFAULT_REGION" {
  description = "AWS Region"
}

variable "ami" {
  description = "Amazon Linux AMI"
  default = "ami-4f508c22"
}

//General Cluster Settings

variable "aws_cluster_name" {
  description = "Name of AWS Cluster"
}


//AWS VPC Variables

variable "aws_vpc_cidr_block" {
  description = "CIDR Block for VPC"
}

variable "aws_cidr_subnets_private" {
  description = "CIDR Blocks for private subnets in Availability Zones"
  type = "list"
}

variable "aws_cidr_subnets_public" {
  description = "CIDR Blocks for public subnets in Availability Zones"
  type = "list"
}

//AWS EC2 Settings


/*
* AWS EC2 Settings
* The number should be divisable by the number of used
* AWS Availability Zones without an remainder.
*/


variable "aws_kube_worker_num" {
    description = "Number of Kubernetes Worker Nodes"
}

variable "aws_kube_worker_size" {
    description = "Instance size of Kubernetes Worker Nodes"
}

variable "default_tags" {
  description = "Default tags for all resources"
  type = "map"
}