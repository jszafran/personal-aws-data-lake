"""

"""
from notifications import SNSNotificationPublisher


def lambda_handler(event, context):
    topic_arn = event.get("topic_arn")
    subject = event.get("subject")
    message_body = event.get("message_body")

    SNSNotificationPublisher.publish_message(
        topic_arn=topic_arn,
        subject=subject,
        message_body=message_body,
    )
