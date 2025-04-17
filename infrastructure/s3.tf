resource "aws_s3_bucket" "codepipeline" {
  bucket = "${local.project}-codepipeline"
}

resource "aws_s3_bucket_ownership_controls" "codepipeline" {
  bucket = aws_s3_bucket.codepipeline.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "codepipeline" {
  depends_on = [aws_s3_bucket_ownership_controls.codepipeline]

  bucket = aws_s3_bucket.codepipeline.id
  acl    = "private"
}

resource "aws_s3_bucket" "lambda_source" {
  bucket = "${local.project}-lambda-source"
}

resource "aws_s3_bucket_ownership_controls" "lambda_source" {
  bucket = aws_s3_bucket.lambda_source.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "lambda_source" {
  depends_on = [aws_s3_bucket_ownership_controls.lambda_source]

  bucket = aws_s3_bucket.lambda_source.id
  acl    = "private"
}
