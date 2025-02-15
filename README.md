https://sunset-squash-626.notion.site/Cloud-Computing-8ca99edf9ab345869a7248eb941e7210?pvs=4

### eksctl install
```sh
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/bin/
eksctl version
```

### kubectl install 
```sh
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.0/2024-09-12/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/bin/
sudo ln -s /usr/bin/kubectl /usr/local/bin/k
k version --client
```
- [☁️ kubectl reference site](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/install-kubectl.html)


### helm install
```sh
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```
