resource "aws_sns_topic" "etl_job_failed" {
  name = "etl-job-failed"
}
resource "aws_sns_topic" "etl_job_succeeded" {
  name = "etl-job-succeeded"
}

resource "aws_sns_topic_subscription" "admin_job_failed_topic_subscription" {
  topic_arn = aws_sns_topic.etl_job_failed.arn
  protocol  = "email"
  endpoint  = var.data_lake_admin_email
}

resource "aws_sns_topic_subscription" "admin_job_succeeded_topic_subscription" {
  topic_arn = aws_sns_topic.etl_job_succeeded.arn
  protocol  = "email"
  endpoint  = var.data_lake_admin_email
}

output "etl_job_failed_topic_arn" {
  value = aws_sns_topic.etl_job_failed.arn
}

output "etl_job_succeeded_topic_arn" {
  value = aws_sns_topic.etl_job_succeeded.arn
}
