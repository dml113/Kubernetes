## Keptn install with helm
- refer site [https://keptn.sh/stable/docs/installation/]

### 1. Get Repository Info
```bash
helm repo add keptn https://charts.lifecycle.keptn.sh
helm repo update
```

### 2. Install Chart
```bash
helm upgrade --install keptn keptn/keptn \
   -n keptn-system --create-namespace --wait
```

## 3. add annotation to Namespace 
```bash
kubectl annotate ns default keptn.sh/lifecycle-toolkit=enabled
```

## (option) ketpn cli install
```bash
curl -sL https://get.keptn.sh | bash
```
