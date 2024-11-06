# Istio Document Guide

## Circuit Breaking Setting

### If you have enabled automatic sidecar injection, deploy the httpbin service:
    ```bash
    kubectl apply -f samples/httpbin/httpbin.yaml
    ```
 - Otherwise, you have to manually inject the sidecar before deploying the httpbin application:
   ```bash
   kubectl apply -f <(istioctl kube-inject -f samples/httpbin/httpbin.yaml)
   ```
## Configuring the circuit breaker

### Create a destination rule to apply circuit breaking settings when calling the httpbin service:
    ```bash
    kubectl apply -f - <<EOF
    apiVersion: networking.istio.io/v1
    kind: DestinationRule
    metadata:
      name: httpbin
    spec:
      host: httpbin
      trafficPolicy:
        connectionPool:
          tcp:
            maxConnections: 1
          http:
            http1MaxPendingRequests: 1
            maxRequestsPerConnection: 1
        outlierDetection:
          consecutive5xxErrors: 1
          interval: 1s
          baseEjectionTime: 3m
          maxEjectionPercent: 100
    EOF
    ```
