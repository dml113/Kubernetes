### kyberno install
```sh
kubectl create -f https://github.com/kyverno/kyverno/releases/download/v1.9.0/install.yaml
helm repo add kyverno https://kyverno.github.io/kyverno/
helm install kyverno kyverno/kyverno -n kyverno --create-namespace --set replicaCount=3
helm install kyverno-policies kyverno/kyverno-policies -n kyverno
```
