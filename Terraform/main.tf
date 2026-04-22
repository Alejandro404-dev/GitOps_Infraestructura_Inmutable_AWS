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
  region = "us-east-1"
}

# --- EL PARCHE DE EMERGENCIA DE AWS ACADEMY ---
# Comentamos la lógica dinámica y forzamos el AMI ID exacto
locals {
  # ami_id_effective = var.use_ssm_ami ? data.aws_ssm_parameter.current_ami[0].value : data.aws_ami.latest_golden.id
  ami_id_effective = "ami-08a7b55e3f225a68e" # <-- PON TU AMI ID AQUÍ SI ES DIFERENTE
}
# ----------------------------------------------

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# data "aws_ssm_parameter" "current_ami" {
#   count = var.use_ssm_ami ? 1 : 0
#   name  = var.ssm_ami_param_name
# }

# data "aws_ami" "latest_golden" {
#   most_recent = true
#   owners      = ["self"]
#
#   filter {
#     name   = "tag:Name"
#     values = [var.ami_name]
#   }
#
#   filter {
#     name   = "tag:Golden"
#     values = ["true"]
#   }
#
#   filter {
#     name   = "state"
#     values = ["available"]
#   }
# }