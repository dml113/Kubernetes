# Dynamic Provisioning

- EFS의 Access Point가 새로 생성되어 Pod에 붙는 방식
- uid, gid 등 POSIX user와 관련해서 권한이 없는 오류가 자주 발생했었음

[Examples on Github](https://github.com/kubernetes-sigs/aws-efs-csi-driver/tree/master/examples/kubernetes/dynamic_provisioning)