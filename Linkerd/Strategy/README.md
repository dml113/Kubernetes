# Linkerd Using Flagger Guide

##  Install Flagger 
###  To add Flagger to your cluster and have it configured to work with Linkerd, run:
  ```bash
  kubectl apply -k github.com/fluxcd/flagger/kustomize/linkerd
  ```

### To watch until everything is up and running, you can use kubectl:
  ```bash
  kubectl -n flagger-system rollout status deploy/flagger
  ```

