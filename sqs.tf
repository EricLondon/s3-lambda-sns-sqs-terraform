resource "aws_sqs_queue" "sqs_queue" {
  name   = "${var.sqs_queue_name}"
  policy = "${data.aws_iam_policy_document.sqs_queue_policy_document.json}"
}

data "aws_iam_policy_document" "sqs_queue_policy_document" {
  policy_id = "arn:aws:sqs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${var.sqs_queue_name}/SQSDefaultPolicy"

  statement {
    sid    = "sns-to-sqs"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "SQS:SendMessage",
    ]

    resources = [
      "arn:aws:sqs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${var.sqs_queue_name}"
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [
        "arn:aws:sns:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${var.sns_topic_name}"
      ]
    }
  }
}
