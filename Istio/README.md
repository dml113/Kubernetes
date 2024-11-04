## Download Istioctl

### 1. Go to the Istio release page to download the installation file for your OS, or download and extract the latest release automatically (Linux or macOS):
### Refer
- [https://github.com/istio/istio/releases/tag/1.23.3]
- [https://istio.io/latest/docs/setup/additional-setup/download-istio-release/]

```bash
curl -L https://istio.io/downloadIstio | sh -
```

### 2. Move to the Istio package directory:
```bash
cd istio-1.23.3
```

### 3. Add the istioctl client to your path (Linux or macOS):
```bash
export PATH=$PWD/bin:$PATH
```

## Setting Istio
### 1. Install Istio using the profile you want:
### Refer
- [https://istio.io/latest/docs/setup/additional-setup/config-profiles/]
```bash
istioctl install --set profile=demo
```

### 2. Add a namespace label to instruct Istio to automatically inject Envoy sidecar proxies when you deploy your application later:
```bash
kubectl label namespace <namespace name> istio-injection=enabled
```

## Addon
- Kiali Install
  ``` bash
  kubectl apply -f https://raw.githubusercontent.com/istio/istio/<istio-release-verison>/samples/addons/kiali.yaml
  ```
- Prometheus Install
  ``` bash
  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/prometheus.yaml
  ```
