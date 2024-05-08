#!/bin/bash
#check for environment variables
if [ -z "$AWS_ACCOUNT_ID" ]; then
  echo "AWS_ACCOUNT_ID environment variable not set"
  exit 1
fi
if [ -z "$AWS_REGION" ]; then
  echo "AWS_REGION environment variable not set"
  exit 1
fi
if [ -z "$EKS_OIDC" ]; then
  echo "EKS_OIDC environment variable not set"
  exit 1
fi
if [ -z "$CF_BUCKET_NAME" ]; then
  echo "CF_BUCKET_NAME environment variable not set"
  exit 1
fi
if [ -z "$BACKUPS_BUCKET_NAME" ]; then
  echo "BACKUPS_BUCKET_NAME environment variable not set"
  exit 1
fi
if [ -z "$TEMBO_NAMESPACE" ]; then
  echo "TEMBO_NAMESPACE environment variable not set"
  exit 1
fi
if [ -z "$TEMBO_CHART_NAME" ]; then
  echo "TEMBO_CHART_NAME environment variable not set"
  exit 1
fi

# Create CloudFormation template
cat >conductor-cf-template.yaml <<EOF
---
AWSTemplateFormatVersion: '2010-09-09'
Description: 'AWS CloudFormation Template IAM Role for S3 access'

Parameters:
  BucketName:
    Description: 'Name of the S3 bucket'
    Type: String
  BucketOrg:
    Description: 'Path inside the S3 bucket that the IAM Role can access'
    Type: String
  RoleName:
    Description: 'Name of the IAM Role for S3 access'
    Type: String
  Namespace:
    Description: 'Kubernetes namespace'
    Type: String
  ServiceAccountName:
    Description: 'Name of the Kubernetes service account'
    Type: String

Resources:
  S3AccessRole:
    Type: 'AWS::IAM::Role'
    Properties:
      RoleName: !Ref RoleName
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Federated: "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/${EKS_OIDC}"
            Action: 'sts:AssumeRoleWithWebIdentity'
            Condition:
              StringLike:
                "${EKS_OIDC}:sub": !Sub "system:serviceaccount:\${Namespace}:*"
      Path: '/'
      Policies:
        - PolicyName: 'S3CustomAccess'
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - 's3:GetObject'
                Resource:
                  - !Sub "arn:aws:s3:::\${BucketName}/coredb/\${BucketOrg}/*"
                  - !Sub "arn:aws:s3:::\${BucketName}/coredb/\${BucketOrg}"
              - Effect: Allow
                Action:
                  - 's3:PutObject'
                  - 's3:DeleteObject'
                Resource:
                  - !Sub "arn:aws:s3:::\${BucketName}/coredb/\${BucketOrg}/\${Namespace}/*"
                  - !Sub "arn:aws:s3:::\${BucketName}/coredb/\${BucketOrg}/\${Namespace}"
              - Effect: Allow
                Action:
                  - 's3:ListBucket'
                Resource:
                  - !Sub "arn:aws:s3:::\${BucketName}"

Outputs:
  RoleName:
    Description: IAM Role Name for S3 access
    Value: !Ref S3AccessRole
  RoleArn:
    Description: IAM Role ARN for S3 access
    Value: !GetAtt S3AccessRole.Arn
EOF

# Create bucket policy for CloudFormation bucket
cat >tembo-cf-bucket-policy.json <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Sid": "ConductorS3Access",
           "Effect": "Allow",
           "Principal": {
               "AWS": "arn:aws:iam::${AWS_ACCOUNT_ID}:root"
           },
           "Action": [
               "s3:PutObject",
               "s3:List*",
               "s3:Get*",
               "s3:DeleteObject"
           ],
           "Resource": [
               "arn:aws:s3:::${CF_BUCKET_NAME}/*",
               "arn:aws:s3:::${CF_BUCKET_NAME}"
           ]
       }
   ]
}
EOF

