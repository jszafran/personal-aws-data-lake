resource "aws_glue_catalog_database" "eurostat_database" {
  name        = "eurostat_db"
  description = "Database for data ingested from Eurostat"
}

resource "aws_glue_catalog_table" "eurostat_weekly_deaths" {
  name          = "weekly_deaths"
  database_name = aws_glue_catalog_database.eurostat_database.name
  description   = "Data about weekly deaths (starting from 2000) sent by countries from EU."
  table_type    = "EXTERNAL"
  parameters = {
    EXTERNAL = "TRUE"
  }

  storage_descriptor {
    location = "s3://jszafran-data-lake/"
  }
}

resource "aws_glue_job" "hello_world_glue_spark_job" {
  name              = "hello-world-glue-job"
  role_arn          = aws_iam_role.glue_data_lake_role.arn
  glue_version      = "3.0"
  number_of_workers = 2
  worker_type       = "G.1X"
  max_retries       = 0
  timeout           = 5
  description       = "Hello world type of job - just to make sure that creation of basic job through Terraform works."
  command {
    script_location = "s3://${aws_s3_bucket.data_lake_bucket.bucket}/${var.glue_jobs_prefix}/hello_world_job.py"
    python_version  = "3"
  }
}
