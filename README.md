# Projeto ToggleMaster Fase 3

## Visão Geral

Este projeto implementa a plataforma ToggleMaster da PósTech FIAP com microsserviços, infraestrutura AWS provisionada via Terraform e entrega em EKS usando GitOps com ArgoCD.

O fluxo principal do repositório é:

1. O Terraform cria a infraestrutura AWS e os recursos base do cluster.
2. O módulo [terraform/main/modules/argocd/main.tf](/home/william/Documentos/pos-graduacao/toggle_master_FIAP/terraform/main/modules/argocd/main.tf) instala o ArgoCD.
3. O ArgoCD sincroniza o app raiz em [gitops/app-of-apps/applicationset.yaml](/home/william/Documentos/pos-graduacao/toggle_master_FIAP/gitops/app-of-apps/applicationset.yaml).
4. O `ApplicationSet` cria as `Applications` dos 5 serviços.
5. Os charts Helm em `gitops/<service>` aplicam `Deployment`, `Service`, `Ingress`, HPA e jobs de init quando habilitados.

O fluxo baseado em `apps/kubernetes` não é mais utilizado. O deploy atual do projeto é feito com Terraform + ArgoCD + Helm.

## Serviços

- `auth-service`: Go + PostgreSQL
- `flag-service`: Python + PostgreSQL
- `targeting-service`: Python + PostgreSQL
- `evaluation-service`: Go + Redis + SQS
- `analytics-service`: Python + DynamoDB + SQS

## Estrutura do Repositório

- `apps/local/`: código-fonte dos microsserviços
- `terraform/bootstrap/tf-backend/`: bootstrap do bucket S3 do backend remoto do Terraform
- `terraform/main/`: infraestrutura principal
- `terraform/main/modules/argocd/`: instalação do ArgoCD e app raiz
- `gitops/`: charts Helm e app-of-apps do ArgoCD
- `.github/workflows/`: pipelines de CI por microsserviço

## Pré-requisitos

Todos os comandos abaixo devem ser executados na raiz do projeto.

Ferramentas esperadas no ambiente:

- `terraform`
- `aws`
- `kubectl`
- `docker`
- `make`

## Como Executar

### 1. Criar o bucket do backend Terraform

```bash
make terraform_backend_bootstrap
```

Para sobrescrever profile ou bucket:

```bash
make terraform_backend_bootstrap \
  AWS_PROFILE=fiapaws \
  TFSTATE_BUCKET=toggle-master-tfstate
```

### 2. Preencher o `terraform.tfvars`

Use [terraform/main/terraform.tfvars.example](/home/william/Documentos/pos-graduacao/toggle_master_FIAP/terraform/main/terraform.tfvars.example) como base e configure pelo menos:

- `aws_account_id`
- `db_user`
- `db_password`
- `master_key`
- `service_api_key`
- `enable_argocd`
- `gitops_repo_url`
- `gitops_target_revision`
- `argocd_admin_password_hash`

### 3. Aplicar a infraestrutura

```bash
make terraform_apply
```

Esse alvo executa:

- `terraform plan`
- `terraform apply`
- atualização do `kubeconfig` para o cluster `togglemaster_project-cluster`

Se quiser consultar os endpoints gerados pelo Terraform depois do `apply`:

```bash
terraform -chdir=terraform/main output
```

### 4. Publicar imagens

O caminho preferencial é o GitHub Actions, que faz:

- build
- testes
- análise estática
- scans de segurança
- push da imagem
- atualização de `gitops/<service>/values.yaml`

Para build manual:

```bash
make docker_build \
  ACCOUNT_ID=123456789012 \
  IMAGE_TAG=v1.0.0 \
  AWS_PROFILE=fiapaws
```

### 5. Validar o acesso externo

Depois do `terraform_apply`, o acesso externo passa pelo LoadBalancer do `ingress-nginx`.

Exemplos de endpoints:

- `http://<LOADBALANCER>/auth-service`
- `http://<LOADBALANCER>/flag-service`
- `http://<LOADBALANCER>/targeting-service`
- `http://<LOADBALANCER>/evaluation-service`
- `http://<LOADBALANCER>/analytics-service`
- `http://<LOADBALANCER>/argocd`

Para descobrir o endpoint público:

```bash
kubectl get svc -A
kubectl get ingress -A
```

Ou, se o Terraform já estiver aplicado:

```bash
terraform -chdir=terraform/main output load_balancer_url
terraform -chdir=terraform/main output argocd_url
terraform -chdir=terraform/main output service_urls
```

### 6. Inicializar dados e executar testes

```bash
make init_2.1 CLUSTER_ENDPOINT=<LOADBALANCER> API_KEY_MASTER=<MASTER_KEY>
make init_2.2 CLUSTER_ENDPOINT=<LOADBALANCER> API_KEY=<API_KEY>
make init_2.3 CLUSTER_ENDPOINT=<LOADBALANCER> API_KEY=<API_KEY>
make test_all CLUSTER_ENDPOINT=<LOADBALANCER>
```

## CI e GitOps

Os workflows em `.github/workflows/` seguem este padrão de execução:

- `pull_request`
- `workflow_dispatch`
- `push` na `main`

As pipelines fazem build, testes, análise estática e scans de segurança. Em execuções na `main`, também publicam a imagem no ECR e atualizam o `gitops/<service>/values.yaml`.

No lado de CD:

- cada serviço possui um chart Helm em `gitops/<service>`
- o ArgoCD é instalado via Terraform
- o app raiz sincroniza [gitops/app-of-apps/applicationset.yaml](/home/william/Documentos/pos-graduacao/toggle_master_FIAP/gitops/app-of-apps/applicationset.yaml)
- a sincronização automática aplica as mudanças no cluster

## Observações

- O `enabled: true` dos charts é atualizado pela pipeline quando a imagem é publicada com sucesso.
- O Terraform controla a infraestrutura e a instalação do ArgoCD.
- Os workloads dos serviços são aplicados pelo ArgoCD a partir do conteúdo da pasta `gitops/`.
