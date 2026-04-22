packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.2.8"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = ">= 1.1.1"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "version" {
  type    = string
  default = "dev"
}

variable "git_commit" {
  type    = string
  default = "local"
}

variable "build_date" {
  type    = string
  default = "1970-01-01T00:00:00Z"
}

source "amazon-ebs" "ubuntu2204" {
  region        = var.aws_region
  instance_type = "t3.micro"
  ssh_username  = "ubuntu"

  # --- EL PARCHE DE AWS ACADEMY ---
  ssh_keypair_name     = "vockey"
  ssh_private_key_file = "~/.ssh/vockey.pem" 
  # --------------------------------

  ami_name        = "app-ubuntu-2204-${var.version}"
  ami_description = "Golden AMI Ubuntu 22.04 LTS para app"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"]
    most_recent = true
  }

  tags = {
    Name      = "app-ubuntu-2204"
    Version   = var.version
    BuildDate = var.build_date
    GitCommit = var.git_commit
    Golden    = "true"
  }

  run_tags = {
    Name = "packer-build-app-ubuntu-2204"
  }
}

build {
  name    = "app-ubuntu-2204"
  sources = ["source.amazon-ebs.ubuntu2204"]

  provisioner "shell" {
    script = "${path.root}/scripts/install-deps.sh"
  }

  provisioner "ansible" {
    playbook_file = "${path.root}/../ansible/playbook.yml"
    extra_arguments = [
      "--extra-vars",
      "app_port=8080"
    ]
  }

  provisioner "shell" {
    script = "${path.root}/scripts/cleanup.sh"
  }

provisioner "shell" {
    script = "${path.root}/scripts/cleanup.sh"
  }
}