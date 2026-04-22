#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Uso: $0 <alb_dns_name> <asg_name>"
  exit 1
fi

ALB_DNS_NAME="$1"
ASG_NAME="$2"

echo "1) Verificando endpoint de salud..."
curl -fsS "http://${ALB_DNS_NAME}/health" >/dev/null

echo "2) Verificando estado de refresh del ASG..."
aws autoscaling describe-instance-refreshes \
  --auto-scaling-group-name "${ASG_NAME}" \
  --max-items 1 \
  --query "InstanceRefreshes[0].[Status,PercentageComplete]" \
  --output table

echo "3) Verificando AMI activa en Parameter Store..."
aws ssm get-parameter \
  --name "/app/ami-id" \
  --query "Parameter.Value" \
  --output text

echo "Validacion E2E completada."
