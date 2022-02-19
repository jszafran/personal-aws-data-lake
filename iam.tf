resource "aws_iam_role" "glue_s3_data_lake_access_role" {
  name = "glue-s3-data-lake-access-role"

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

resource "aws_iam_policy" "glue_s3_access_policy" {
  name        = "glue-s3-data-lake-access-policy"
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
  role       = aws_iam_role.glue_s3_data_lake_access_role.name
  policy_arn = aws_iam_policy.glue_s3_access_policy.arn
}
