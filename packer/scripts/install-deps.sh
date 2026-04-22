#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "==> [1/4] Actualizando sistema base (solo lo esencial)..."
sudo apt-get update -y
# Instalamos solo lo que sabemos que no falla y es crítico
sudo apt-get install -y curl unzip python3 python3-pip software-properties-common

echo "==> [2/4] Instalando JQ vía binario (Bypass de dependencias rotas)..."
# En lugar de apt install jq, bajamos el binario estático directamente
sudo curl -L https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux64 -o /usr/local/bin/jq
sudo chmod +x /usr/local/bin/jq

echo "==> [3/4] Instalando CloudWatch Agent..."
curl -fsSL -o /tmp/amazon-cloudwatch-agent.deb \
  https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i /tmp/amazon-cloudwatch-agent.deb
rm -f /tmp/amazon-cloudwatch-agent.deb

echo "==> [4/4] Instalando Goss para validación..."
curl -fsSL https://github.com/goss-org/goss/releases/latest/download/goss-linux-amd64 -o /tmp/goss
sudo install -m 0755 /tmp/goss /usr/local/bin/goss
rm -f /tmp/goss

echo "==> ¡Proceso completado con éxito!"
jq --version