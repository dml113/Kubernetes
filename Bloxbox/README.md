## Blackbox install with helm
- refer site [https://artifacthub.io/packages/helm/prometheus-community/prometheus-blackbox-exporter]

### 1. Get Repository Info
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### 2. Install Chart
```bash
helm install blackbox prometheus-community/prometheus-blackbox-exporter
```
  - To install blackbox in blackbox Namespace:
    ```bash
    helm install blackbox prometheus-community/prometheus-blackbox-exporter -n blackbox
    ```
## Blackbox Add Target 
```bash
curl "blackbox-prometheus-blackbox-exporter.blackbox.svc.cluster.local:9115/probe?module=http_2xx&target=IP"
```
