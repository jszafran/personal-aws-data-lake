import datetime
import hashlib
import pathlib
import shutil
from typing import Dict

import boto3
import urllib3
from etl_common import messages

# lambda layer
from etl_common.hash_tracker import get_data_sources_hash_history, get_most_recent_hash

S3 = boto3.resource("s3")
SOURCES_HASHES_OBJECT = S3.Object(
    "jszafran-data-lake",
    "etl-metadata/eurostat-weekly-deaths/data-source-hashes.json",
)
ENCODING = "UTF-8"
DATA_SOURCE_URL = "https://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?file=data/demo_r_mwk_05.tsv.gz"  # noqa

HashHistory = Dict[datetime.datetime, str]


def lambda_handler(event, context):
    http = urllib3.PoolManager()
    current_time = datetime.datetime.utcnow().strftime("%Y%m%d_%H%M%S")
    filename = f"eurostat-weekly-deaths-{current_time}.tsv.gz"
    source_path = pathlib.Path(f"/tmp/{filename}")

    with http.request("GET", DATA_SOURCE_URL, preload_content=False) as resp, open(
        source_path, "wb"
    ) as out:
        shutil.copyfileobj(resp, out)

    with open(source_path, "rb") as f:
        source_hash = hashlib.sha256(f.read()).hexdigest()

    sources_hash_history = get_data_sources_hash_history()

    if source_hash == get_most_recent_hash(sources_hash_history):
        return {"message": messages.SOURCE_HASH_ALREADY_PROCESSED}

    target_object = S3.Object(
        "jszafran-data-lake", f"raw-layer/eurostat-weekly-deaths/{filename}"
    )
    sources_hash_history[datetime.datetime.utcnow()] = source_hash

    with open(source_path, "rb") as f:
        target_object.put(Body=f.read())

    return {
        "message": messages.SOURCE_READY_FOR_PROCESSING,
        "source_hash": source_hash,
        "s3_input_path": f"s3://{target_object.bucket_name}/{target_object.key}",
    }
