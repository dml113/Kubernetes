## ArgoCD Annotation List
```bash
argocd-image-updater.argoproj.io/image-list: org/app=950274644703.dkr.ecr.ap-northeast-2.amazonaws.com/skills-repo/backend
argocd-image-updater.argoproj.io/org_app.update-strategy: latest or semver or digest
(option) argocd-image-updater.argoproj.io/org_app.pull-secret: ext:/scripts/auth1.sh
```

### Refer
- [https://argocd-image-updater.readthedocs.io/en/stable/basics/update-strategies/]


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
