# Keda Deploying with Helm
## Install

### Refer
-  [https://keda.sh/docs/2.14/scalers/]

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
   - If your want custom serivceaccount:
     ```bash
     helm install keda kedacore/keda --namespace keda --set serviceAccount.operator.create=false --set serviceAccount.operator.name=keda-operator
     ```
