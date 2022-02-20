resource "aws_iam_role" "glue_data_lake_role" {
  name = "glue-data-lake-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "data_lake_s3_access_policy" {
  name        = "data-lake-s3-access-policy"
  description = "Policy allowing S3 access (read & write)."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "s3-object-lambda:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "data_lake_job_failed_sns_topic_publish_policy_document" {
  statement {
    sid = "1"
    actions = [
      "sns:Publish",
    ]
    resources = [
      aws_sns_topic.etl_job_failed.arn
    ]
  }
}

resource "aws_iam_policy" "data_lake_job_failed_sns_topic_publish_policy" {
  name        = "data-lake-job-failed-topic-publish-policy"
  description = "Allow to publish to job failed SNS topic."
  policy      = data.aws_iam_policy_document.data_lake_job_failed_sns_topic_publish_policy_document.json
}

resource "aws_iam_role" "lambda_data_lake_role" {
  name = "lambda-data-lake-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "glue-s3-access-role-policy-attachment" {
  role       = aws_iam_role.glue_data_lake_role.name
  policy_arn = aws_iam_policy.data_lake_s3_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda-s3-access-role-policy-attachment" {
  role       = aws_iam_role.lambda_data_lake_role.name
  policy_arn = aws_iam_policy.data_lake_s3_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda-sns-job-failed-topic-publish-policy-attachment" {
  role       = aws_iam_role.lambda_data_lake_role.name
  policy_arn = aws_iam_policy.data_lake_job_failed_sns_topic_publish_policy.arn
}
