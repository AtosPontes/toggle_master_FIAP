# Projeto Togglemaster fase 3

### Visão Geral do Projeto

Este projeto foi desenvolvido como parte do **desafio bimestral da PósTech FIAP**.

A solução utiliza uma **aplicação local fornecida pela FIAP**, cujas imagens são geradas por pipelines no **GitHub Actions**, publicadas em repositórios **Amazon ECR** e posteriormente **deployadas em um cluster Kubernetes (EKS)** por meio de **GitOps com ArgoCD**.

Todo o cluster Kubernetes, bem como a infraestrutura associada, foi **provisionado via Terraform**, garantindo uma infraestrutura totalmente **automatizada, documentada, versionada no GitHub e reproduzível**.  
Além da infraestrutura base, o Terraform também instala recursos da camada Kubernetes, incluindo **Ingress NGINX**, **ArgoCD**, namespaces e secrets iniciais necessários para o fluxo da **Fase 3**.

---

### Arquitetura de Serviços
De forma simplificada, o projeto é composto pelos seguintes serviços:

---

### Auth-Service

Serviço responsável pela autenticação do projeto **ToggleMaster**.  
É responsável pela **criação e validação de chaves de API**, garantindo o controle de acesso entre os serviços.

- **Aplicação:** Go  
- **Banco de dados:** Amazon RDS (PostgreSQL)

---

### Flag-Service

Serviço responsável pelo **CRUD (Create, Read, Update, Delete)** das *feature flags* do projeto **ToggleMaster**.  
Gerencia as definições e configurações das flags disponíveis no sistema.

- **Aplicação:** Python  
- **Banco de dados:** Amazon RDS (PostgreSQL)

---

### Targeting-Service

Serviço responsável pelas **regras de segmentação (targeting)** das *feature flags*.  
Permite a definição de regras mais complexas, como por exemplo:
- "50% dos usuários"
- **Aplicação:** Python  
- **Banco de dados:** Amazon RDS (PostgreSQL)

---

### Evaluation-Service

Serviço de **avaliação das feature flags**, considerado o **hot path** do projeto **ToggleMaster**.  
É o **único endpoint exposto aos clientes finais**, como aplicações mobile ou web, sendo responsável por retornar rapidamente o estado de uma feature flag.

- **Aplicação:** Go  
- **Banco de dados:** Amazon ElastiCache for Redis  
- **Fila:** Amazon SQS (entrada)

---

### Analytics-Service

Serviço responsável pela **análise e processamento de eventos (analytics)** do projeto **ToggleMaster**.  
Funciona como um **worker de backend**, não possuindo API pública (exceto o endpoint `/health`).

- **Aplicação:** Python  
- **Banco de dados:** Amazon DynamoDB  
- **Fila:** Amazon SQS (saída)

---
---

# 🚀 Como Executar o Projeto

> **Importante:**  
> Todos os comandos a seguir devem ser executados **na raiz do projeto**.

### 0. Criar previamente o bucket do backend Terraform

Antes de executar o projeto principal, é necessário provisionar o bucket S3 usado pelo backend remoto do Terraform.

Configuração atual do backend:

- `bucket = "toggle-master-tfstate"`
- `key = "dev/terraform.tfstate"`
- `region = "us-east-1"`

Esse bootstrap foi isolado em um Terraform separado dentro do próprio repositório:

- `terraform/bootstrap/tf-backend`

Para criar o bucket usando esse bootstrap:

```bash
make terraform_backend_bootstrap
```

Se quiser usar outro profile ou outro nome de bucket:

```bash
make terraform_backend_bootstrap AWS_PROFILE=fiapaws TFSTATE_BUCKET=toggle-master-tfstate
```

Arquivos principais desse bootstrap:

- `terraform/bootstrap/tf-backend/provider.tf`
- `terraform/bootstrap/tf-backend/main.tf`
- `terraform/bootstrap/tf-backend/variables.tf`

Se o bucket não existir, o `terraform init` e os comandos de `terraform apply` do projeto principal não irão funcionar.

### 1. Preparar as variáveis do Terraform

Preencha o arquivo `terraform/main/terraform.tfvars` com os valores obrigatórios, incluindo:

- `aws_account_id`
- `db_user`
- `db_password`
- `master_key`
- `service_api_key`
- `gitops_repo_url`

Além disso, habilite o ArgoCD:

```hcl
enable_argocd = true
```

### 2. Aplicar a infraestrutura base

O `apply` cria a infraestrutura AWS, instala o **Ingress NGINX**, instala o **ArgoCD** e registra um app raiz para o fluxo GitOps.

```bash
make terraform_apply
```

### 3. Publicar as primeiras imagens das aplicações

Após o provisionamento da infraestrutura, publique a primeira imagem de cada microsserviço no ECR por merge na `main` ou por `workflow_dispatch`.

Cada chart Helm em `gitops/<service>` começa com:

- `enabled: false`
- `image.tag: ""`

