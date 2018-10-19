#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EC2 Security Group to allow networking traffic
#  * Data source to fetch latest EKS worker AMI
#  * AutoScaling Launch Configuration to configure worker instances
#  * AutoScaling Group to launch worker instances
#

resource "aws_iam_role" "demo-node" {
  name = "terraform-eks-demo-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.demo-node.name}"
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.demo-node.name}"
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.demo-node.name}"
}

resource "aws_iam_instance_profile" "demo-node" {
  name = "terraform-eks-demo"
  role = "${aws_iam_role.demo-node.name}"
}

resource "aws_security_group" "demo-node" {
  name        = "terraform-eks-demo-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.demo.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "terraform-eks-demo-node",
     "kubernetes.io/cluster/${var.cluster-name}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "demo-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.demo-node.id}"
  source_security_group_id = "${aws_security_group.demo-node.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "demo-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.demo-node.id}"
  source_security_group_id = "${aws_security_group.demo-cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}


# uncomment if ssh access to the nodes is required

#resource "aws_security_group_rule" "demo-node-ingress-workstation-ssh" {
#  cidr_blocks       = ["${local.workstation-external-cidr}"]
#  description       = "Allow workstation to communicate with the Nodes"
#  from_port         = 22
#  protocol          = "tcp"
#  security_group_id = "${aws_security_group.demo-node.id}"
#  to_port           = 22
#  type              = "ingress"
#}


data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  demo-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.demo.endpoint}' --b64-cluster-ca '${aws_eks_cluster.demo.certificate_authority.0.data}' '${var.cluster-name}'
USERDATA
}


resource "aws_key_pair" "chrissis-xps-key" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDnOMTrBtmi4JwheVLKPi3V7DZyaxgXXYR/GhBrgvwpawOwCggjz3uPlXKkwssKZpCj9FE7W66M1L2EvUinth1uHU6lAgw/qP3mfnrSHRpBE0MjgncztZ5GCSNeZ2et/L5r0eOCipL4y7L4RNjU3QmIIKbZCnuxQjD8p4crL12q7LzeUvQKiG6GJM/QwbpWv0gHeZg86fMcDZQTYojUijflA4BGfScpZZ20B9xamc6Av76kMKO06wQM1C+3V9Gx/tEO+az2qQp0ckmy9Qp1ivM3DgtMiXFs/d6nFJ+t1318xauigBwaa8SexchBdRS8npul9CnxmFSF+uCaU7sxDZn8tbK/dUARFoxiUz8Njsd5y5A0fVoekMrG8Lj36CdSqGsDKJVQRBENQqVSgMXf1vfYlo3eWpAhu1ZnRcad3wPtgzJi2XE3ixWObhTiWyC2/7WWT+dTMIomiplYTQgbwhS94EQhXVqpQ1N65XMnbMug7XkbGfE/OuII/4vmyFVc6Q2Z51VYggwK81t0J8oXQsoHnwMR5jx+jJhRH7hQmUZua785Xcj21kHGMfcHTHeoKaC3QdpGStb/gYQQQj5w4Cwyzn22tsGOZBl1ylkiajtvedkaVyP+D5h9SI3KzKdTI6BxL+wQVdXbJQU7qGzy+ybLkb3suilCn0HNAmalJyPozw== christian.woehrle@googlemail.com"
}

resource "aws_launch_configuration" "demo" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.demo-node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "m4.large"
  name_prefix                 = "terraform-eks-demo"
  security_groups             = ["${aws_security_group.demo-node.id}"]
  user_data_base64            = "${base64encode(local.demo-node-userdata)}"
  ## add key here
  key_name                    = "${aws_key_pair.chrissis-xps-key.id}"
  spot_price                  = "0.04"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "demo" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.demo.id}"
  max_size             = 2
  min_size             = 1
  name                 = "terraform-eks-demo"
  vpc_zone_identifier  = ["${aws_subnet.demo.*.id}"]

  tag {
    key                 = "Name"
    value               = "terraform-eks-demo"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }
}
