### Container Insights Install
```
### region과 cluster name 변경
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluentd-quickstart-enhanced.yaml | sed "s/{{cluster_name}}/<cluster-name>/;s/{{region_name}}/<cluster-region>/" | kubectl apply -f -
