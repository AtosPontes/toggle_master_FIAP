# Projeto ToggleMaster Fase 3

## Visão Geral

Este projeto implementa a plataforma ToggleMaster da PósTech FIAP com microsserviços locais, infraestrutura AWS provisionada via Terraform e entrega em EKS usando GitOps com ArgoCD.

O fluxo atual do repositório é:

1. Terraform cria a infraestrutura AWS e os recursos base do cluster.
2. O módulo [terraform/main/modules/argocd/main.tf](/home/william/Documentos/pos-graduacao/toggle_master_FIAP/terraform/main/modules/argocd/main.tf) instala o ArgoCD.
3. O ArgoCD sincroniza o app raiz em [gitops/app-of-apps/applicationset.yaml](/home/william/Documentos/pos-graduacao/toggle_master_FIAP/gitops/app-of-apps/applicationset.yaml), que cria as `Applications` dos 5 serviços.
4. Os charts Helm em `gitops/<service>` aplicam `Deployment`, `Service`, `Ingress`, HPA e jobs de init quando habilitados.

Nao existe mais fluxo ativo baseado em `apps/kubernetes`. O deploy atual do projeto e Terraform + ArgoCD + Helm.

## Servicos

- `auth-service`: Go + PostgreSQL.
- `flag-service`: Python + PostgreSQL.
- `targeting-service`: Python + PostgreSQL.
- `evaluation-service`: Go + Redis + SQS.
- `analytics-service`: Python + DynamoDB + SQS.

## Estrutura Principal

- `apps/local/`: codigo-fonte dos microsservicos.
- `terraform/bootstrap/tf-backend/`: bootstrap do bucket S3 do backend remoto do Terraform.
- `terraform/main/`: infraestrutura principal.
- `terraform/main/modules/argocd/`: instalacao do ArgoCD e app raiz.
- `gitops/`: charts Helm e app-of-apps do ArgoCD.
- `.github/workflows/`: pipelines de CI por microsservico.

## Como Executar

Todos os comandos devem ser executados na raiz do projeto.

### 1. Criar o bucket do backend Terraform

```bash
make terraform_backend_bootstrap
```

Se quiser sobrescrever profile ou bucket:

```bash
make terraform_backend_bootstrap AWS_PROFILE=fiapaws TFSTATE_BUCKET=toggle-master-tfstate
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

Esse alvo roda `plan`, `apply` em `terraform/main` e atualiza o `kubeconfig` do cluster `togglemaster_project-cluster`.

### 4. Publicar imagens

O caminho preferencial e o CI no GitHub Actions, que faz build, testes, scans e atualiza `gitops/<service>/values.yaml`.

Para build manual:

```bash
make docker_build ACCOUNT_ID=123456789012 IMAGE_TAG=v1.0.0 AWS_PROFILE=fiapaws
```

### 5. Validar o acesso externo

Depois do `terraform_apply`, o acesso externo passa pelo LoadBalancer do `ingress-nginx`.

Exemplos:

- `http://<LOADBALANCER>/auth-service`
- `http://<LOADBALANCER>/flag-service`
- `http://<LOADBALANCER>/targeting-service`
- `http://<LOADBALANCER>/evaluation-service`
- `http://<LOADBALANCER>/analytics-service`
- `http://<LOADBALANCER>/argocd`

Para descobrir o endpoint:

```bash
kubectl get svc -A
kubectl get ingress -A
```

### 6. Inicializar dados e testar

```bash
make init_2.1 CLUSTER_ENDPOINT=<LOADBALANCER> API_KEY_MASTER=<MASTER_KEY>
make init_2.2 CLUSTER_ENDPOINT=<LOADBALANCER> API_KEY=<API_KEY>
make init_2.3 CLUSTER_ENDPOINT=<LOADBALANCER> API_KEY=<API_KEY>
make test_all CLUSTER_ENDPOINT=<LOADBALANCER>
```

## CI e GitOps

Os workflows em `.github/workflows/` seguem o padrao:

- `pull_request`
- `workflow_dispatch`
- `push` na `main`

As pipelines fazem build, testes, analise estatica, scans de seguranca e, na `main`, publicam imagem e atualizam `gitops/<service>/values.yaml`.

No lado de CD:

- cada servico possui um chart Helm em `gitops/<service>`;
- o ArgoCD e instalado via Terraform;
- o app raiz sincroniza [gitops/app-of-apps/applicationset.yaml](/home/william/Documentos/pos-graduacao/toggle_master_FIAP/gitops/app-of-apps/applicationset.yaml);
- a sincronizacao automatica aplica as mudancas no cluster.
