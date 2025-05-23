# Terraform app
terraform {
  backend "s3" {
    bucket = "g2-state"
    key    = "./terraform.tfstate"
    region = "us-east-1"
  }
}
module "s3" {
  source    = "../modules/s3"
  buckets   = local.buckets
  proyecto  = var.proyecto
  ambiente  = var.ambiente
}

module "iam" {
  source      = "../modules/iam"
  role_name   = var.glue_role_name
  policy_name = var.glue_policy_name
}