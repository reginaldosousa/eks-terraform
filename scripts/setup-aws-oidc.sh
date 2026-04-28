#!/bin/bash

# AWS OIDC Setup Script for GitHub Actions
# This script sets up the infrastructure necessary for GitHub Actions to assume
# an AWS IAM role using OpenID Connect (OIDC).

set -e

# Configuration
GITHUB_ORG="reginaldosousa"
GITHUB_REPO="eks-terraform"
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text)}
ROLE_NAME="github-terraform-role"
POLICY_NAME="github-terraform-policy"

echo "🔧 AWS OIDC Setup for GitHub Actions"
echo "===================================="
echo "GitHub Org: $GITHUB_ORG"
echo "GitHub Repo: $GITHUB_REPO"
echo "AWS Account ID: $AWS_ACCOUNT_ID"
echo ""

# Step 1: Create OIDC Provider (if not exists)
echo "📋 Step 1: Create OpenID Connect Provider..."

PROVIDER_ARN=$(aws iam list-open-id-connect-providers --query "OpenIDConnectProviderList[?contains(OpenIDConnectProviderArn, 'token.actions.githubusercontent.com')].OpenIDConnectProviderArn" --output text 2>/dev/null || echo "")

if [ -z "$PROVIDER_ARN" ]; then
  echo "Creating new OIDC provider..."
  PROVIDER_ARN=$(aws iam create-open-id-connect-provider \
    --url https://token.actions.githubusercontent.com \
    --client-id-list sts.amazonaws.com \
    --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
    --query 'OpenIDConnectProviderArn' \
    --output text)
  echo "✅ Created OIDC provider: $PROVIDER_ARN"
else
  echo "✅ OIDC provider already exists: $PROVIDER_ARN"
fi

# Step 2: Create IAM Role
echo ""
echo "📋 Step 2: Create IAM Role..."

ASSUME_ROLE_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:${GITHUB_ORG}/${GITHUB_REPO}:*"
        }
      }
    }
  ]
}
EOF
)

if aws iam get-role --role-name "$ROLE_NAME" 2>/dev/null; then
  echo "✅ Role already exists: $ROLE_NAME"
else
  echo "Creating new role..."
  aws iam create-role \
    --role-name "$ROLE_NAME" \
    --assume-role-policy-document "$ASSUME_ROLE_POLICY" \
    --description "Role for GitHub Actions to manage Terraform"
  echo "✅ Created role: $ROLE_NAME"
fi

# Step 3: Create and Attach Policy
echo ""
echo "📋 Step 3: Create and Attach Least-Privilege Policy..."

TERRAFORM_POLICY=$(cat <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "eks:*",
        "s3:*",
        "iam:*",
        "logs:*",
        "cloudwatch:*",
        "elasticloadbalancing:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::eks-terraform-state-*",
        "arn:aws:s3:::eks-terraform-state-*/*"
      ]
    }
  ]
}
EOF
)

# Check if policy already exists
if aws iam get-role-policy --role-name "$ROLE_NAME" --policy-name "$POLICY_NAME" 2>/dev/null; then
  echo "Policy already exists, updating..."
  aws iam put-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-name "$POLICY_NAME" \
    --policy-document "$TERRAFORM_POLICY"
else
  echo "Creating new policy..."
  aws iam put-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-name "$POLICY_NAME" \
    --policy-document "$TERRAFORM_POLICY"
fi

echo "✅ Policy attached to role"

# Step 4: Output Results
echo ""
echo "✅ Setup Complete!"
echo "======================================"
echo ""
echo "📌 Add this secret to your GitHub repository:"
echo ""
echo "Secret Name: AWS_ROLE_TO_ASSUME"
echo "Secret Value: arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE_NAME}"
echo ""
echo "📌 GitHub Repository Settings:"
echo "  1. Go to Settings → Secrets and variables → Actions"
echo "  2. Click 'New repository secret'"
echo "  3. Name: AWS_ROLE_TO_ASSUME"
echo "  4. Value: arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE_NAME}"
echo ""
echo "📌 Also add these secrets for your Terraform variables:"
echo "  - CLOUDFLARE_API_TOKEN"
echo "  - LETSENCRYPT_EMAIL"
echo ""
echo "🎉 Your GitHub Actions CI/CD pipeline is ready!"
