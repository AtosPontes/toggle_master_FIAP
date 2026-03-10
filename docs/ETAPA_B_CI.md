# Etapa B — CI & DevSecOps

Esta etapa adiciona pipelines de CI para os 5 microsserviços via GitHub Actions.

## Workflows criados

- `.github/workflows/template-ci.yml` (workflow reutilizável com os 4 estágios comuns)
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

## Triggers

Cada workflow roda em:

- `pull_request`
- `push` na branch `main`

Com `paths` por serviço para evitar execução desnecessária.

Além disso, os workflows chamadores declaram permissões explícitas:

- `contents: read`
- `id-token: write`

Isso é necessário para permitir OIDC no job de push para ECR do workflow reutilizável.

## Estágios implementados

1. **Build & Unit Test**
   - Go: `go test ./...`
   - Python: `pytest` (executa apenas se houver arquivos de teste)

2. **Linter / Static Analysis**
   - Go: `golangci-lint` (executa sem bloquear o pipeline por dívida técnica legada)
   - Python: `flake8` (checagens críticas de sintaxe/runtime) e `pylint --errors-only`

3. **Security Scan (SCA + SAST)**
   - SCA: Trivy em filesystem com bloqueio de severidade `CRITICAL`
   - SAST Go: gosec (versão fixada para maior compatibilidade de execução)
   - SAST Python: bandit com bloqueio de alta severidade

4. **Docker Build & Push**
   - Build da imagem
   - Scan da imagem com Trivy (bloqueio `CRITICAL`)
   - Push para ECR no `push` para `main`, com tag `v1.0.0-<sha7>`

## Secrets necessários no GitHub

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN` (opcional; necessário em credenciais temporárias do AWS Academy)
