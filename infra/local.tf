# Configuración reusable para los 3 buckets
locals {
    buckets = [
        {
        name = "raw-apartments-management-${var.ambiente}-${var.owner}"
        layer = "Raw"
        },
        {
        name = "stage-apartments-management-${var.ambiente}-${var.owner}"
        layer = "Stage"
        },
        {
        name = "product-apartments-management-${var.ambiente}-${var.owner}"
        layer = "Product"
        }
    ]
    glue_jobs = {        
        job_cuotas = {
            script_file   = "g2_glue_job-cuotas.py"
            source_bucket = module.s3.bucket_map["Raw"]
            target_bucket = module.s3.bucket_map["Stage"]
            glue_role_arn = module.iam.glue_role_arn
        }
        job_departamentos = {
            script_file   = "g2_glue_job-departamentos.py"
            source_bucket = module.s3.bucket_map["Raw"]
            target_bucket = module.s3.bucket_map["Stage"]
            glue_role_arn = module.iam.glue_role_arn
        }
        job_edificios = {
            script_file   = "g2_glue_job-edificios.py"
            source_bucket = module.s3.bucket_map["Raw"]
            target_bucket = module.s3.bucket_map["Stage"]
            glue_role_arn = module.iam.glue_role_arn
        }
        job_empresas = {
            script_file   = "g2_glue_job-empresas.py"
            source_bucket = module.s3.bucket_map["Raw"]
            target_bucket = module.s3.bucket_map["Stage"]
            glue_role_arn = module.iam.glue_role_arn
        }
        job_facturas = {
            script_file   = "g2_glue_job-facturas.py"
            source_bucket = module.s3.bucket_map["Raw"]
            target_bucket = module.s3.bucket_map["Stage"]
            glue_role_arn = module.iam.glue_role_arn
        }
        job_gastos = {
            script_file   = "g2_glue_job-gastos.py"
            source_bucket = module.s3.bucket_map["Raw"]
            target_bucket = module.s3.bucket_map["Stage"]
            glue_role_arn = module.iam.glue_role_arn
        }
        job_inquilinos = {
            script_file   = "g2_glue_job-inquilinos.py"
            source_bucket = module.s3.bucket_map["Raw"]
            target_bucket = module.s3.bucket_map["Stage"]
            glue_role_arn = module.iam.glue_role_arn
        }
        job_pagos = {
            script_file   = "g2_glue_job-pagos.py"
            source_bucket = module.s3.bucket_map["Raw"]
            target_bucket = module.s3.bucket_map["Stage"]
            glue_role_arn = module.iam.glue_role_arn
        }
        job_presupuestos = {
            script_file   = "g2_glue_job-presupuestos.py"
            source_bucket = module.s3.bucket_map["Raw"]
            target_bucket = module.s3.bucket_map["Stage"]
            glue_role_arn = module.iam.glue_role_arn
        }
        job_propietarios = {
            script_file   = "g2_glue_job-propietarios.py"
            source_bucket = module.s3.bucket_map["Raw"]
            target_bucket = module.s3.bucket_map["Stage"]
            glue_role_arn = module.iam.glue_role_arn
        }
        job_proveedores = {
            script_file   = "g2_glue_job-proveedores.py"
            source_bucket = module.s3.bucket_map["Raw"]
            target_bucket = module.s3.bucket_map["Stage"]
            glue_role_arn = module.iam.glue_role_arn
        }
    }
}
