### Nginx Controller Install
```sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx --version 4.10.0 --namespace ingress-nginx --create-namespace -f nginx-ingress_deploy.yaml
```