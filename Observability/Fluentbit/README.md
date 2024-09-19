

## fluentbit 배포

fluentbit를 daemonset으로 배포합니다. 이는 아마존에서 제공해주는 기본 설정을 사용하며, 실제로는 커스텀하여 사용해야 합니다.

create namespace
```
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cloudwatch-namespace.yaml
```

create configmap
```
ClusterName=<my-cluster-name>
RegionName=<my-cluster-region>
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
kubectl create configmap fluent-bit-cluster-info \
--from-literal=cluster.name=${ClusterName} \
--from-literal=http.server=${FluentBitHttpServer} \
--from-literal=http.port=${FluentBitHttpPort} \
--from-literal=read.head=${FluentBitReadFromHead} \
--from-literal=read.tail=${FluentBitReadFromTail} \
--from-literal=logs.region=${RegionName} -n amazon-cloudwatch
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
--name=fluent-bit \
--attach-policy-arn=arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy \
--override-existing-serviceaccounts \
--approve
```

download `fluent-bit.yaml` file
```
wget https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluent-bit/fluent-bit.yaml -o fluent-bit.yaml
```

modify `fluent-bit.yaml`
- 위에서 Service Account for IAM Role을 생성했으니, Yaml 파일에서 Service Account 내용을 삭제합니다.
- 삭제한뒤 수정된 yaml파일로 배포를 수행합니다.