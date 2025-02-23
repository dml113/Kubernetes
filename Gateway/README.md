## k8s Gateway 
- Refer site[https://gateway-api.sigs.k8s.io/]

### If you want to use Envoy Proxy:
```sh
helm install eg oci://docker.io/envoyproxy/gateway-helm --version v1.3.0 -n envoy-gateway-system --create-namespace
```
