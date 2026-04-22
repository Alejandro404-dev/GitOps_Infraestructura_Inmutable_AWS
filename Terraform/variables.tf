variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "app_name" {
  type    = string
  default = "app"
}

variable "ami_name" {
  type    = string
  default = "app-ubuntu-2204"
}

variable "use_ssm_ami" {
  type    = bool
  default = true
}

variable "ssm_ami_param_name" {
  type    = string
  default = "/app/ami-id"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "asg_min_size" {
  type    = number
  default = 2
}

variable "asg_max_size" {
  type    = number
  default = 4
}

variable "asg_desired_capacity" {
  type    = number
  default = 2
}

variable "alert_email" {
  type    = string
  default = ""
}
