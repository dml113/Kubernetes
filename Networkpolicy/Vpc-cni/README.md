
Please refer to official document

- https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/security-groups-for-pods.html
- https://dobby-isfree.tistory.com/201

### Enable the parameters to assign prefixes to the network interface of the Amazon VPC CNI DaemonSet.
  ```bash
  kubectl set env daemonset aws-node -n kube-system ENABLE_PREFIX_DELEGATION=true
  ```
### Enable Assign to pod as ipv6.
  ```bash
  kubectl set env daemonset aws-node -n kube-system ENABLE_IPv4=false
  kubectl set env daemonset aws-node -n kube-system ENABLE_IPv6=true
  ```