# Create bucket policy for backups bucket
cat >tembo-backups-bucket-policy.json <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Sid": "DenyIncorrectEncryptionHeader",
           "Effect": "Deny",
           "Principal": "*",
           "Action": "s3:PutObject",
           "Resource": "arn:aws:s3:::${BACKUPS_BUCKET_NAME}/*",
           "Condition": {
               "StringNotEquals": {
                   "s3:x-amz-server-side-encryption": "AES256"
               }
           }
       },
       {
           "Sid": "DenyUnEncryptedObjectUploads",
           "Effect": "Deny",
           "Principal": "*",
           "Action": "s3:PutObject",
           "Resource": "arn:aws:s3:::${BACKUPS_BUCKET_NAME}/*",
           "Condition": {
               "Null": {
                   "s3:x-amz-server-side-encryption": "true"
               }
           }
       },
       {
           "Sid": "ForceSSLOnlyAccess",
           "Effect": "Deny",
           "Principal": "*",
           "Action": "s3:*",
           "Resource": [
               "arn:aws:s3:::${BACKUPS_BUCKET_NAME}/*",
               "arn:aws:s3:::${BACKUPS_BUCKET_NAME}"
           ],
           "Condition": {
               "Bool": {
                   "aws:SecureTransport": "false"
               }
           }
       }
   ]
}
EOF

# Create IAM policy for conductor component
cat >tembo-iam-policy.json <<EOF
{
   "Statement": [
       {
           "Action": [
               "cloudformation:UpdateStack",
               "cloudformation:CreateStack"
           ],
           "Condition": {
               "StringEquals": {
                   "cloudformation:TemplateUrl": [
                       "s3://${CF_BUCKET_NAME}/conductor-cf-template.yaml",
                       "https://${CF_BUCKET_NAME}.s3.amazonaws.com/conductor-cf-template.yaml"
                   ]
               }
           },
           "Effect": "Allow",
           "Resource": [
               "arn:aws:cloudformation:${AWS_REGION}:${AWS_ACCOUNT_ID}:type/*",
               "arn:aws:cloudformation:${AWS_REGION}:${AWS_ACCOUNT_ID}:stackset/*",
               "arn:aws:cloudformation:${AWS_REGION}:${AWS_ACCOUNT_ID}:stack/*",
               "arn:aws:cloudformation:${AWS_REGION}:${AWS_ACCOUNT_ID}:changeSet/*"
           ],
           "Sid": "ConductorCFAccessWithCondition"
       },
       {
           "Action": [
               "cloudformation:ListStacks",
               "cloudformation:GetTemplate",
               "cloudformation:DescribeStacks",
               "cloudformation:DescribeStackEvents",
               "cloudformation:DeleteStack"
           ],
           "Effect": "Allow",
           "Resource": [
               "arn:aws:cloudformation:${AWS_REGION}:${AWS_ACCOUNT_ID}:type/*",
               "arn:aws:cloudformation:${AWS_REGION}:${AWS_ACCOUNT_ID}:stackset/*",
               "arn:aws:cloudformation:${AWS_REGION}:${AWS_ACCOUNT_ID}:stack/*",
               "arn:aws:cloudformation:${AWS_REGION}:${AWS_ACCOUNT_ID}:changeSet/*"
           ],
           "Sid": "ConductorCFAccess"
       },
       {
           "Action": [
               "cloudformation:ValidateTemplate",
               "cloudformation:DescribeStacks"
           ],
           "Effect": "Allow",
           "Resource": "*",
           "Sid": "ConductorCFValidateTemplate"
       },
       {
           "Action": [
               "s3:List*",
               "s3:Get*",
               "s3:Describe*"
           ],
           "Effect": "Allow",
           "Resource": [
               "arn:aws:s3:::${CF_BUCKET_NAME}/*",
               "arn:aws:s3:::${CF_BUCKET_NAME}/"
           ],
           "Sid": "ConductorS3Access"
       },
       {
           "Action": [
               "iam:PutRolePolicy",
               "iam:GetRolePolicy",
               "iam:GetRole",
               "iam:DetachRolePolicy",
               "iam:DeleteRolePolicy",
               "iam:DeleteRole",
               "iam:CreateRole",
               "iam:AttachRolePolicy"
           ],
           "Effect": "Allow",
           "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/*",
           "Sid": "ConductorIAMRoleAccess"
       }
   ],
   "Version": "2012-10-17"
}
EOF

# Create Trust Relationship for conductor IAM role
cat >tembo-trust-relationship.json <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Sid": "",
           "Effect": "Allow",
           "Principal": {
               "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/${EKS_OIDC}"
           },
           "Action": "sts:AssumeRoleWithWebIdentity",
           "Condition": {
               "StringLike": {
                   "${EKS_OIDC}:sub": "system:serviceaccount:${TEMBO_NAMESPACE}:${TEMBO_CHART_NAME}-conductor"
               }
           }
       }
   ]
}
EOF

