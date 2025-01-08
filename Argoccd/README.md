## Argocd Install

### 1. Argocd values.yaml create
    cat <<EOF> values.yaml
    configs:
      params:
        server.insecure: true
    EOF

### 2. Argocd cli install
    curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    rm argocd-linux-amd64

### 3. Argocd Helm repo update
    helm repo add argo https://argoproj.github.io/argo-helm
    helm repo update argo

### 4. Argocd Helm Deploy
    helm install argocd argo/argo-cd \
        --create-namespace \
        --namespace argocd \
        --values values.yaml

### 5. Argocd Server Password Change
    kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    argocd login <argocd 주소>
    argocd account update-password
