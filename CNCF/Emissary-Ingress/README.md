# Emissary-ingress quick start
- Refer [https://www.getambassador.io/docs/emissary/latest/tutorials/getting-started]

## 1. Installation
### Add the Repo:
  ```bash
  helm repo add datawire https://app.getambassador.io
  helm repo update
  ```

### Create Namespace and Install:
  ```bash
  kubectl create namespace emissary && \
  kubectl apply -f https://app.getambassador.io/yaml/emissary/3.9.1/emissary-crds.yaml
 
  kubectl wait --timeout=90s --for=condition=available deployment emissary-apiext -n emissary-system
 
  helm install emissary-ingress --namespace emissary datawire/emissary-ingress && \
  kubectl -n emissary wait --for condition=available --timeout=90s deploy -lapp.kubernetes.io/instance=emissary-ingress
  ```

## 2. Routing traffic from the edge
### Start by creating a Listener resource for HTTP on port 8080:
  ```bash
  kubectl apply -f - <<EOF
  ---
  apiVersion: getambassador.io/v3alpha1
  kind: Listener
  metadata:
    name: emissary-ingress-listener-8080
    namespace: emissary
  spec:
    port: 8080
    protocol: HTTP
    securityModel: XFP
    hostBinding:
      namespace:
        from: ALL
  EOF
  ```

### Apply the YAML for the "Quote" service.
  ```bash
  kubectl apply -f https://app.getambassador.io/yaml/v2-docs/3.9.1/quickstart/qotm.yaml
  ```

### Generates the YAML for a Mapping to tell Emissary-ingress to route all traffic inbound to the /backend/ path to the quote Service.
  ```bash
  kubectl apply -f - <<EOF
  ---
  apiVersion: getambassador.io/v3alpha1
  kind: Mapping
  metadata:
    name: quote-backend
  spec:
    hostname: "*"
    prefix: /backend/
    service: quote
    docs:
      path: "/.ambassador-internal/openapi-docs"
  EOF
  ```

### Store the Emissary-ingress load balancer IP address to a local environment variable. You will use this variable to test access to your service.
  ```bash
  export LB_ENDPOINT=$(kubectl -n emissary get svc  emissary-ingress \
  -o "go-template={{range .status.loadBalancer.ingress}}{{or .ip .hostname}}{{end}}")
  ```

### Test the configuration by accessing the service through the Emissary-ingress load balancer:
  ```bash
  curl -i http://$LB_ENDPOINT/backend/
  ```
