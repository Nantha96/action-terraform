terraform {
  backend "s3" {
    bucket         = "nanthabuckettwo"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-db-2"
    encrypt        = true
  }
}

resource "aws_instance" "myInstance" {
  ami           = "ami-05d72852800cbf29e"
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ssm_profie.name
  key_name = "deployer-two"
  user_data = <<-EOF
			  #! /bin/bash
			  sudo yum -y install httpd
			  sudo service httpd start
		      EOF

  
}		

provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

resource "aws_iam_role" "test_role" {
  name = "test_role"

assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
managed_policy_arns = [aws_iam_policy.policy_two.arn]

  tags = {
      tag-key = "tag-value"
  }
}

resource "aws_iam_policy" "policy_two" {
  name = "policy-381966"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeAssociation",
                "ssm:GetDeployablePatchSnapshotForInstance",
                "ssm:GetDocument",
                "ssm:DescribeDocument",
                "ssm:GetManifest",
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:ListAssociations",
                "ssm:ListInstanceAssociations",
                "ssm:PutInventory",
                "ssm:PutComplianceItems",
                "ssm:PutConfigurePackageResult",
                "ssm:UpdateAssociationStatus",
                "ssm:UpdateInstanceAssociationStatus",
                "ssm:UpdateInstanceInformation"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply"
            ],
            "Resource": "*"
        }
    ]
})
}

resource "aws_iam_instance_profile" "ssm_profie" {
  name = "ssm_profie"
  role = "${aws_iam_role.test_role.name}"
}

module "key_pair" {

  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "deployer-two"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAiAistfEpeFZJQy9LvplAwVwPcALRbp7sN6E5Nw1Rf1/PQc8TFsfONo+FNXeqIuGbgZNpAglsNROyHQaldMDHlDF/GtUzsBpCplSYweDPcmhlLt9NToGqyZ+YA9VYzWdC20Sl/bajs9L3nuwJIaO0Gw7rbhbSMKwuGCJrNjJrvazj5yR5hvopJfdsWriCVekhdr/GqsKh651RE/vHRFzmPvlKUwciIHsYrt4sWv3Tl9PWnHT8uwx4xDE8KxEhD1ZaV66C8YPSpHearkSbpMLhXmMrU3GSS1Po108KBw2JYvNn7mIHNQ511Ag9bIkA/1TF9yHFlG8fVhjGWC8x5B/yvw=="

}

locals {
  service_name = aws_instance.myInstance.public_dns
  owner        = "Community Team"
}

output "DNS" {
  value = aws_instance.myInstance.public_dns
}

output "state" {
  value = aws_instance.myInstance.instance_state
}
