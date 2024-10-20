### To set the default stage class, refer to the command below
  ```sh
  kubectl patch storageclass <sotrageClass Name> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}
  ```
