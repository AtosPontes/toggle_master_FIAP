# GitOps Manifests

This directory contains Kubernetes manifests managed by ArgoCD.

- `auth-service`
- `flag-service`
- `targeting-service`
- `evaluation-service`
- `analytics-service`

Each service folder contains:

- `deployment.yaml`
- `service.yaml`
- `hpa.yaml` (when applicable)
- `kustomization.yaml`

The CI workflow updates only the image line in `deployment.yaml` for the service that was built and pushed.
