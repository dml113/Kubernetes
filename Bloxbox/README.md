## Prometheus install with helm
- refer site [https://artifacthub.io/packages/helm/prometheus-community/prometheus-blackbox-exporter]

### 1. Get Repository Info
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### 2. Install Chart
```bash
helm install bloxbox prometheus-community/prometheus-blackbox-exporter
```
  - To install Prometheus in Prometheus Namespace:
    ```bash
     helm install bloxbox prometheus-community/prometheus-blackbox-exporter -n blackbox
    ```
