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

resource "aws_iam_role_policy_attachment" "glue-s3-access-role-policy-attachment" {
  role       = aws_iam_role.glue_data_lake_role.name
  policy_arn = aws_iam_policy.data_lake_s3_access_policy.arn
}
