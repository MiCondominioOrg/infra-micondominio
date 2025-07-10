
resource "aws_s3_bucket" "glue_bucket" {
  bucket = "g2-${var.ambiente}-scripts-bucket"
}

data "template_file" "glue_job_script" {
  for_each = var.glue_jobs

  template = file("./glue_script/${each.value.script_file}")
  vars = {
    source_bucket = each.value.source_bucket
    target_bucket = each.value.target_bucket
  }
}

resource "aws_s3_object" "glue_script" {
  for_each = var.glue_jobs

  bucket  = aws_s3_bucket.glue_bucket.bucket
  key     = "scripts/${each.value.script_file}"
  content = data.template_file.glue_job_script[each.key].rendered
}

resource "aws_glue_job" "glue_jobs" {
  for_each = var.glue_jobs

  name     = "g2-glue-${each.key}-${var.ambiente}"
  role_arn = each.value.glue_role_arn

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.glue_bucket.bucket}/scripts/${each.value.script_file}"
    python_version  = "3"
  }

  glue_version      = "4.0"
  number_of_workers = 2
  worker_type       = "G.1X"

  execution_property {
    max_concurrent_runs = 1
  }

  max_retries = 0
  timeout     = 2880
  description = "Glue job ${each.key}"
  tags = {
    Environment = var.ambiente
  }

  execution_class = "STANDARD"

  connections = []

  default_arguments = {
    "--job-language"                     = "python"
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-glue-datacatalog"          = "true"
    "--additional-python-modules"        = "pydeequ"
  }
}
