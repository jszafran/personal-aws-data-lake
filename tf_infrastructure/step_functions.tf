data "template_file" "eurostat_etl_state_machine" {
  template = file("eurostat_etl_state_machine_definition.tpl")

  vars = {
    comment                            = "Test comment rendering"
    check_eurostat_input_data_hash_arn = aws_lambda_function.check_eurostat_input_data_hash.arn
    eurostat_process_raw_data_arn      = aws_lambda_function.eurostat_process_raw_data.arn
    publish_message_arn                = aws_lambda_function.publish_message.arn
    job_succeeded_topic_arn            = aws_sns_topic.etl_job_succeeded.arn

  }
}

resource "aws_sfn_state_machine" "eurostat_etl_state_machine" {

  definition = data.template_file.eurostat_etl_state_machine.rendered
  name       = "EurostatETLStateMachine"
  role_arn   = aws_iam_role.step_functions_data_lake_role.arn
}
