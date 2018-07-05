FROM centos:7
MAINTAINER "alauda Terraform Team <rongzhang@alauda.io>"

USER root
ENV TERRAFORM_VERSION=0.11.7

RUN yum install git curl openssh unzip -y && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

COPY ./aws /aws 
WORKDIR  /aws

CMD ["/bin/bash", "/aws/terraform.sh"]
