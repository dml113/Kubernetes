### Set to your own value
``` sh
cluster=skills-cluster
policy=policy arn 입력
```

### Create accound
```sh
eksctl create iamserviceaccount --cluster $cluster --attach-policy-arn $policy --namespace <namespace name> --name secret-role --approve
```

### Verify that the commands below are generated well
```sh
kubectl get sa -n <namespace name>
```
