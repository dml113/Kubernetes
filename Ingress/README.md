
## 주의점

- **Ingress Healthcheck와 liveness probe의 관계**

    ingress 로 생성되는 Target Group의 Healthcheck는 liveness probe보다 먼저 동작하거나 동시점에 동작하는 것이 좋습니다.

    liveness probe로 인해 컨테이너가 재시작되는 동안에는 트래픽을 처리할 수 없기 때문입니다.

    이를 주의하여 ingress 생성 시 Healthcheck 의 interval, threshold를 설정하도록 합니다.

- **Ingress Draining과 gracePeriodShutdown의 관계**

    Ingress의 Draning 시간은 gracePeriodShutdown으로 설정된 시간과 같게 설정하는 것이 좋습니다.

    파드가 종료될 때 gracePeriodShutdown 기간 동안은 종료되지 않을 수 있고, 

    해당 기간이 넘어가면 강제 종료되기 때문에 더 이상 Draning을 유지할 필요가 없기 때문입니다.

## aws-load-balancer-controller

ingress 리소스를 생성하기 위해서는 aws-load-balancer-controller를 먼저 생성해야 합니다.

refer

- https://kubernetes-sigs.github.io/aws-load-balancer-controller/

- https://github.com/kubernetes-sigs/aws-load-balancer-controller

1. IAM - OIDC Provider 생성

    ```bash
    eksctl utils associate-iam-oidc-provider \
        --region <region-code> \
        --cluster <your-cluster-name> \
        --approve
    ```

2. IAM - Policy 생성

    ```bash
    curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.1/docs/install/iam_policy.json
    ```
    ```bash
    aws iam create-policy \
        --policy-name AWSLoadBalancerControllerIAMPolicy \
        --policy-document file://iam-policy.json
    ```

3. IAM - Role 생성

    ```bash
    eksctl create iamserviceaccount \
        --cluster=<cluster-name> \
        --namespace=kube-system \
        --name=aws-load-balancer-controller \
        --attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
        --override-existing-serviceaccounts \
        --region <region-code> \
        --approve
    ```

4. TargetGroupBinding CRDs 생성

    ```bash
    kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
    ```

5. Helm - Repo 추가

    ```bash
    helm repo add eks https://aws.github.io/eks-charts
    ```

6. Helm - Install from chart

    ```bash
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
        -n kube-system \
        --set clusterName=<cluster-name> \
        --set serviceAccount.create=false \
        --set serviceAccount.name=aws-load-balancer-controller
    ```

    - if you have tolerations options
    
        ```bash
        helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
            -n kube-system \
            --set clusterName=<cluster-name> \
            --set serviceAccount.create=false \
            --set serviceAccount.name=aws-load-balancer-controller \
            --set tolerations\[0\].key="key01" \
            --set tolerations\[0\].value="value01" \
            --set tolerations\[0\].effect="NoSchedule"
        ```

7. Subnet Tag 추가

    Subnet Discovery를 위해 Subnet에 태그를 추가합니다.

    - public & private subnets

        `kubernetes.io/cluster/${cluster-name}`: `owned` or `shared`

    - public subnets

        `kubernetes.io/role/elb` : `1`

    - private subnets

        `kubernetes.io/role/internal-elb` : `1`

## external-dns

refer

- https://github.com/kubernetes-sigs/external-dns/tree/master/charts/external-dns

- https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md

- https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/alb-ingress.md

1. create iam policy

    ```json
    {
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "route53:ChangeResourceRecordSets"
          ],
          "Resource": [
            "arn:aws:route53:::hostedzone/*"
          ]
          },
          {
          "Effect": "Allow",
          "Action": [
            "route53:ListHostedZones",
            "route53:ListResourceRecordSets"
          ],
          "Resource": [
            "*"
          ]
        }
      ]
    }
    ```

    ```
    aws iam create-policy \
        --policy-name AmazonEKSExternalDNSPolicy \
        --policy-document file://external-dns-policy.json
    ```

2. create iam role for service account

    ```
    eksctl create iamserviceaccount \
        --cluster=<cluster-name> \
        --namespace=kube-system \
        --name=external-dns \
        --attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AmazonEKSExternalDNSPolicy \
        --override-existing-serviceaccounts \
        --region <region-code> \
        --approve
    ```

3. add helm repo 

    ```
    helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
    ```

4. install helm chart

    ```
    helm upgrade --install external-dns external-dns/external-dns \
    -n kube-system \
    --set serviceAccount.create=false \
    --set serviceAccount.name=external-dns
    ```

    - if you need tolerations.
        ```
        helm upgrade --install external-dns external-dns/external-dns \
        -n kube-system \
        --set serviceAccount.create=false \
        --set serviceAccount.name=external-dns \
        --set tolerations\[0\].key=Management \
        --set tolerations\[0\].value=Tools \
        --set tolerations\[0\].effect=NoSchedule
        ```

5. ingress annotations

    ```
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: example-eks-ingress-alb
      namespace: dev
      annotations:
        external-dns.alpha.kubernetes.io/hostname: www.skill53.cloud
    ```
