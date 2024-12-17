## Grafana install with helm
- refer site [https://grafana.com/docs/grafana/latest/setup-grafana/installation/helm/]

### 1. Get Repository Info
```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

### 2. Install Chart
```bash
helm install prometheus prometheus-community/prometheus
```
  - To install Grafna in Grafana Namespace:
    ```bash
     helm install my-grafana grafana/grafana -n grafana
    ```
