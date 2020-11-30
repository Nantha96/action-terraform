resource "aws_instance" "myInstance" {
  ami           = "ami-0a54aef4ef3b5f881"
  instance_type = "t2.micro"
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

resource "aws_security_group_rule" "myInstance" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks 		= ["0.0.0.0/0"]
  security_group_id = "sg-0bbe10ba0129ef5d6"
}

module "key_pair" {

  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "deployer-two"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAiAistfEpeFZJQy9LvplAwVwPcALRbp7sN6E5Nw1Rf1/PQc8TFsfONo+FNXeqIuGbgZNpAglsNROyHQaldMDHlDF/GtUzsBpCplSYweDPcmhlLt9NToGqyZ+YA9VYzWdC20Sl/bajs9L3nuwJIaO0Gw7rbhbSMKwuGCJrNjJrvazj5yR5hvopJfdsWriCVekhdr/GqsKh651RE/vHRFzmPvlKUwciIHsYrt4sWv3Tl9PWnHT8uwx4xDE8KxEhD1ZaV66C8YPSpHearkSbpMLhXmMrU3GSS1Po108KBw2JYvNn7mIHNQ511Ag9bIkA/1TF9yHFlG8fVhjGWC8x5B/yvw=="

}


output "DNS" {
  value = aws_instance.myInstance.public_dns
}