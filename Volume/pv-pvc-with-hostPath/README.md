``` sh
StorageClass VOLUMEBINDINGMODE에는 WaitForFirstConsumer와 Immediate가 존재하는데,
WaitForFirstConsumer를 사용한다면 pvc와 pod를 연결 및 생성하면 pv와 EBS volume 생성되지만,
Immediate를 사용한다면 pvc를 생성하면 pod를 생성하지 않아도 pv와 EBS volume이 생성된다.
```

### To set the default stage class, refer to the command below
  ```sh
  kubectl patch storageclass <sotrageClass Name> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}
  ```
