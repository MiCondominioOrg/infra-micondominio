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
module "glue" {
  source    = "../modules/glue"
  ambiente  = var.ambiente
  glue_role_arn = module.iam.glue_role_arn
  source_bucket  = module.s3.bucket_map["Raw"]
  target_bucket  = module.s3.bucket_map["Stage"]
  glue_jobs = local.glue_jobs
}

resource "aws_sns_topic" "topic_sns_g2" {
  name = "topic_sns_g2-${var.ambiente}"
}


module "g2_step_function" {
  source   = "../modules/step_function"
  name     = "g2-${var.ambiente}-step-function"
  role_arn = module.iam.glue_role_arn
  definition = templatefile("./step_definitions/datapipeline-micondominio.json", {
    ambiente = var.ambiente,
    sns_topic_arn  = aws_sns_topic.topic_sns_g2.arn
  })
  tags = {
    Environment = var.ambiente
  }
}