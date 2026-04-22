# GitOps Infraestructura Inmutable AWS

Guia para levantar y operar el servicio con AMIs inmutables usando `Packer + Ansible + Goss + Terraform + GitHub Actions`.

## 1) Que despliega este repo

- Build de AMI Ubuntu 22.04 con app + Nginx + systemd.
- Publicacion del AMI ID en SSM Parameter Store (`/app/ami-id`).
- Infraestructura con Terraform:
  - Launch Template
  - Auto Scaling Group con Instance Refresh
  - Application Load Balancer + Target Group con `/health`
  - IAM Role para Session Manager y lectura de parametros SSM
  - CloudWatch Dashboard + alarma SNS de unhealthy targets
- Pipelines GitHub Actions para build AMI, deploy de infraestructura, refresh y drift detection.

## 2) Estructura del proyecto

- `packer/`: template HCL2, scripts de provision y tests Goss.
- `ansible/`: playbook, roles y templates.
- `Terraform/`: infraestructura AWS.
- `.github/workflows/`: pipelines CI/CD.
- `scripts/e2e-validation.sh`: validacion operativa post-deploy.

## 3) Prerrequisitos

### AWS

- Cuenta AWS con permisos para EC2, ASG, ELBv2, IAM, SSM, CloudWatch, SNS.
- Region objetivo: `us-east-1`.
- Credenciales para CI (o idealmente OIDC).

### Local (opcional para pruebas locales)

- Terraform >= 1.5
- Packer >= 1.9
- AWS CLI v2
- Ansible + ansible-lint
- Bash (Git Bash o WSL si estas en Windows)

## 4) Configuracion de GitHub (obligatorio para pipelines)

En `Settings -> Secrets and variables -> Actions`, crear:

### Secrets

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN` (si tu entorno lo requiere)

### Variables (opcional recomendado)

- `ASG_NAME` (por defecto el workflow usa `app-asg` si no esta definido)

### Environments

- Crear environment `production`.
- Configurar required reviewers para aprobacion manual antes de `apply`.

## 5) Levantar servicio (camino recomendado)

## Paso A - Build de AMI

Se ejecuta por cambios en `packer/**` o `ansible/**`, o manual:

- Workflow: `.github/workflows/ami-build.yml`
- Jobs:
  - `lint`
  - `build_ami`
  - `test_ami`
  - `tag_golden`
  - `update_ssm_param`

Resultado esperado:

- Nueva AMI con tags `Name`, `Version`, `BuildDate`, `GitCommit`, `Golden=true`.
- SSM actualizado en `/app/ami-id`.

## Paso B - Deploy de infraestructura

Se ejecuta por cambios en `Terraform/**`, o manual:

- Workflow: `.github/workflows/infra-deploy.yml`
- Jobs:
  - `validate`
  - `plan`
  - `apply` (con aprobacion manual en `production`)

Resultado esperado:

- ALB publico con target group healthy.
- ASG en servicio con instancias lanzadas desde AMI vigente.

## Paso C - Instance Refresh (si aplica)

Workflow: `.github/workflows/instance-refresh.yml`

- Trigger manual (`workflow_dispatch`) o automatico al terminar `ami-build`.
- Ejecuta `aws autoscaling start-instance-refresh` con:
  - `MinHealthyPercentage=50`
  - `InstanceWarmup=120`

## Paso D - Verificacion E2E

Con AWS CLI configurado, correr:

```bash
bash scripts/e2e-validation.sh <alb_dns_name> <asg_name>
```

Valida:

- `GET /health` por ALB
- estado de instance refresh
- AMI activa en SSM (`/app/ami-id`)

## 6) Comandos utiles locales

## Terraform

```bash
cd Terraform
terraform init
terraform fmt -check
terraform validate
terraform plan
```

## Packer

```bash
packer init packer/ubuntu-2204.pkr.hcl
packer validate packer/ubuntu-2204.pkr.hcl
```

## Goss (si pruebas local/instancia)

```bash
goss -g packer/goss.yaml validate --format documentation
```

## 7) Operacion y observabilidad

- Dashboard CloudWatch creado por Terraform (`${app_name}-dashboard`).
- Alarma CloudWatch: unhealthy targets > 0 durante 5 minutos.
- Alertas enviadas por SNS topic `${app_name}-alerts`.
- Drift detection diario: `.github/workflows/drift-detection.yml`.

## 8) Rollback rapido (operativo)

Opciones:

1. Restaurar el valor anterior de `/app/ami-id` en SSM.
2. Ejecutar `infra-deploy` (o `instance-refresh`) para rotar instancias a la AMI previa.

Buenas practicas:

- Mantener historial de AMIs golden por tags/version.
- No borrar inmediatamente la AMI anterior.
- Validar `/health` y `HealthyHostCount` durante rollback.

## 9) Troubleshooting

- `ami-build` falla en `test_ami`:
  - revisar permisos SSM Run Command y estado de la instancia temporal.
- `infra-deploy` falla en `apply`:
  - revisar aprobacion de environment `production` y permisos IAM.
- Targets unhealthy:
  - revisar `app.service`, `nginx`, y respuesta `200` en `/health`.

## 10) Checklist de salida a produccion

- `ami-build` en verde con AMI publicada en SSM.
- `infra-deploy` aplicado con aprobacion manual.
- ASG estable y ALB healthy.
- Alarma y dashboard visibles en CloudWatch.
- Validacion E2E ejecutada sin errores.
