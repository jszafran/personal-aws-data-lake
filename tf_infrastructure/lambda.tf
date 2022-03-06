variable "aws_datawrangler_py39_useast1_arn" {
  type    = string
  default = "arn:aws:lambda:us-east-1:336392948345:layer:AWSDataWrangler-Python39:1"
}

// TODO: Switch archive files for Lambda to tf lambda module in the future
// zips
data "archive_file" "fetch_justjoinit_raw_data_zip_file" {
  type        = "zip"
  output_path = "/tmp/fetch_justjoinit_raw_data_zip_file.zip"
  source {
    content  = file("../src/justjoinit/fetch_justjoinit_raw_data.py")
    filename = "lambda_function.py"
  }
}

data "archive_file" "check_eurostat_input_data_hash_zip_file" {
  type        = "zip"
  output_path = "/tmp/check_eurostat_input_data_hash_zip_file.zip"
  source {
    content  = file("../src/eurostat_weekly_deaths_etl/eurostat_check_input_data_hash.py")
    filename = "lambda_function.py"
  }
}

data "archive_file" "eurostat_process_raw_data_zip_file" {
  type        = "zip"
  output_path = "/tmp/data_lake_tf/eurostat_process_raw_data.zip"
  source {
    content  = file("../src/eurostat_weekly_deaths_etl/process_raw_data.py")
    filename = "lambda_function.py"
  }
}

data "archive_file" "publish_message_zip_file" {
  type        = "zip"
  output_path = "/tmp/publish_message.zip"
  source {
    content  = file("../src/common/lambda/publish_message.py")
    filename = "lambda_function.py"
  }
}

data "archive_file" "eurostat_etl_common_layer" {
  type        = "zip"
  output_path = "/tmp/data_lake_tf/eurostat_lambda_layer.zip"
  source_dir  = "../src/eurostat_weekly_deaths_etl/lambda-layer"
}

data "archive_file" "notifications_lambda_layer" {
  type        = "zip"
  output_path = "/tmp/data_lake_tf/notifications_lambda_layer.zip"
  source_dir  = "../src/common/notifications-lambda-layer"
}

// lambda functions
resource "aws_lambda_function" "fetch_justjoinit_raw_data" {
  function_name    = "fetch_justjoinit_raw_data"
  role             = aws_iam_role.lambda_data_lake_role.arn
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.fetch_justjoinit_raw_data_zip_file.output_path
  source_code_hash = data.archive_file.fetch_justjoinit_raw_data_zip_file.output_base64sha256
  runtime          = var.default_python_lambda_runtime
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
  runtime          = var.default_python_lambda_runtime
  timeout          = 20
  layers           = [aws_lambda_layer_version.eurostat_etl_common_layer.arn]
}

resource "aws_lambda_function" "eurostat_process_raw_data" {
  function_name    = "eurostat_process_raw_data"
  role             = aws_iam_role.lambda_data_lake_role.arn
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.eurostat_process_raw_data_zip_file.output_path
  source_code_hash = data.archive_file.eurostat_process_raw_data_zip_file.output_base64sha256
  runtime          = var.default_python_lambda_runtime
  timeout          = 120
  memory_size      = 2048
  layers = [
    aws_lambda_layer_version.eurostat_etl_common_layer.arn,
    var.aws_datawrangler_py39_useast1_arn
  ]
}

resource "aws_lambda_function" "publish_message" {
  function_name    = "publish_message"
  role             = aws_iam_role.lambda_data_lake_role.arn
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.publish_message_zip_file.output_path
  source_code_hash = data.archive_file.publish_message_zip_file.output_base64sha256
  runtime          = var.default_python_lambda_runtime
  timeout          = 5
  memory_size      = 128
  layers = [
    aws_lambda_layer_version.notifications_lambda_layer.arn,
  ]
}

// lambda layers
resource "aws_lambda_layer_version" "eurostat_etl_common_layer" {
  filename         = data.archive_file.eurostat_etl_common_layer.output_path
  layer_name       = "eurostat_etl_common_layer"
  source_code_hash = data.archive_file.eurostat_etl_common_layer.output_base64sha256

  compatible_runtimes = [var.default_python_lambda_runtime]
}

resource "aws_lambda_layer_version" "notifications_lambda_layer" {
  filename         = data.archive_file.notifications_lambda_layer.output_path
  layer_name       = "notifications_layer"
  source_code_hash = data.archive_file.notifications_lambda_layer.output_base64sha256

  compatible_runtimes = [var.default_python_lambda_runtime]
}
