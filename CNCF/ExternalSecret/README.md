# Emissary-ingress quick start
- Refer [https://artifacthub.io/packages/helm/external-secrets-operator/external-secrets]

## 1. Installation
### Add the Repo:
  ```bash
  helm repo add external-secrets https://charts.external-secrets.io
  helm repo update
  ```

### Install the Chart
  ```bash
  helm install external-secrets external-secrets/external-secrets
  ```