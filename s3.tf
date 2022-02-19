resource "aws_s3_bucket" "data_lake_bucket" {
  bucket = var.data_lake_bucket_name
  force_destroy = false

  tags = {
    Name = "Data lake bucket"
  }
}
