
refer
- https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/calico.html
- https://kubernetes.io/ko/docs/concepts/services-networking/network-policies/


## calico

1. add helm repo

    ```bash
    helm repo add projectcalico https://docs.projectcalico.org/charts
    ```

2. update helm repo

    ```bash
    helm repo update
    ```

3. create namespace

    ```bash
    kubectl create namespace calico-system
    ```

4. write `values.yaml`

    ```yaml
    installation:
      kubernetesProvider: EKS
      controlPlaneTolerations: # if you need taint/toleration.
        - key: Management
          value: Tools
          effect: NoSchedule
    ```

5. install calico using helm

    ```bash
    helm install calico projectcalico/tigera-operator --version v3.21.4 --namespace calico-system -f values.yaml
    ```