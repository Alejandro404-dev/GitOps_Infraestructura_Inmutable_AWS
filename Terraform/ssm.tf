resource "aws_ssm_parameter" "current_ami" {
  name  = var.ssm_ami_param_name
  type  = "String"
  value = local.ami_id_effective

  lifecycle {
    ignore_changes = [value]
  }
}
