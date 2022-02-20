import urllib3
import boto3
import datetime


JUSTJOINIT_URL = "https://justjoin.it/api/offers"
S3 = boto3.resource("s3")


def lambda_handler(event, context):
    """
    Fetches raw https://justjoin.it offers data and saves to S3.
    """
    http = urllib3.PoolManager()
    today = datetime.date.today()
    year, month, day = today.year, today.month, today.day
    s3_object = S3.Object("jszafran-data-lake", f"raw-layer/justjoinit/{year}/{month}/{day}.json")

    response = http.request(
        "GET",
        JUSTJOINIT_URL,
        timeout=urllib3.Timeout(connect=5.0, read=5.0),
    )

    if response.status != 200:
        # TODO: implement some kind of notification (SNS)?
        return "error"

    s3_object.put(Body=response.data)
    return {'message': f"FetchRawJustJoinItData for {today.isoformat()} succeeded."}
