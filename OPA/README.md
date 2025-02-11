## OPA install with helm
- refer site [https://artifacthub.io/packages/helm/opa-kube-mgmt/opa-kube-mgmt]

### 1. Get Repository Info
```bash
helm repo add opa https://open-policy-agent.github.io/kube-mgmt/charts
helm repo update
```

### 2. Install Chart
```bash
helm upgrade -i -n opa --create-namespace opa opa/opa-kube-mgmt
```

### (Option) You can download the bundle and inspect it yourself:
```bash
mkdir example && cd example
curl -s -L https://www.openpolicyagent.org/bundles/kubernetes/admission | tar xzv
```
