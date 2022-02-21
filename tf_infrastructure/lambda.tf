data "archive_file" "fetch_justjoinit_raw_data_zip_file" {
  type        = "zip"
  output_path = "/tmp/fetch_justjoinit_raw_data_zip_file.zip"
  source {
    content  = file("../py_sources/lambdas/fetch_justjoinit_raw_data.py")
    filename = "lambda_function.py"
  }
}

data "archive_file" "check_eurostat_input_data_hash_zip_file" {
  type        = "zip"
  output_path = "/tmp/check_eurostat_input_data_hash_zip_file.zip"
  source {
    content  = file("../py_sources/lambdas/eurostat_check_input_data_hash.py")
    filename = "lambda_function.py"
  }
}

resource "aws_lambda_function" "fetch_justjoinit_raw_data" {
  function_name    = "fetch_justjoinit_raw_data"
  role             = aws_iam_role.lambda_data_lake_role.arn
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.fetch_justjoinit_raw_data_zip_file.output_path
  source_code_hash = data.archive_file.fetch_justjoinit_raw_data_zip_file.output_base64sha256
  runtime          = "python3.9"
  timeout          = 15

  environment {
    variables = {
      JOB_FAILED_TOPIC_ARN = aws_sns_topic.etl_job_failed.arn
    }
  }
}

resource "aws_lambda_function" "check_eurostat_input_data_hash" {
  function_name    = "check_eurostat_input_data_hash"
  role             = aws_iam_role.lambda_data_lake_role.arn
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.check_eurostat_input_data_hash_zip_file.output_path
  source_code_hash = data.archive_file.check_eurostat_input_data_hash_zip_file.output_base64sha256
  runtime          = "python3.9"
  timeout          = 20
}
