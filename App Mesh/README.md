## APP Mesh
※Cloud Map은 직접 생성한다. (name: skills.local, instance search: API calls and DNS queries in VPCs)※
### IAM Policy Create
```sh
envoy-policy='{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "appmesh:StreamAggregatedResources",
                "appmesh:*",
                "xray:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "acm:ExportCertificate",
                "acm-pca:GetCertificateAuthorityCertificate"
            ],
            "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "logs:*"
          ],
          "Resource": "*"
        }
    ]
}'

proxy-auth-policy='{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "appmesh:StreamAggregatedResources",
            "Resource": [
                "arn:aws:appmesh:ap-northeast-2:*:mesh/*/virtualNode/*"
            ]
        }
    ]
}'
echo "$envoy-policy" > envoy-policy.json
echo "$proxy-auth-policy" > proxy-auth-policy.json

envoy-policy=$(aws iam create-policy --policy-name envoy-policy --policy-document file://envoy-policy.json --query 'Policy.Arn' --output text)
proxy-auth-policy=$(aws iam create-policy --policy-name proxy-auth-policy --policy-document file://proxy-auth-policy.json --query 'Policy.Arn' --output text)
```
### 1. Create Namespace and ALB Controller Install
```sh
kubectl create namespace skills

# helm 설치
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# OIDC 생성
eksctl utils associate-iam-oidc-provider --cluster doc-cluster --approve --region ap-northeast-2

# AWS Load Balancer Controller의 IAM 정책을 다운로드
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json

# 다운로드 한 정책을 사용하여 IAM정책을 만듬
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

# 생성한 정책을 사용하여 serviceaccount 생성
eksctl create iamserviceaccount \
  --cluster=doc-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve \
  --region ap-northeast-2

# eks-charts 리포지토리를 추가
helm repo add eks https://aws.github.io/eks-charts

# 로컬 리포지토리를 업데이트
helm repo update

# Load Balancer Controller을 설치
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=skills-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller 

# 잘 설치 되어 있는지 확인
kubectl get deployment -n kube-system aws-load-balancer-controller
```

### 2. Appmesh Install
```sh
# git 설치
sudo yum  install -y git
# appmesh-system namespace 생성
kubectl create ns appmesh-system
kubectl apply -k "https://github.com/aws/eks-charts/stable/appmesh-controller/crds?ref=master"
# account 생성
eksctl create iamserviceaccount --cluster skills-cluster --namespace appmesh-system --name appmesh-controller --attach-policy-arn arn:aws:iam::aws:policy/AWSCloudMapFullAccess,arn:aws:iam::aws:policy/AWSAppMeshFullAccess --override-existing-serviceaccounts --approve
# appmesh-controller update 
helm upgrade -i appmesh-controller eks/appmesh-controller \
    --namespace appmesh-system \
    --set region=ap-northeast-2 \
    --set serviceAccount.create=false \
    --set serviceAccount.name=appmesh-controller
```

### 3. Files Apply
```sh
# 전부 생성될 때까지 기다렸다 apply한다.
kubectl apply -f ns.yaml
kubectl apply -f mesh.yaml
kubectl apply -f VirtualNode.yaml
kubectl apply -f VirtualRouter.yaml
kubectl apply -f VirtualService.yaml
eksctl create iamserviceaccount --cluster skills-cluster --namespace skills --name envoy-serviceaccount --attach-policy-arn $envoy-policy --override-existing-serviceaccounts --approve
kubectl apply -f Envoy & Gateway.yaml
eksctl create iamserviceaccount --cluster skills-cluster --namespace skills --name proxy-serviceaccount --attach-policy-arn $proxy-auth-policy --override-existing-serviceaccounts --approve
```
    - (OPTION) If you want to change the YAML file below, you can change it and use it.
        ### Files refer to a folder called Default.yaml
        kubectl apply -f deployment.yaml
        kubectl apply -f service.yaml
        kubectl apply -f ingress.yaml
