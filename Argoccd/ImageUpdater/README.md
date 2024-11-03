## ArgoCD Annotation List
- Refer[https://argocd-image-updater.readthedocs.io/en/stable/basics/update-strategies/]

## 1. Helm Repo Add 
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update argo
```

## 2. Argocd Install
```bash
helm install argocd-image-updater argo/argocd-image-updater \
    --namespace argocd \
    --values values.yaml
```