Na primeira release de cada microsserviço, a pipeline:

- publica a imagem no ECR
- atualiza `gitops/<service>/values.yaml`
- altera `enabled: true`
- define a `image.tag`

Com isso, o ArgoCD sincroniza o serviço automaticamente, sem necessidade de um segundo `terraform apply`.

### 4. Validar o ambiente

Após o `terraform apply`, o acesso externo acontece por um único **LoadBalancer** do `ingress-nginx`.

Exemplos de acesso:

- `http://<LOADBALANCER>/auth-service`
- `http://<LOADBALANCER>/flag-service`
- `http://<LOADBALANCER>/targeting-service`
- `http://<LOADBALANCER>/evaluation-service`
- `http://<LOADBALANCER>/analytics-service`
- `http://<LOADBALANCER>/argocd`

Para descobrir o endpoint do balanceador:

```bash
kubectl get svc -A
kubectl get ingress -A
```

### 5. Inicializar os dados funcionais da aplicação

Depois que os serviços estiverem disponíveis, utilize os alvos abaixo para criar a API Key interna e popular os dados de exemplo:

```bash
make init_2.1
make init_2.2
make init_2.3
```

E para testes de saúde:

```bash
make test_all
```

---

## CI & DevSecOps

Após a etapa de bootstrap da infraestrutura, o projeto utiliza pipelines por microsserviço no GitHub Actions para build, testes, segurança e atualização do GitOps.

### Workflows e ações reutilizáveis

- `.github/workflows/template-ci-go.yml` (template para serviços Go)
- `.github/workflows/template-ci-python.yml` (template para serviços Python)
- `.github/actions/ci-go-build/action.yml`
- `.github/actions/ci-go-lint/action.yml`
- `.github/actions/ci-go-sast/action.yml`
- `.github/actions/ci-python-build/action.yml`
- `.github/actions/ci-python-lint/action.yml`
- `.github/actions/ci-python-sast/action.yml`
- `.github/workflows/auth-service.yml`
- `.github/workflows/flag-service.yml`
- `.github/workflows/targeting-service.yml`
- `.github/workflows/evaluation-service.yml`
- `.github/workflows/analytics-service.yml`

### Triggers dos pipelines

Cada workflow de serviço roda em:

- `workflow_dispatch`
- `pull_request`
- `push` na branch `main`

Com `paths` por serviço para evitar execução desnecessária e com permissões explícitas:

- `contents: write`

### Estágios de CI implementados

1. **Build & Unit Test**
   - Go: `go test ./...`
   - Python: `pytest` (quando há arquivos de teste)
2. **Linter / Static Analysis**
   - Go: `golangci-lint`
   - Python: `flake8` e `pylint --errors-only`
3. **Security Scan (SCA + SAST)**
   - SCA: Trivy em filesystem com bloqueio de severidade `CRITICAL`
   - SAST Go: gosec
   - SAST Python: bandit
4. **Docker Build, Scan and Push**
   - Build da imagem
   - Scan da imagem com Trivy (bloqueio `CRITICAL`)
   - Push para ECR na `main`
   - Atualização automática de `gitops/<service>/values.yaml`

### Secrets necessários no GitHub

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN` (necessário quando as credenciais são temporárias)

---

## CD & GitOps (ArgoCD)

### O que foi implementado

1. **GitOps no monorepo**
   - Charts Helm em `gitops/` para os 5 microsserviços.
   - Cada aplicação possui seu próprio `Ingress`, `Deployment`, `Service` e recursos auxiliares quando necessário.
2. **Instalação do ArgoCD via Terraform**
   - O módulo `terraform/main/modules/argocd` instala o ArgoCD no namespace `argocd`.
   - O ArgoCD é exposto pelo mesmo LoadBalancer do `ingress-nginx`, através do path `/argocd`.
3. **App raiz + ApplicationSet**
   - O Terraform cria apenas um app raiz do ArgoCD.
   - Esse app sincroniza `gitops/app-of-apps/applicationset.yaml`, que cria automaticamente as 5 `Applications`.
4. **Atualização automática de imagem pelo CI**
   - Após build/push da imagem no ECR, o CI atualiza:
   - `gitops/<service>/values.yaml`
   - Em seguida, realiza commit/push na `main` para o ArgoCD sincronizar.

### Variáveis Terraform

No `terraform/main/terraform.tfvars`, configure:

```hcl
enable_argocd          = true
gitops_repo_url        = "https://github.com/AtosPontes/toggle_master_FIAP.git"
gitops_target_revision = "main"
```

### Observações operacionais

- Os namespaces de aplicação continuam sendo criados pelo módulo Kubernetes.
- Os jobs de inicialização de banco são aplicados pelo próprio fluxo GitOps/Helm quando o chart é habilitado.
- O fluxo esperado passa a ser: alteração no microsserviço -> merge na `main` -> pipeline atualiza `values.yaml` -> ArgoCD sincroniza.
