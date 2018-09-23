resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.s3_bucket_name}"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_notification" "lambda_bucket_notification" {
  bucket = "${aws_s3_bucket.s3_bucket.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.meta_lambda.arn}"
    events              = ["s3:ObjectCreated:*"]
    # filter_prefix       = "some-path/"
    # filter_suffix       = "*.csv"
  }
}
