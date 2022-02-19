variable "data_lake_bucket_name" {
  description = "Name of the bucket serving as my data lake main storage place."
  type = string
  default = "jszafran-data-lake"
}

variable "raw_layer_prefix" {
  description = "S3 prefix denoting location for raw layer."
  type = string
  default = "raw-layer"
}

variable "curated_area_prefix" {
  description = "S3 prefix denoting location for curated layer."
  type = string
  default = "curated-layer"
}

variable "region" {
  description = "AWS Region"
  type = string
  default = "us-east-1"
}
