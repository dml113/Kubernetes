
refer
- https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/calico.html
- https://kubernetes.io/ko/docs/concepts/services-networking/network-policies/
- https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart


## calico

1. Install the Tigera Calico operator and custom resource definitions.

    ```bash
    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml
    ```

2. Install Calico by creating the necessary custom resource. For more information on configuration options available in this manifest, see the installation reference [https://docs.tigera.io/calico/latest/reference/installation/api].

    ```bash
    helm repo update
    ```

3. Confirm that all of the pods are running with the following command.

    ```bash
    watch kubectl get pods -n calico-system
    ```

4. Remove the taints on the control plane so that you can schedule pods on it.

    ```bash
    kubectl taint nodes --all node-role.kubernetes.io/control-plane-
    ```
    It should return the following.
    ```bash
    node/<your-hostname> untainted
    ```
