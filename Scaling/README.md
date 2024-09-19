

## metrics-server

refer

- https://artifacthub.io/packages/helm/metrics-server/metrics-server

- https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/metrics-server.html

1. add helm repo

    ```
    helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
    ```

2. install helm chart

    ```
    helm upgrade --install metrics-server metrics-server/metrics-server -n kube-system
    ```
    
    - if you need to tolerations.
        ```
        helm upgrade --install metrics-server metrics-server/metrics-server -n kube-system \
        --set tolerations\[0\].key="Management" \
        --set tolerations\[0\].value="Tools" \
        --set tolerations\[0\].effect="NoSchedule"
        ```



## cluster-autoscaler

refer

- https://artifacthub.io/packages/helm/cluster-autoscaler/cluster-autoscaler

- https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/cluster-autoscaler.html

1. create iam policy

    `cluster-autoscaler-policy.json`
    ```json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            "Resource": ["*"]
            },
            {
            "Effect": "Allow",
            "Action": [
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeImages",
                "ec2:GetInstanceTypesFromInstanceRequirements",
                "eks:DescribeNodegroup"
            ],
            "Resource": ["*"]
            }
        ]
    }
    ```

    ```
    aws iam create-policy \
    --policy-name AmazonEKSClusterAutoscalerPolicy \
    --policy-document file://cluster-autoscaler-policy.json
    ```

2. create iam role for service account

    ```
    eksctl utils associate-iam-oidc-provider \
    --region <region-code> \
    --cluster <your-cluster-name> \
    --approve
    ```

    ```
    eksctl create iamserviceaccount \
        --cluster=<cluster-name> \
        --namespace=kube-system \
        --name=cluster-autoscaler \
        --attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AmazonEKSClusterAutoscalerPolicy \
        --override-existing-serviceaccounts \
        --region <region-code> \
        --approve
    ```

3. add helm repo

    ```
    helm repo add autoscaler https://kubernetes.github.io/autoscaler
    ```

4. install helm chart

    ```
    helm upgrade --install aws-cluster-autoscaler autoscaler/cluster-autoscaler -n kube-system \
    --set autoDiscovery.clusterName=<CLUSTER NAME> \
    --set awsRegion=<YOUR AWS REGION> \
    --set rbac.serviceAccount.create=false \
    --set rbac.serviceAccount.name=cluster-autoscaler \
    --set image.tag="v1.23.0"
    ```

    - cluster-autoscaler image tag 와 kubernetes version이 일치 해야합니다.

    - if you need to tolerations.
        ```
        helm upgrade --install aws-cluster-autoscaler autoscaler/cluster-autoscaler -n kube-system \
        --set autoDiscovery.clusterName=<CLUSTER NAME> \
        --set awsRegion=<YOUR AWS REGION> \
        --set rbac.serviceAccount.create=false \
        --set rbac.serviceAccount.name=cluster-autoscaler \
        --set tolerations\[0\].key="Management" \
        --set tolerations\[0\].value="Tools" \
        --set tolerations\[0\].effect="NoSchedule" \
        --set image.tag="v1.23.0"
        ```