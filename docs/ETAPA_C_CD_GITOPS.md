# Etapa C — CD & GitOps (ArgoCD)

## O que foi implementado

1. **GitOps no monorepo**
   - Pasta `gitops/` com os manifestos dos 5 microsserviços.

2. **Instalação do ArgoCD via Terraform**
   - Módulo `modules/argocd` instala ArgoCD com Helm no namespace `argocd`.
   - Cria 5 recursos `Application` (um por microsserviço) com sync automático.

3. **Atualização automática de tag no CI**
   - Após push da imagem no ECR (somente `push` na `main`), o workflow atualiza:
     - `gitops/<service>/deployment.yaml`
   - Faz commit e push da alteração para a `main`.

## Variáveis Terraform

No `terraform.tfvars`, habilite:

```hcl
enable_argocd         = true
gitops_repo_url       = "https://github.com/AtosPontes/projeto_posgraduacao.git"
gitops_target_revision = "main"
```

## Observações

- Os namespaces de aplicação continuam sendo criados pelo módulo Kubernetes.
- Os `Jobs` de inicialização de banco continuam no fluxo operacional (`make k8s_up`) e não no sync contínuo do ArgoCD.
