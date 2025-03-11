# Thanos Prometheus Configure
## Configuring Thanos Object Storage 
### 1. Once you have written your configuration save it to a file. Here’s an example:
```bash
cat <<EOF > objstore.yml
type: s3
config:
  bucket: thanos-gmst-bucket
  endpoint: s3.ap-northeast-3.amazonaws.com
  access_key: AKIATCKARK6C6EWHGUI2
  access_key: TXilroUeGShOF/ai6qeqyvo+3kuhFlPYGSx5XENg
EOF
```
