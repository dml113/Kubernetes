# Getting Started with Karpenter
- Refer Site [https://karpenter.sh/docs/getting-started/getting-started-with-karpenter/]

### 1. Set environment variables
After setting up the tools, set the Karpenter and Kubernetes version:
    ```sh
    export KARPENTER_NAMESPACE="kube-system"
    export KARPENTER_VERSION="1.1.1"
    ```
    
Then set the following environment variable:    
    ```sh
    export CLUSTER_NAME="<CLUSTER_NAME>"
    export K8S_VERSION="1.31"
    export AWS_PARTITION="aws"
    export AWS_DEFAULT_REGION="ap-northeast-2"
    export AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
    export TEMPOUT="$(mktemp)"
    ```

### Karpenter Cloudformation Deploy
``` sh
curl -fsSL https://raw.githubusercontent.com/aws/karpenter-provider-aws/v"${KARPENTER_VERSION}"/website/content/en/preview/getting-started/getting-started-with-karpenter/cloudformation.yaml  > "${TEMPOUT}" \
&& aws cloudformation deploy \
  --stack-name "Karpenter-${CLUSTER_NAME}" \
  --template-file "${TEMPOUT}" \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides "ClusterName=${CLUSTER_NAME}"
```

### IAM Role 생성
```sh
echo '{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}' > node-trust-policy.json

aws iam create-role \
    --role-name "KarpenterNodeRole-${CLUSTER_NAME}" \
    --assume-role-policy-document file://node-trust-policy.json

# policy 추가
aws iam attach-role-policy \
    --role-name "KarpenterNodeRole-${CLUSTER_NAME}" \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
```

###  AmazonEKS_CNI_Policy attach
```sh
aws iam attach-role-policy \
    --role-name "KarpenterNodeRole-${CLUSTER_NAME}" \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy   
```

### AmazonEC2ContainerRegistryReadOnly attach
```sh
aws iam attach-role-policy \
    --role-name "KarpenterNodeRole-${CLUSTER_NAME}" \
    --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
```

###  AmazonSSMManagedInstanceCore attach  
```sh
aws iam attach-role-policy \
    --role-name "KarpenterNodeRole-${CLUSTER_NAME}" \
    --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
```
### EC2 Instance Profile 생성
```sh
aws iam create-instance-profile \
    --instance-profile-name "KarpenterNodeInstanceProfile-${CLUSTER_NAME}"
aws iam add-role-to-instance-profile \
    --instance-profile-name "KarpenterNodeInstanceProfile-${CLUSTER_NAME}" \
    --role-name "KarpenterNodeRole-${CLUSTER_NAME}"    
```
### IAM Role 신뢰 관계 생성
```sh
cat << EOF > controller-trust-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/${OIDC_ENDPOINT#*//}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${OIDC_ENDPOINT#*//}:aud": "sts.amazonaws.com",
                    "${OIDC_ENDPOINT#*//}:sub": "system:serviceaccount:karpenter:karpenter"
                }
            }
        }
    ]
}
EOF
```
### Karpnter controller의 IAM Role 생성
```sh
aws iam create-role \
    --role-name KarpenterControllerRole-${CLUSTER_NAME} \
    --assume-role-policy-document file://controller-trust-policy.json
```

### Karpenter cotroller의 IAM Role의 Policy 생성
```sh
cat << EOF > controller-policy.json
{
    "Statement": [
        {
            "Action": [
                "ssm:GetParameter",
                "ec2:DescribeImages",
                "ec2:RunInstances",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeLaunchTemplates",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeInstanceTypeOfferings",
                "ec2:DescribeAvailabilityZones",
                "ec2:DeleteLaunchTemplate",
                "ec2:CreateTags",
                "ec2:CreateLaunchTemplate",
                "ec2:CreateFleet",
                "ec2:DescribeSpotPriceHistory",
                "pricing:GetProducts"
            ],
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "Karpenter"
        },
        {
            "Action": "ec2:TerminateInstances",
            "Condition": {
                "StringLike": {
                    "ec2:ResourceTag/Name": "*karpenter*"
                }
            },
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "ConditionalEC2Termination"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:${AWS_PARTITION}:iam::${AWS_ACCOUNT_ID}:role/KarpenterNodeRole-${CLUSTER_NAME}",
            "Sid": "PassNodeIAMRole"
        },
        {
            "Effect": "Allow",
            "Action": "eks:DescribeCluster",
            "Resource": "arn:${AWS_PARTITION}:eks:${AWS_REGION}:${AWS_ACCOUNT_ID}:cluster/${CLUSTER_NAME}",
            "Sid": "EKSClusterEndpointLookup"
        }
    ],
    "Version": "2012-10-17"
}
EOF
```
### IAM Role에 연결
```sh
aws iam put-role-policy \
    --role-name KarpenterControllerRole-${CLUSTER_NAME} \
    --policy-name KarpenterControllerPolicy-${CLUSTER_NAME} \
    --policy-document file://controller-policy.json
```
### EKS cluster의 서브넷에 태그 추가
```sh
for NODEGROUP in $(aws eks list-nodegroups --cluster-name ${CLUSTER_NAME} \
    --query 'nodegroups' --output text); do aws ec2 create-tags \
        --tags "Key=karpenter.sh/discovery,Value=${CLUSTER_NAME}" \
        --resources $(aws eks describe-nodegroup --cluster-name ${CLUSTER_NAME} \
        --nodegroup-name $NODEGROUP --query 'nodegroup.subnets' --output text )
done
```

### 보안 그룹에 태그 추가
```sh
NODEGROUP=$(aws eks list-nodegroups --cluster-name ${CLUSTER_NAME} \
    --query 'nodegroups[0]' --output text)
LAUNCH_TEMPLATE=$(aws eks describe-nodegroup --cluster-name ${CLUSTER_NAME} \
    --nodegroup-name ${NODEGROUP} --query 'nodegroup.launchTemplate.{id:id,version:version}' \
    --output text | tr -s "\t" ",")
# If your EKS setup is configured to use only Cluster security group, then please execute -

SECURITY_GROUPS=$(aws eks describe-cluster \
    --name ${CLUSTER_NAME} --query "cluster.resourcesVpcConfig.clusterSecurityGroupId" --output text)

# If your setup uses the security groups in the Launch template of a managed node group, then :

SECURITY_GROUPS=$(aws ec2 describe-launch-template-versions \
    --launch-template-id ${LAUNCH_TEMPLATE%,*} --versions ${LAUNCH_TEMPLATE#*,} \
    --query 'LaunchTemplateVersions[0].LaunchTemplateData.[NetworkInterfaces[0].Groups||SecurityGroupIds]' \
    --output text)

aws ec2 create-tags \
    --tags "Key=karpenter.sh/discovery,Value=${CLUSTER_NAME}" \
    --resources ${SECURITY_GROUPS}
```

### ConfigMap 설정  
```sh
kubectl edit configmap aws-auth -n kube-system

#  aws-auth ConfigMap에 groups를 하나 더 추가한다.
apiVersion: v1
data:
  mapRoles: |
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::950274644703:role/dev-global-eks-node-iam-role
      username: system:node:{{EC2PrivateDNSName}}
+   - groups:
+     - system:bootstrappers
+     - system:nodes
+     rolearn: arn:aws:iam::950274644703:role/KarpenterNodeRole-skills-cluster
+     username: system:node:{{EC2PrivateDNSName}}
kind: ConfigMap
metadata:
  ...
:x
```

# Karpenter 배포 yaml 생성
```sh
export KARPENTER_VERSION=v0.25.0
helm template karpenter oci://public.ecr.aws/karpenter/karpenter \
    --version ${KARPENTER_VERSION} \
    --namespace karpenter \
    --set settings.aws.defaultInstanceProfile=KarpenterNodeInstanceProfile-${CLUSTER_NAME} \
    --set settings.aws.clusterName=${CLUSTER_NAME} \
    --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="arn:${AWS_PARTITION}:iam::${AWS_ACCOUNT_ID}:role/KarpenterControllerRole-${CLUSTER_NAME}" \
    --set controller.resources.requests.cpu=1 \
    --set controller.resources.requests.memory=1Gi \
    --set controller.resources.limits.cpu=1 \
    --set controller.resources.limits.memory=1Gi \
    --set replicas=2 > karpenter.yaml
```

### karpenter.yaml 파일 수정
```sh
vi karpenter.yaml
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: karpenter.sh/provisioner-name
                operator: DoesNotExist
+           - matchExpressions:
+             - key: eks.amazonaws.com/nodegroup
+               operator: In
+               values:
+               - YOUR_NODE_GROUP_NAME  # 노드그룹 이름은 현재 사용중인 노드 그룹으로 수정하기(두개면 두개로 설정)

# karpenter namespace 생성
kubectl create namespace karpenter

# provisioners CRD 생성
kubectl create -f \
    https://raw.githubusercontent.com/aws/karpenter/$KARPENTER_VERSION/pkg/apis/crds/karpenter.sh_provisioners.yaml
    
# awsnodetemplates CRD 생성    
kubectl create -f \
    https://raw.githubusercontent.com/aws/karpenter/$KARPENTER_VERSION/pkg/apis/crds/karpenter.k8s.aws_awsnodetemplates.yaml  

# CRD 목록 확인
kubectl api-resources \
    --categories karpenter \
    -o wide
NAME               SHORTNAMES   APIVERSION                   NAMESPACED   KIND              VERBS                                                        CATEGORIES
awsnodetemplates                karpenter.k8s.aws/v1alpha1   false        AWSNodeTemplate   delete,deletecollection,get,list,patch,create,update,watch   karpenter
provisioners                    karpenter.sh/v1alpha5        false        Provisioner       delete,deletecollection,get,list,patch,create,update,watch   karpenter

# Karpenter를 cluster에 배포
kubectl apply -f karpenter.yaml
kubectl get pod -n karpenter

# Provisioner 생성
 cat <<EOF | kubectl apply -f -
---
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: default
  labels:
    app: karpenter
    version: v0.25.0
spec:
  requirements:
    - key: karpenter.k8s.aws/instance-category
      operator: In
      values: [c, m, r]
    - key: karpenter.k8s.aws/instance-generation
      operator: Gt
      values: ["2"]
  providerRef:
    name: default

---
apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: default
  labels:
    app: karpenter
    version: v0.25.0
spec:
  amiFamily: AL2
  subnetSelector:
    karpenter.sh/discovery: "${CLUSTER_NAME}"
  securityGroupSelector:
    karpenter.sh/discovery: "${CLUSTER_NAME}"
EOF
```
