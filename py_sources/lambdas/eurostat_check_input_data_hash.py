import datetime
import hashlib
import json
import pathlib
import shutil
from typing import Dict, Optional

import boto3
import urllib3

S3 = boto3.resource("s3")
SOURCES_HASHES_OBJECT = S3.Object(
    "jszafran-data-lake",
    "etl-metadata/eurostat-weekly-deaths/data-source-hashes.json",
)
ENCODING = "UTF-8"
DATA_SOURCE_URL = "https://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?file=data/demo_r_mwk_05.tsv.gz"  # noqa

HashHistory = Dict[datetime.datetime, str]


def get_data_sources_hash_history() -> HashHistory:
    """
    Fetches data source hashes history from S3.
    """
    sources_hash_history = {}
    try:
        sources_hash_history = json.loads(
            SOURCES_HASHES_OBJECT.get()["Body"].read().decode(ENCODING)
        )
        sources_hash_history = {
            datetime.datetime.fromisoformat(k): v
            for k, v in sources_hash_history.items()
        }
    except S3.meta.client.exceptions.NoSuchKey:
        pass
    return sources_hash_history


def save_sources_hash_history(hash_history: HashHistory) -> None:
    hash_history = {k.isoformat(): v for k, v in hash_history.items()}
    SOURCES_HASHES_OBJECT.put(Body=bytes(json.dumps(hash_history).encode(ENCODING)))


def get_most_recent_hash(hash_history: HashHistory) -> Optional[str]:
    if len(hash_history) == 0:
        return None
    return sorted(hash_history.items(), key=lambda x: x[0], reverse=True)[0][1]


def lambda_handler(event, context):
    http = urllib3.PoolManager()
    source_path = pathlib.Path("/tmp/eurostat_data.tsv")

    with http.request("GET", DATA_SOURCE_URL, preload_content=False) as resp, open(
        source_path, "wb"
    ) as out:
        shutil.copyfileobj(resp, out)

    with open(source_path, "rb") as f:
        source_hash = hashlib.sha256(f.read()).hexdigest()
    sources_hash_history = get_data_sources_hash_history()

    if source_hash == get_most_recent_hash(sources_hash_history):
        return {"message": f"Hash {source_hash} already processed."}

    sources_hash_history[datetime.datetime.utcnow()] = source_hash
    save_sources_hash_history(sources_hash_history)
    # TODO:
    # push to S3 & return message with S3 link that will be picked up by next task in AWS Step Function workflow
    return {"message": "About to process hash"}
