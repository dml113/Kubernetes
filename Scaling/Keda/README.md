# Keda Deploying with Helm
## Install

### 1. Add Helm repo
  ```bash
  helm repo add kedacore https://kedacore.github.io/charts
  ```
### 2. Update Helm repo
  ```bash
  helm repo update
  ```
### 3. Install keda Helm chart
  ```bash
  helm install keda kedacore/keda --namespace keda --create-namespace
  ```
   - If your wn
