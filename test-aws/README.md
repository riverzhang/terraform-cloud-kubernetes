## Kubernetes on AWS with Terraform

**Overview:**

* A dynamic number of node in the Private Subnet

**Requirements**
- Terraform 0.8.7 or newer

**How to Use:**

- docker build -t alauda.io/alauda/terraform-aws:1.0 .

- docker run   -it \
  -e AWS_ACCESS_KEY_ID=xxxxxx \ 
  -e AWS_SECRET_ACCESS_KEY=xxxxx \
  -e AWS_SSH_KEY_NAME=xxxx \
  -e AWS_DEFAULT_REGION=xxxxx \
  -e ami=xxxxx \
  -e aws_kube_worker_size
  alauda.io/alauda/terraform-aws:1.0

- job yaml

```
apiVersion: batch/v1
kind: Job
metadata:
  name: aws
spec:
  template:
    metadata:
      name: aws
    spec:
      containers:
      - name: aws
        image: alauda.io/alauda/terraform-aws:1.0
        env:
          - name: AWS_ACCESS_KEY_ID
            value: xxxxx 
          - name: AWS_SECRET_ACCESS_KEY
            value: xxxxx 
          - name: AWS_SSH_KEY_NAME
            value: xxxxx 
          - name: AWS_DEFAULT_REGION
            value: xxxxx 
          - name: ami
            value: xxxxx 
          - name: aws_kube_worker_size
            value: xxxxx 
      restartPolicy: Never
```
