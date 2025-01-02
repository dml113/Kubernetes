## Argocd Install
[https://arcozz.tistory.com/47]

1. Argocd Install
    ```sh
    kubectl create namespace argocd
    kubectl create namespace argo-rollouts
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/ha/install.yaml
    kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
    sudo curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    sudo chmod +x argocd
    sudo mv argocd /usr/local/bin/
    ```

    - if you need to rollout deploy
      ```sh
      kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
      sudo curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
      sudo chmod +x ./kubectl-argo-rollouts-linux-amd64
      sudo mv ./kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts
      ```

2. Argocd login
    ```sh
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
    kubectl get svc argocd-server -n argocd
    sudo argocd login <server address>
    username: admin
    password: <above-printed password>
    kubectl create clusterrolebinding default-admin --clusterrole=admin --serviceaccount=prd-cicd:default
    ```

    - if you want change password 
      ```sh
      sudo argocd account update-password
      # Enter password of currently logged in user (admin): <위에서 출력한 값>
      # Enter new password for user admin: Skill53##
      # Confirm new password for user admin: Skill53##
      ```

## Interlock codecommit
    sudo yum install -y git
    /usr/bin/git config --global credential.helper '!aws codecommit credential-helper $@'
    /usr/bin/git config --global credential.UseHttpPath true

- You have not HTTPS Git credentials for AWS CodeCommit follow command
    ```sh
    aws iam create-user --user-name argocd
    OUTPUT=$(aws iam create-access-key --user-name argocd)
    ACCESS_KEY_ID=$(echo $OUTPUT | jq -r '.AccessKey.AccessKeyId')
    SECRET_ACCESS_KEY=$(echo $OUTPUT | jq -r '.AccessKey.SecretAccessKey')
    export AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY=$SECRET_ACCESS_KEY
    ```
    
    Change variables to your own in code in buildspec
    The files in the files folder are uploaded to the code commit location.
    Files in kube are put inside a folder called kube.  

### Upload a file to code commit
    git clone <Your codecommit https>
    cd <codecommit name>
    git init
    git add -A
    git commit -m "kube upload"
    git push origin main

- argocd codecommit connect
    ```sh
    sudo argocd repo add https://git-codecommit.ap-northeast-2.amazonaws.com/v1/repos/gwangju-application-repo
    # Enter username and password 
    ## If an error occurs, go directly into the argocd domain and add it. ##
    ```

- After accessing the argocd, click New APP and click EDIT AS YAML.
    ```yaml
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: blue-green-app
      namespace: argocd
    spec:
      destination:
        name: ''
        namespace: app
        server: 'https://kubernetes.default.svc'
      source:
        path: kube
        repoURL: '<codecommit repo URL>'
        targetRevision: HEAD
        helm:
          valueFiles:
            - values.yaml
      sources: []
      project: default
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
    ```

- if you need to rollout deploy
    ```sh
    kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
    sudo curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
    sudo chmod +x ./kubectl-argo-rollouts-linux-amd64
    sudo mv ./kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts
    ```
