resource "aws_sns_topic" "etl_job_failed" {
  name = "etl-job-failed"
}

resource "aws_sns_topic_subscription" "admin_job_failed_topic_subscription" {
  topic_arn = aws_sns_topic.etl_job_failed.arn
  protocol  = "email"
  endpoint  = var.data_lake_admin_email
}
