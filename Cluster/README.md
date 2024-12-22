### Specify Variables
```sh
export CLUSTER_NAME="eks-clusterA"
export K8S_VERSION="1.31"
export REGION_CODE="ap-northeast-2"
export ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

export PUBLIC_SUBNET_A=<PUBLIC_SUBNET_A_NAME>
export PUBLIC_SUBNET_B=<PUBLIC_SUBNET_B_NAME>
export PRIVATE_SUBNET_A=<PRIVATE_SUBNET_A_NAME>
export PRIVATE_SUBNET_B=<PRIVATE_SUBNET_B_NAME>

sed -i "s/PUBLIC_SUBNET_A/$PUBLIC_SUBNET_A/g" cluster.yaml
sed -i "s/PUBLIC_SUBNET_B/$PUBLIC_SUBNET_B/g" cluster.yaml
sed -i "s/PRIVATE_SUBNET_A/$PRIVATE_SUBNET_A/g" cluster.yaml
sed -i "s/PRIVATE_SUBNET_B/$PRIVATE_SUBNET_B/g" cluster.yaml

```

### If you want to change the cluster from public to private, use the command below
```sh
eksctl utils update-cluster-endpoints --name=<cluster name> --private-access=true --public-access=false --approve
```
