## Kong install with helm
- refer site [https://artifacthub.io/packages/helm/prometheus-community/prometheus-blackbox-exporter]

### 1. Apply to Kong crd
```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml
```

### 2. Deploy Kong Gateway 
```bash
echo "
---
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
 name: kong
 annotations:
   konghq.com/gatewayclass-unmanaged: 'true'

spec:
 controllerName: konghq.com/kic-gateway-controller
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
 name: kong
spec:
 gatewayClassName: kong
 listeners:
 - name: proxy
   port: 80
   protocol: HTTP
   allowedRoutes:
     namespaces:
        from: All
" | kubectl apply -f -
```
### 3. Get helm repo
```bash
helm repo add kong https://charts.konghq.com
helm repo update
```

### 2. Install 
```bash
helm install kong kong/ingress
```
  - To install kong in kong Namespace:
    ```bash
    helm install kong kong/ingress -n kong
    ```
