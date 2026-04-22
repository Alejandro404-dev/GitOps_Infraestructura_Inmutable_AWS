terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  ami_id_effective = var.use_ssm_ami ? data.aws_ssm_parameter.current_ami[0].value : data.aws_ami.latest_golden.id
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ssm_parameter" "current_ami" {
  count = var.use_ssm_ami ? 1 : 0
  name  = var.ssm_ami_param_name
}

data "aws_ami" "latest_golden" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Name"
    values = [var.ami_name]
  }

  filter {
    name   = "tag:Golden"
    values = ["true"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  ami_id_effective = var.use_ssm_ami ? data.aws_ssm_parameter.current_ami[0].value : data.aws_ami.latest_golden.id
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ssm_parameter" "current_ami" {
  count = var.use_ssm_ami ? 1 : 0
  name  = var.ssm_ami_param_name
}

data "aws_ami" "latest_golden" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Name"
    values = [var.ami_name]
  }

  filter {
    name   = "tag:Golden"
    values = ["true"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

variable "ami_id" {
  description = "ID de la AMI dorada"
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg-final"
  description = "Permitir HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-lt-"
  image_id      = var.ami_id
  instance_type = "t3.micro"

  # ELIMINAMOS EL BLOQUE IAM_INSTANCE_PROFILE TOTALMENTE
  # Ya no dependeremos de roles que AWS Academy bloquea.

  network_interfaces {
    security_groups             = [aws_security_group.ec2_sg.id]
    associate_public_ip_address = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name                = "app-asg"
  vpc_zone_identifier = data.aws_subnets.default.ids

  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  # Esto cumple con el punto de Rolling Updates del proyecto
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "AppInstance"
    propagate_at_launch = true
  }
}