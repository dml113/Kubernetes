# Pod with volume using AWS EFS

## Create service account using AWS IAM

``` shell
curl -o efs-csi-driver-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/master/docs/iam-policy-example.json

aws iam create-policy \
    --policy-name <policy name> \
    --policy-document file://efs-csi-driver-policy.json

cat >efs-csi-controller-sa.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: efs-csi-controller-sa
  namespace: kube-system
EOF

kubectl apply -f efs-csi-controller-sa.yaml

namespace=kube-system
service_account=efs-csi-controller-sa
account_id=$(aws sts get-caller-identity --query "Account" --output text)
oidc_provider=$(aws eks describe-cluster --name <cluster name> --region <region code> --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")

cat >trust-relationship.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$account_id:oidc-provider/$oidc_provider"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "$oidc_provider:aud": "sts.amazonaws.com",
          "$oidc_provider:sub": "system:serviceaccount:$namespace:$service_account"
        }
      }
    }
  ]
}
EOF

aws iam create-role --role-name <role name> --assume-role-policy-document file://trust-relationship.json --description "efs csi controller sa role"

aws iam attach-role-policy --role-name <role name> --policy-arn=arn:aws:iam::$account_id:policy/<policy name>

kubectl annotate serviceaccount -n $namespace $service_account eks.amazonaws.com/role-arn=arn:aws:iam::$account_id:role/<role name>
```

[AWS Documentation](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/efs-csi.html#efs-create-iam-resources)

## Install EFS driver in Kubernetes

``` shell
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/

helm repo update

helm upgrade -i aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver \
    --namespace kube-system \
    --set image.repository=602401143452.dkr.ecr.<region code>.amazonaws.com/eks/aws-efs-csi-driver \
    --set controller.serviceAccount.create=false \
    --set controller.serviceAccount.name=efs-csi-controller-sa
```

EFS CSI Driver의 컨테이너 이미지 정보는 [반드시 여기를 확인해야 함.](https://marcus16-kang.github.io/aws-resources-example/Containers/EKS/12-using-efs/#:~:text=You%20should%20check,AWS%20Documentation)

[AWS Documentation](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/efs-csi.html#efs-install-driver)

## Using EFS

> EFS와 EKS node간에 Security group(반드시 EKS의 primary security group) 등 네트워크 설정이 잘 되었는지 확인해야 함
>
> Managed node group을 사용할 경우 OS에 efs-utils가 이미 설정되어 있어 문제가 없으나, 그 이외에는 반드시 OS에 efs-utils가 있어야 함
>
> Dynamic provisioning의 경우, uid, gid 등 POSIX 설정에서 오류가 자주 발생함

[AWS EFS CSI Driver Examples](https://github.com/kubernetes-sigs/aws-efs-csi-driver/tree/master/examples/kubernetes)

[AWS Documentation](https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html#efs-sample-app)