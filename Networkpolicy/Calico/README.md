
refer
- https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/calico.html
- https://kubernetes.io/ko/docs/concepts/services-networking/network-policies/
- https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart


## calico

1. Installing calico deployment.

    ```bash
    k create ns tigera-operator
    helm repo add projectcalico https://docs.tigera.io/calico/charts
    helm install calico projectcalico/tigera-operator --version v3.28.0 --namespace tigera-operator
    ```

2. Confirm that all of the pods are running with the following command.
    ```bash
    k get po -n tigera-operator
    ```

3. Install calicoctl

    ```bash
    curl -L https://github.com/projectcalico/calico/releases/download/v3.24.5/calicoctl-linux-amd64 -o calicoctl
    chmod 700 calicoctl
    sudo mv calicoctl /usr/bin/
    ```
