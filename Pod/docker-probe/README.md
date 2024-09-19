## About

시작하는 데 30초의 딜레이가 발생하는 어플리케이션을 생성합니다.

```
docker build . -t <registry>/flask-delay-start:v2
docker push <registry>/flask-delay-start:v2
```

`/healthcheck/liveness`
liveness probe를 테스트하기 위한 api로써 아무런 조건없이 200을 내려줍니다.

`/healthcheck/readiness`
readiness probe를 테스트하기 위한 api로써 /prod-data/greet.txt 파일이 있어야만 200을 내려줍니다.
-> 어플리케이션 시작 후 50초 후에 파일을 injection하는 방식으로 테스트할 수 있습니다.