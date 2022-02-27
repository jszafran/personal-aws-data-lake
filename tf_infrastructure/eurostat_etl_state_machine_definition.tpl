{
  "Comment": "State machine for Eurostat Weekly Deaths ETL",
  "StartAt": "Download source, compute its hash and check if it was already processed.",
  "States": {
    "Download source, compute its hash and check if it was already processed.": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "FunctionName": "${check_eurostat_input_data_hash_arn}"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 2,
          "BackoffRate": 2
        }
      ],
      "Next": "Choice"
    },
    "Choice": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.message",
          "StringEquals": "SourceReadyForProcessing",
          "Next": "Process raw data ang generate parquet"
        }
      ],
      "Default": "Send Email notification (no new data ingested)"
    },
    "Send Email notification (no new data ingested)": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "FunctionName": "${publish_message_arn}:$LATEST",
        "Payload": {
          "topic_arn": "${job_succeeded_topic_arn}",
          "subject": "Eurostat ETL succeeded without ingesting new data",
          "message_body": "No new data was ingested - source code hash already exists."
        }
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 2,
          "BackoffRate": 2
        }
      ],
      "End": true
    },
    "Process raw data ang generate parquet": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "${eurostat_process_raw_data_arn}:$LATEST"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 1,
          "BackoffRate": 2
        }
      ],
      "Next": "Send email notification (new data ingested)"
    },
    "Send email notification (new data ingested)": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload": {
          "topic_arn": "${job_succeeded_topic_arn}",
          "subject": "Eurostat ETL succeeded with ingesting new data",
          "message_body": "New data was successfully ingested."
        },
        "FunctionName": "${publish_message_arn}:$LATEST"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 6,
          "BackoffRate": 2
        }
      ],
      "End": true
    }
  }
}
