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
        Action   = ["ec2:Describe*"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

  tags = {
      tag-key = "tag-value"
  }
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


output "DNS" {
  value = aws_instance.myInstance.public_dns
}
