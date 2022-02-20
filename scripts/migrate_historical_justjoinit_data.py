"""
Migrates historical data for JustJoinIT to new data lake bucket & location.
"""
import datetime
import os
import pathlib
import time
from concurrent import futures

import boto3
from dotenv import load_dotenv

load_dotenv(pathlib.Path(__file__).parent.parent / ".env")

S3 = boto3.resource(
    "s3",
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
)
SOURCE_BUCKET = S3.Bucket("justjoinit-raw-data")
TARGET_BUCKET = S3.Bucket("jszafran-data-lake")


def _migrate_object(s3_object):
    source_data = {"Bucket": s3_object.bucket_name, "Key": s3_object.key}
    TARGET_BUCKET.copy(source_data, f"raw-layer/justjoinit/{s3_object.key}")
    print(f"{s3_object.key} moved.")


def main():
    files = list(SOURCE_BUCKET.objects.all())
    print(f"About to copy {len(files)} files.")

    start_time = time.monotonic()

    with futures.ThreadPoolExecutor(max_workers=10) as pool:
        _ = pool.map(_migrate_object, files)

    time_elapsed = round(time.monotonic() - start_time, 2)

    print(f"Migration done. It took: {datetime.timedelta(seconds=time_elapsed)}")


if __name__ == "__main__":
    main()
