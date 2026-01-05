terraform {
    backend "s3" {
        bucket = "oleksii-terraform-state-bucket"
        key = "global/s3/terraform.tfstate"
        region = "us-east-2"
        profile = "default"
        dynamodb_table = "terraform-locks"
        encrypt = true
    }
}



provider "aws" {
  region  = var.region
  profile = "default"
}

resource "aws_s3_bucket" "terraform-state-bucket" {
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform-state-versioning" {
  bucket = aws_s3_bucket.terraform-state-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform-state-encryption-configuration" {
  bucket = aws_s3_bucket.terraform-state-bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform-locks" {
    name = var.dynamodb_table_name
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
    server_side_encryption {
        enabled = true
    }
    lifecycle {
        prevent_destroy = true
    }
}

resource "aws_s3_bucket_public_access_block" "terraform-state-public-access" {
  bucket                  = aws_s3_bucket.terraform-state-bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
