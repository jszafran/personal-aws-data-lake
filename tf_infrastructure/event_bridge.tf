// uses default event bus
resource "aws_cloudwatch_event_rule" "justjoinit_job_trigger_event_rule" {
  name                = "justjoinit-job-trigger-event-rule"
  description         = "Trigger for FetchRawJustJoinItData job (lambda function)."
  schedule_expression = "cron(45 16 * * ? *)"
}

resource "aws_cloudwatch_event_target" "justjoinit_job_trigger_event_target" {
  arn  = aws_lambda_function.fetch_justjoinit_raw_data.arn
  rule = aws_cloudwatch_event_rule.justjoinit_job_trigger_event_rule.id
}
