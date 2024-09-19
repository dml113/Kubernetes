## 파일 내용을 configmap으로 만들기

`kubectl create configmap` 명령의 `--from-files` 옵션을 활용하여 기존 작성된 설정 파일들을 configmap으로 만들 수 있습니다.

```bash
kubectl create configmap configmap-name --from-files=configmap-from-files/
```
