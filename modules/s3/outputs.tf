output "bucket_names" {
  value = [for b in aws_s3_bucket.data_lake_buckets : b.id]
}