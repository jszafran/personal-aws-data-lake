resource "aws_ses_email_identity" "notifications_from_email_address" {
  email = var.notifications_email_address
}

resource "aws_ses_template" "failed_job_notification_template" {
  name    = "failed-job-notification-template"
  subject = "Job {{job_name}} failed."
  html    = "<h1>{{job_name}} failed at {{failure_time}}.</h1><p>Extra details:</p><p>{{failure_details}}</p>"
  text    = "{{job_name}} failed at {{failure_time}}.\n\nExtra details:\n{{failure_details}}"
}
