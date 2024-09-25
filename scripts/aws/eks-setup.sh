#!/bin/bash

# Function to prompt the user with a default value
prompt_with_default() {
    local prompt_message=$1
    local default_value=$2
    local user_input

    # Display the prompt message with the default value
    read -p "$prompt_message [$default_value]: " user_input

    # If the user input is empty, use the default value
    echo "${user_input:-$default_value}"
}

CLUSTER_NAME=$(kubectl config current-context | awk -F'/' '{print $NF}')
REGION=$(kubectl config current-context | awk -F':' '{print $4}')
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

## Enable IAM OIDC Provider
eksctl utils associate-iam-oidc-provider --cluster $CLUSTER_NAME --region $REGION --approve

## Create the Amazon EBS CSI driver IAM role
IAM_ROLE_NAME="AmazonEKS_EBS_CSI_DriverRole_${CLUSTER_NAME}"

eksctl create iamserviceaccount \
    --name ebs-csi-controller-sa \
    --namespace kube-system \
    --cluster $CLUSTER_NAME \
    --role-name $IAM_ROLE_NAME \
    --role-only \
    --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
    --region $REGION \
    --approve


SERVICE_ACCOUNT_ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${IAM_ROLE_NAME}"

## Add the Amazon EBS CSI driver add-on
eksctl create addon \
     --name aws-ebs-csi-driver \
     --cluster $CLUSTER_NAME \
     --service-account-role-arn $SERVICE_ACCOUNT_ROLE_ARN \
     --region $REGION \
     --force

## Update the StorageClass to allow for volume expansion
kubectl patch storageclass gp2 -p '{"allowVolumeExpansion": true}'

kubectl get namespace | grep -q cert-manager || kubectl create namespace cert-manager
