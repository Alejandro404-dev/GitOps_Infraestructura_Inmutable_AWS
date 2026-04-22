#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get install -y \
  curl \
  unzip \
  python3 \
  python3-pip \
  jq

# CloudWatch Agent for system metrics.
curl -fsSL -o /tmp/amazon-cloudwatch-agent.deb \
  https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i /tmp/amazon-cloudwatch-agent.deb
rm -f /tmp/amazon-cloudwatch-agent.deb

# Goss binary used by AMI validation stage.
curl -fsSL https://github.com/goss-org/goss/releases/latest/download/goss-linux-amd64 -o /tmp/goss
sudo install -m 0755 /tmp/goss /usr/local/bin/goss
rm -f /tmp/goss
