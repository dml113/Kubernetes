## OPA install with helm
- refer site [https://www.sktenterprise.com/bizInsight/blogDetail/dev/2578]

### 1. Get Repository Info
```bash
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
```

### 2. Install Chart
```bash
helm install -n gatekeeper-system gatekeeper gatekeeper/gatekeeper --create-namespace
```
