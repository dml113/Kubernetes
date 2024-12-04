# Amazon EBS CSI Driver Setup Guide

This guide provides the steps for setting up the Amazon EBS CSI Driver on an Amazon EKS cluster. It includes checking the available versions, creating an IAM Role for Service Account (IRSA), and installing the CSI Driver as an add-on.

---

## Table of Contents
1. [Check Amazon EBS CSI Driver Versions](#check-amazon-ebs-csi-driver-versions)
2. [Create IAM Role for Service Account (IRSA)](#create-iam-role-for-service-account-irsa)
3. [Install Amazon EBS CSI Driver](#install-amazon-ebs-csi-driver)

---
## Specify Variables
```bash
CLUSTER_NAME=eks-cluster
REGION=ap-northeast-2
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
```

## 1. Check Amazon EBS CSI Driver Versions

To list available Amazon EBS CSI Driver versions and identify the default version for Kubernetes latest:

```bash
aws eks describe-addon-versions \
    --addon-name aws-ebs-csi-driver \
    --kubernetes-version latest \
    --query "addons[].addonVersions[].[addonVersion, compatibilities[].defaultVersion]" \
    --output text
```

## 2. Create IAM Role for Service Account (IRSA)
To enable Amazon EKS to manage the Amazon EBS CSI Driver, create an IAM Role for the Service Account

```bash
eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster ${CLUSTER_NAME} \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --role-only \
  --region ap-northeast-2 \
  --role-name AmazonEKS_EBS_CSI_DriverRole
```

## 3. Verify IRSA Creation
Check that the IRSA has been created successfully

```bash
eksctl get iamserviceaccount --cluster ${CLUSTER_NAME}
```

## 4. Install Amazon EBS CSI Driver
Install the Amazon EBS CSI Driver as an EKS add-on, attaching the IAM role

```bash
eksctl create addon --name aws-ebs-csi-driver \
  --cluster ${CLUSTER_NAME} \
  --service-account-role-arn arn:aws:iam::${ACCOUNT_ID}:role/AmazonEKS_EBS_CSI_DriverRole \
  --region ap-northeast-2 \
  --force
```
