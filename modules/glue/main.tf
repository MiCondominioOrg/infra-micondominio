
resource "aws_s3_bucket" "glue_bucket" {
  bucket = "g2-${var.ambiente}-scripts-bucket"
}

data "template_file" "glue_job_script" {
  template = file("./glue_script/g2_script.py")

  vars = {
    source_bucket = var.source_bucket
    target_bucket = var.target_bucket
  }
}

resource "aws_s3_object" "glue_script" {
  bucket = aws_s3_bucket.glue_bucket.bucket
  key    = "scripts/g2_script.py"
  content = data.template_file.glue_job_script.rendered
#   source = "./glue_script/g2_script.py"
#   etag   = filemd5("./glue_script/g2_script.py")
}

resource "aws_glue_job" "g2_glue_job" {
  name     = "g2-${var.ambiente}-glue-job"
  role_arn = var.glue_role_arn

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.glue_bucket.bucket}/scripts/g2_script.py"
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
  description = "Glue job"
  tags = {
    Environment = "dev"
  }

  # Para activar Job Insights
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
