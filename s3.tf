# Crear los buckets con configuración básica
resource "aws_s3_bucket" "data_lake_buckets" {
    for_each = { for bucket in local.buckets : bucket.name => bucket }

    bucket = each.key

    tags = {
        Proyecto = var.proyecto
        Environment = var.ambiente
        Layer       = each.value.layer
    }
}

# Bloqueo de acceso público (gratis y recomendable)
resource "aws_s3_bucket_public_access_block" "public_access" {
    for_each = aws_s3_bucket.data_lake_buckets

    bucket = each.value.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}