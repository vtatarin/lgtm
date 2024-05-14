resource "aws_s3_bucket" "state" {
  bucket_prefix = "lgtm-playground-tfstate-"
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}
