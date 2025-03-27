## Jenkins install with helm
- refer site [https://artifacthub.io/packages/helm/jenkinsci/jenkins]

### 1. Get Repository Info
```bash
helm repo add jenkins https://charts.jenkins.io
helm repo update
```

### 2. Install Chart
```bash
helm install jenkins jenkins/jenkins
```
  - To install Jenkins in jenkins Namespace:
    ```bash
    helm install jenkins jenkins/jenkins -n jenkins
    ```

  - Since version 5.6.0 the chart is available as an OCI image and can be installed using:
    ```bash
    helm install jenkins oci://ghcr.io/jenkinsci/helm-charts/jenkins -n jenkins
    ```
