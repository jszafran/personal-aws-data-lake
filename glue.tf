resource "aws_glue_job" "hello_world_glue_spark_job" {
  name              = "hello-world-glue-job"
  role_arn          = aws_iam_role.glue_s3_data_lake_access_role.arn
  glue_version      = "3.0"
  number_of_workers = 2
  worker_type       = "G.1X"
  max_retries       = 0
  timeout           = 5
  description       = "Hello world type of job - just to make sure that creation of basic job through Terraform works."
  command {
    script_location = "s3://${aws_s3_bucket.data_lake_bucket.bucket}/${var.glue_jobs_prefix}/hello_world_job.py"
    python_version  = "3"
  }
}
