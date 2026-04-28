#!/bin/bash

# Script to run Terraform validation locally
# This mirrors what the GitHub Actions pipeline does

set -e

echo "🔍 Running Terraform Validation Checks"
echo "======================================"

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
  echo "❌ Terraform is not installed"
  exit 1
fi

# Check if TFLint is installed
if ! command -v tflint &> /dev/null; then
  echo "⚠️  TFLint is not installed. Install with: brew install tflint"
  echo "   Skipping TFLint checks..."
  SKIP_TFLINT=true
else
  SKIP_TFLINT=false
fi

echo ""
echo "📋 1. Checking Terraform Format..."
if terraform fmt -check -diff -recursive . > /tmp/fmt_check.txt 2>&1; then
  echo "✅ Terraform formatting is correct"
else
  echo "❌ Formatting issues found:"
  cat /tmp/fmt_check.txt
  echo ""
  echo "💡 Fix formatting with: terraform fmt -recursive ."
  exit 1
fi

echo ""
echo "📋 2. Initializing Terraform (backend disabled)..."
terraform init -backend=false > /dev/null 2>&1

echo ""
echo "📋 3. Validating Terraform Configuration..."
if terraform validate; then
  echo "✅ Terraform validation passed"
else
  echo "❌ Terraform validation failed"
  exit 1
fi

if [ "$SKIP_TFLINT" = false ]; then
  echo ""
  echo "📋 4. Running TFLint..."
  tflint --init > /dev/null 2>&1
  if tflint -f compact --chdir .; then
    echo "✅ TFLint checks passed"
  else
    echo "⚠️  TFLint found issues (review carefully)"
  fi
fi

echo ""
echo "✅ All validation checks passed!"
echo ""
echo "💡 Next steps:"
echo "  1. Run 'terraform plan' to see what will be created/modified"
echo "  2. Review the plan carefully"
echo "  3. Create a pull request to trigger CI/CD validation"
echo "  4. After review and approval, merge to deploy"
