variable "bucket_name" {
  description = "The name of the S3 bucket"
  type = string
  default = "oleksii-terraform-state-bucket"
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  type = string
  default = "terraform-locks"
}

variable "region" {
  description = "The region of the S3 bucket"
  type = string
  default = "us-east-2"
}
