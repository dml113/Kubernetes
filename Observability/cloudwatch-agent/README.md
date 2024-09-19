
## Cloudwatch agent 배포

### Namespace
create namespace
```
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cloudwatch-namespace.yaml
```

### ISRA
create service account
```
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-serviceaccount.yaml
```

associate oidc
```
eksctl utils associate-iam-oidc-provider \
--cluster <your-cluster-name> \
--region <region-code> \
--approve
```

create irsa
```
eksctl create iamserviceaccount \
--cluster=<your-cluster-name> \
--region=<region-code> \
--namespace=amazon-cloudwatch \
--name=cloudwatch-agent \
--attach-policy-arn=arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy \
--override-existing-serviceaccounts \
--approve
```

### configmap

download configmap yaml file
```
wget https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-configmap.yaml -o cwagent-configmap.yaml
```

modify configmap yaml file
- modify `{{cluster-name}}` to your cluster name
- then, deploy configmap to kubernetes.

### damemonset

download daemonset yaml file
```
wget https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-daemonset.yaml -o cwagent-daemonset.yaml
```

modify daemonset yaml file
- add tolerations
    ```
    tolerations:
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      - operator: "Exists"
        effect: "NoExecute"
      - operator: "Exists"
        effect: "NoSchedule"
    ```
- then, deploy daemonset yaml to kubernetes.