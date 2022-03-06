variable "data_lake_bucket_name" {
  description = "Name of the bucket serving as my data lake main storage place."
  type        = string
  default     = "jszafran-data-lake"
}

variable "raw_layer_prefix" {
  description = "S3 prefix denoting location for raw layer."
  type        = string
  default     = "raw-layer"
}

variable "curated_area_prefix" {
  description = "S3 prefix denoting location for curated layer."
  type        = string
  default     = "curated-layer"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "glue_jobs_prefix" {
  description = "S3 prefix denoting locations for all Glue jobs."
  type        = string
  default     = "jobs-scripts"
}

variable "notifications_email_address" {
  description = "Email address for sending all data lake related notifications."
  type        = string
  default     = "jsz.datalake.notifications@gmail.com"
}

variable "data_lake_admin_email" {
  description = "Data lake admin email"
  type        = string
  default     = "jszafran.pv@gmail.com"
}

variable "default_python_lambda_runtime" {
  type    = string
  default = "python3.9"
}
