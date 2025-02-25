## Linkerd Installation site
- [https://linkerd.io/2.17/getting-started/]
## Linkerd SMI Installation site
- [https://linkerd.io/2-edge/tasks/linkerd-smi/]
## Handling ingress traffic
- [https://linkerd.io/2.17/tasks/using-ingress/]

### Linkerd Add annotations to the Namespace
```bash
kubectl annotate ns default linkerd.io/inject=enabled
```
