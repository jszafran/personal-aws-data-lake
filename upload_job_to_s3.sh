# utility for uploading given job to S3 Glue jobs location

AWS_PROFILE=terraform aws s3 cp ./glue_jobs/$1 s3://jszafran-data-lake/jobs-scripts/$1
