# Install Crossplane
- Refer [https://docs.crossplane.io/latest/getting-started/provider-aws/]

## 1. Install the Crossplane Helm chart 
### Enable the Crossplane Helm Chart repository:
  ```bash
  helm repo add \
  crossplane-stable https://charts.crossplane.io/stable
  helm repo update
  ```

### Install the Crossplane components using helm install:
  ```bash
  helm install crossplane \
  crossplane-stable/crossplane \
  --namespace crossplane-system \
  --create-namespace
  ```

### AWS credentials file
  ```bash
  [default]
  aws_access_key_id = 
  aws_secret_access_key =
  ```
