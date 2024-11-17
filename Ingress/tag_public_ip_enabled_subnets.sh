#!/bin/bash

# AWS CLI로 사용할 리전 설정 (필요에 따라 수정)
REGION="ap-northeast-2"

# 현재 리전에서 존재하는 모든 VPC ID 가져오기
vpcs=$(aws ec2 describe-vpcs \
    --region "$REGION" \
    --query "Vpcs[*].VpcId" \
    --output text)

if [ -z "$vpcs" ]; then
  echo "No VPCs found in the region $REGION."
  exit 1
fi

# 각 VPC에 대해 서브넷 가져오고 태그 설정
for VPC_ID in $vpcs; do
  echo "Processing VPC: $VPC_ID"

  # VPC 내 모든 서브넷 가져오기
  subnets=$(aws ec2 describe-subnets \
      --region "$REGION" \
      --filters "Name=vpc-id,Values=$VPC_ID" \
      --query "Subnets[*].{ID:SubnetId,PublicIP:MapPublicIpOnLaunch,Name:Tags[?Key=='Name'].Value | [0]}" \
      --output json)

  # JSON 파싱을 위해 jq 사용 (AWS CLI의 출력을 다루기 쉽게 도와줌)
  for row in $(echo "$subnets" | jq -c '.[]'); do
    subnet_id=$(echo "$row" | jq -r '.ID')
    public_ip_enabled=$(echo "$row" | jq -r '.PublicIP')
    subnet_name=$(echo "$row" | jq -r '.Name')

    # 서브넷 이름에 "public"이 포함되었는지 확인 (대소문자 구분 없음)
    if [[ "$public_ip_enabled" == "true" || "$subnet_name" =~ [Pp]ublic ]]; then
      echo "Tagging Public Subnet: $subnet_id with kubernetes.io/role/elb: 1"
      aws ec2 create-tags \
        --region "$REGION" \
        --resources "$subnet_id" \
        --tags Key=kubernetes.io/role/elb,Value=1
    else
      echo "Tagging Private Subnet: $subnet_id with kubernetes.io/role/internal-elb: 1"
      aws ec2 create-tags \
        --region "$REGION" \
        --resources "$subnet_id" \
        --tags Key=kubernetes.io/role/internal-elb,Value=1
    fi
  done
done

echo "Tagging complete for all VPCs in the region $REGION!"
