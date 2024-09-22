### If you want to change the cluster from public to private, use the command below
```sh
eksctl utils update-cluster-endpoints --name=<cluster name> --private-access=true --public-access=false --approve
```
