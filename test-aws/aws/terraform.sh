#!/bin/sh

# init setup
terraform init -plugin-dir=.terraform/plugins/linux_amd64/ 

# AWS env args
export TF_VAR_AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID 
export TF_VAR_AWS_SSH_KEY_NAME=$AWS_SSH_KEY_NAME
export TF_VAR_AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export TF_VAR_AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
export TF_VAR_ami=$ami
export TF_VAR_aws_kube_worker_size=$aws_kube_worker_size

# deploy setup
terraform apply -auto-approve
