#Add AWS Roles for Kubernetes


resource "aws_iam_role" "kube-worker" {
    name = "kubernetes-${var.aws_cluster_name}-node"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      }
      }
  ]
}
EOF
}


resource "aws_iam_role_policy" "kube-worker" {
    name = "kubernetes-${var.aws_cluster_name}-node"
    role = "${aws_iam_role.kube-worker.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
        {
          "Effect": "Allow",
          "Action": "ec2:Describe*",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": "ec2:AttachVolume",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": "ec2:DetachVolume",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": ["route53:*"],
          "Resource": ["*"]
        },
        {
          "Effect": "Allow",
          "Action": [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:GetRepositoryPolicy",
            "ecr:DescribeRepositories",
            "ecr:ListImages",
            "ecr:BatchGetImage"
          ],
          "Resource": "*"
        }
      ]
}
EOF
}


#Create AWS Instance Profiles

resource "aws_iam_instance_profile" "kube-worker" {
    name = "kube_${var.aws_cluster_name}_node_profile"
    role = "${aws_iam_role.kube-worker.name}"
}
