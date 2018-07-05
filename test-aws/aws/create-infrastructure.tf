terraform {
    required_version = ">= 0.8.7"
}

provider "aws" {
    access_key = "${var.AWS_ACCESS_KEY_ID}"
    secret_key = "${var.AWS_SECRET_ACCESS_KEY}"
    region = "${var.AWS_DEFAULT_REGION}"
}

data "aws_availability_zones" "available" {}

/*
* Calling modules who create the initial AWS VPC / AWS ELB
* and AWS IAM Roles for Kubernetes Deployment
*/

module "aws-vpc" {
  source = "modules/vpc"

  aws_cluster_name = "${var.aws_cluster_name}"
  aws_vpc_cidr_block = "${var.aws_vpc_cidr_block}"
  aws_avail_zones="${slice(data.aws_availability_zones.available.names,0,1)}"
  aws_cidr_subnets_private="${var.aws_cidr_subnets_private}"
  aws_cidr_subnets_public="${var.aws_cidr_subnets_public}"
  default_tags="${var.default_tags}"

}

module "aws-iam" {
  source = "modules/iam"

  aws_cluster_name="${var.aws_cluster_name}"
}


/*
* Create K8s Master and worker nodes instances
*
*/

resource "aws_instance" "k8s-worker" {
    ami = "${var.ami}"
    instance_type = "${var.aws_kube_worker_size}"

    count = "${var.aws_kube_worker_num}"

    availability_zone  = "${element(slice(data.aws_availability_zones.available.names,0,1),count.index)}"
    subnet_id = "${element(module.aws-vpc.aws_subnet_ids_private,count.index)}"

    vpc_security_group_ids = [ "${module.aws-vpc.aws_security_group}" ]

    iam_instance_profile = "${module.aws-iam.kube-worker-profile}"
    key_name = "${var.AWS_SSH_KEY_NAME}"


    tags = "${merge(var.default_tags, map(
      "Name", "kubernetes-${var.aws_cluster_name}-worker${count.index}",
      "kubernetes.io/cluster/${var.aws_cluster_name}", "member",
      "Role", "worker"
    ))}"

}

