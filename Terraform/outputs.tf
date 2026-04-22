output "alb_dns_name" {
  value = aws_lb.app.dns_name
}

output "asg_name" {
  value = aws_autoscaling_group.app_asg.name
}

output "ami_id_in_use" {
  value = local.ami_id_effective
}

output "alerts_topic_arn" {
  value = aws_sns_topic.alerts.arn
}
