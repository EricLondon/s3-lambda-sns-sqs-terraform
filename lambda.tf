resource "aws_lambda_function" "meta_lambda" {
  filename         = "meta_lambda.zip"
  function_name    = "meta_lambda"
  role             = "${aws_iam_role.meta_lambda_role.arn}"
  handler          = "meta_lambda.handler"
  source_code_hash = "${data.archive_file.meta_lambda_zip.output_base64sha256}"
  runtime          = "nodejs8.10"
   environment {
    variables = {
      AWS_ACCOUNT_ID = "${data.aws_caller_identity.current.account_id}"
      SNS_TOPIC_NAME = "${var.sns_topic_name}"
    }
  }
}

data "archive_file" "meta_lambda_zip" {
  type        = "zip"
  source_file = "meta_lambda.js"
  output_path = "meta_lambda.zip"
}

resource "aws_iam_role" "meta_lambda_role" {
  name = "meta_lambda_role"
  assume_role_policy = "${data.aws_iam_policy_document.meta_lambda.json}"
}

data "aws_iam_policy_document" "meta_lambda" {
  statement {
    sid = ""
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_lambda_permission" "lambda_allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.meta_lambda.function_name}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.s3_bucket.arn}"
}

resource "aws_iam_role_policy_attachment" "attach_lambda_role_policy" {
  role = "${aws_iam_role.meta_lambda_role.name}"
  policy_arn = "${aws_iam_policy.meta_lambda_policy.arn}"
}

resource "aws_iam_policy" "meta_lambda_policy" {
  name   = "meta_lambda_policy"
  policy = "${data.aws_iam_policy_document.meta_lambda_policy_document.json}"
}

data "aws_iam_policy_document" "meta_lambda_policy_document" {
  statement {
    sid = ""
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup"
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {
    sid = ""
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.meta_lambda.function_name}:*"
    ]
  }

  statement {
    sid = ""
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "${aws_s3_bucket.s3_bucket.arn}",
      "${aws_s3_bucket.s3_bucket.arn}/*"
    ]
  }

  statement {
    sid = ""
    effect = "Allow"
    actions = [
      "SNS:Publish"
    ]
    resources = [
      "${aws_sns_topic.sns_topic.arn}"
    ]
  }
}
