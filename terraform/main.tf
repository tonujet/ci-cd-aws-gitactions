terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {
  region     = "eu-north-1"
  access_key = "AKIA47CRXLNWBXHXOOY4"
  secret_key = "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"
}

resource "aws_instance" "web" {
  ami                    = "ami-0914547665e6a707c"
  instance_type          = "t3.micro"
  key_name               = "first"
  # vpc_security_group_ids = [aws_security_group.http_server.id]

  tags = {
    Name = "FromTerraform"
  }
  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y docker.io
    docker run -p 80:80 -d --name web tonujet/iit-lab4
    docker run -d --name watchtower -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --cleanup --schedule "* * * * * *"
  EOF
}


resource "aws_security_group" "http_server" {
  name        = "http_server"
  description = "Http_server inbound traffic and all outbound traffic"
  vpc_id      = "vpc-0d201c4c176bafc9c"

  tags = {
    Name = "http_server"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http_server_http_rule" {
  security_group_id = aws_security_group.http_server.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "http_server_ssh_rule" {
  security_group_id = aws_security_group.http_server.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "http_server_outbound_rule" {
  security_group_id = aws_security_group.http_server.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}



