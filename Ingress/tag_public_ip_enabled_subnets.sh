#!/bin/bash

# AWS CLI로 사용할 리전 설정 (필요에 따라 수정)
REGION="ap-northeast-2"

# VPC ID (필요할 경우 수정)
VPC_ID="vpc-00ce362107b7850d0"

# VPC 내 모든 서브넷 가져오기
subnets=$(aws ec2 describe-subnets \
    --region "$REGION" \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query "Subnets[*].{ID:SubnetId,PublicIP:MapPublicIpOnLaunch}" \
    --output json)

# JSON 파싱을 위해 jq 사용 (AWS CLI의 출력을 다루기 쉽게 도와줌)
for row in $(echo "$subnets" | jq -c '.[]'); do
  subnet_id=$(echo "$row" | jq -r '.ID')
  public_ip_enabled=$(echo "$row" | jq -r '.PublicIP')

  if [ "$public_ip_enabled" == "true" ]; then
    echo "Tagging Public Subnet: $subnet_id with kubernetes.io/role/elb: 1"
    aws ec2 create-tags \
      --region "$REGION" \
      --resources "$subnet_id" \
      --tags Key=kubernetes.io/role/elb,Value=1
  else
    echo "Tagging Prviate Subnet: $subnet_id with kubernetes.io/role/internal-elb: 1"
    aws ec2 create-tags \
      --region "$REGION" \
      --resources "$subnet_id" \
      --tags Key=kubernetes.io/role/internal-elb,Value=1
  fi
done

echo "Tagging complete!"
