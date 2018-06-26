#Global Vars
aws_cluster_name = "k8s"

#VPC Vars
aws_vpc_cidr_block = "10.250.192.0/18"
aws_cidr_subnets_private = ["10.250.192.0/20"]
aws_cidr_subnets_public = ["10.250.224.0/20"]

#Amazon Linux AMI
ami  = "ami-4f508c22"

#Bastion Host
aws_bastion_size = "t2.medium"

#Kubernetes Cluster

aws_kube_master_num = 1
aws_kube_master_size = "t2.medium"

aws_kube_worker_num = 1
aws_kube_worker_size = "t2.medium"

#Settings AWS ELB

aws_elb_api_port = 6443
k8s_secure_api_port = 6443
kube_insecure_apiserver_address = "0.0.0.0"

default_tags = {
#  Env = "alauda"
#  Product = "kubernetes"
}
