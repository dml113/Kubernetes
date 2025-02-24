# Install Crossplane
- Refer [https://docs.crossplane.io/latest/getting-started/provider-aws/]

## 1. Install the Crossplane Helm chart 
### Enable the Crossplane Helm Chart repository:
  ```bash
  helm repo add \
  crossplane-stable https://charts.crossplane.io/stable
  helm repo update
  ```

### Install the Crossplane components using helm install:
  ```bash
  helm install crossplane \
  crossplane-stable/crossplane \
  --namespace crossplane-system \
  --create-namespace
  ```

### AWS credentials file
  ```bash
  [default]
  aws_access_key_id = 
  aws_secret_access_key =
  ```


### Use the --from-file= argument to set the value to the contents of the aws-credentials.txt file.
  ```bash
  kubectl create secret \
  generic aws-secret \
  -n crossplane-system \
  --from-file=creds=./aws-credentials.txt
  ```

### Apply the ProviderConfig with the this Kubernetes configuration file:
  ```bash
  cat <<EOF | kubectl apply -f -
  apiVersion: aws.upbound.io/v1beta1
  kind: ProviderConfig
  metadata:
    name: default
  spec:
    credentials:
      source: Secret
      secretRef:
        namespace: crossplane-system
        name: aws-secret
        key: creds
  EOF
  ```
