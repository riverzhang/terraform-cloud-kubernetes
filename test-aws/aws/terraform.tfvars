#Global Vars
aws_cluster_name = "k8s"

#VPC Vars
aws_vpc_cidr_block = "10.250.192.0/18"
aws_cidr_subnets_private = ["10.250.192.0/20"]
aws_cidr_subnets_public = ["10.250.224.0/20"]

#Amazon Linux AMI
ami  = "ami-4f508c22"

#Kubernetes Cluster
aws_kube_worker_num = 1
aws_kube_worker_size = "t2.medium"

default_tags = {
#  Env = "alauda"
#  Product = "kubernetes"
}
