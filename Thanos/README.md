# Thanos Prometheus Configure
## Configuring Thanos Object Storage 
### 1. Once you have written your configuration save it to a file. Here’s an example:
```bash
cat <<EOF > objstore.yml
type: s3
config:
  bucket: thanos-gmst-bucket
  endpoint: s3.ap-northeast-3.amazonaws.com
  access_key: AKIATCKARK6C6EWHGUI2
  access_key: TXilroUeGShOF/ai6qeqyvo+3kuhFlPYGSx5XENg
EOF
```
### 2. You can use the following command to create a secret called thanos-objstore-config inside your cluster in the monitoring namespace.
```bash
kubectl create secret generic thanos-objstore -n monitoring --from-file=objstore.yml -o yaml --dry-run=client | kubectl apply -f -
```

### 3. Then you can specify this secret inside the Thanos field of the Prometheus spec as mentioned.
```bash
cat > prometheus.values.yaml << EOF
prometheus:
  prometheusSpec:
    thanos:
      image: quay.io/thanos/thanos:v0.28.1
      objectStorageConfig:
        name: thanos-objstore
        key: objstore.yml
  thanosService:
    enabled: true
    clusterIP: ''
  thanosServiceMonitor:
    enabled: true
EOF
```

### 4. Install prometheus using help with the values file you created above.
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring -f prometheus.values.yaml
```

### 5. Now you can deploy Thanos to collect metric.
```bash
helm install thanos oci://registry-1.docker.io/bitnamicharts/thanos -n monitoring --create-namespace \
--set queryFrontend.service.type=LoadBalancer \
--set query.dnsDiscovery.sidecarsNamespace=monitoring \
--set query.dnsDiscovery.sidecarsService=kube-prometheus-stack-thanos-discovery \
--set query.dnsDiscovery.enabled=true \
--set query.enabled=true
```
