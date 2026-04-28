#!/bin/bash

# Script to format Terraform code locally

set -e

echo "🎨 Formatting Terraform Code"
echo "============================"

if ! command -v terraform &> /dev/null; then
  echo "❌ Terraform is not installed"
  exit 1
fi

echo "Formatting all Terraform files..."
terraform fmt -recursive -write=true .

echo ""
echo "✅ Formatting complete!"
echo ""
echo "📝 Changed files:"
git diff --name-only -- '*.tf' 2>/dev/null || echo "  (No changes tracked by git)"

echo ""
echo "💡 Review the changes and commit:"
echo "  git add *.tf"
echo "  git commit -m 'chore: format Terraform code'"
