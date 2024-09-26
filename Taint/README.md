### Refernece site
- [☁️ Taint reference site](https://kubernetes.io/ko/docs/concepts/scheduling-eviction/taint-and-toleration/)
### Effect 종류
```sh
NoSchedule (포드를 스케줄링하지 않음)
NoExecute (포드의 실행 자체를 허용하지 않음)
PreferNoSchedule  (가능하면 스케줄링하지 않음)
```

### Node에 Taint 부여
```sh
kubectl taint nodes `nodename` `key`=`value`:`effect`
```

### 예시:
```sh
kubectl taint nodes ip-192-168-201-100.ap-northeast-2.compute.internal itguny04/taint=dirty:NoSchedule
```

### Node에 Taint 삭제
```sh
kubectl taint nodes `nodename` `key`:`effect`-
```

### 예시:
```sh
kubectl taint nodes ip-192-168-201-100.ap-northeast-2.compute.internal itguny04/taint:NoSchedule-
```
