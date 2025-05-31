output "bucket_map" {
  value = {
    for b in var.buckets :
    b.layer => aws_s3_bucket.data_lake_buckets[b.name].id
  }
}