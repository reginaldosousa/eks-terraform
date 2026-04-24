plugin "aws" {
  enabled = true
  version = "0.31.1"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# General rules
rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = false
}

# AWS-specific rules
rule "aws_instance_ebs_encryption_by_default" {
  enabled = true
}

rule "aws_instance_multiple_public_ips" {
  enabled = true
}

rule "aws_s3_bucket_server_side_encryption_configuration" {
  enabled = true
}

rule "aws_s3_bucket_acl" {
  enabled = true
}

rule "aws_security_group_rule_cidr_ip" {
  enabled = true
}

rule "aws_elasticache_parameter_group_description" {
  enabled = true
}

rule "aws_db_instance_publicly_accessible" {
  enabled = true
}

rule "aws_db_instance_deletion_protection" {
  enabled = true
}

rule "aws_rds_cluster_multi_az" {
  enabled = true
}

rule "aws_rds_cluster_deletion_protection" {
  enabled = true
}

rule "aws_redshift_cluster_logging" {
  enabled = true
}