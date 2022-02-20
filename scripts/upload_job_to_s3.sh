# utility for uploading given job to S3 Glue jobs location
SCRIPT_PATH="$PWD/py_sources/glue_jobs/$1"

AWS_PROFILE=terraform aws s3 cp $SCRIPT_PATH s3://jszafran-data-lake/jobs-scripts/$1
