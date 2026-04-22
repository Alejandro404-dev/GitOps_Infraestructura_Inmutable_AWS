#!/usr/bin/env bash
set -euo pipefail

# Evitar diálogos interactivos durante la instalación
export DEBIAN_FRONTEND=noninteractive

echo "==> Limpiando y actualizando repositorios para evitar errores de dependencias..."
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*
sudo apt-get update -y

echo "==> Instalando dependencias base..."
# Añadimos --fix-missing y software-properties-common para mayor estabilidad
sudo apt-get install -y --fix-missing \
  software-properties-common \
  curl \
  unzip \
  python3 \
  python3-pip \
  jq

echo "==> Instalando CloudWatch Agent..."
curl -fsSL -o /tmp/amazon-cloudwatch-agent.deb \
  https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i /tmp/amazon-cloudwatch-agent.deb
rm -f /tmp/amazon-cloudwatch-agent.deb

echo "==> Instalando Goss para validación de AMI..."
curl -fsSL https://github.com/goss-org/goss/releases/latest/download/goss-linux-amd64 -o /tmp/goss
sudo install -m 0755 /tmp/goss /usr/local/bin/goss
rm -f /tmp/goss

echo "==> Instalación de dependencias finalizada con éxito."