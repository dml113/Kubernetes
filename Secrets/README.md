
secret 리소스에 대한 .yaml파일 형식이 존재하지만, 아래와 같이 kubectl 명령을 활용하여 일회성으로 만드는 방법에 대해서만 살펴봅니다.

secret 리소스로 관리되는 key/value는 대체로 민감한 데이터인 데, .yaml 파일로 작성되고 VCS로 관리된다면 외부에 노출될 가능성이 있기 때문입니다.

TLS 인증서 및 개인키 생성
```bash
openssl genrsa -out https.key 2048
openssl req -new -x509 -key https.key -out https.cert -days 3650 -subj /CN=www.kubia-example.com
```

생성된 TLS 인증서 및 개인키의 내용으로 secret을 생성합니다.
```bash
kubectl create secret generic fortune-https --from-file=certs/
```

secret을 확인합니다.
```bash
kubectl get secret
kubectl describe secret
```