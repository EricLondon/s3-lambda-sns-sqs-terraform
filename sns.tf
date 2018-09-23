resource "aws_sns_topic" "sns_topic" {
  name = "${var.sns_topic_name}"
}

resource "aws_sns_topic_subscription" "sqs_subscription" {
  topic_arn = "${aws_sns_topic.sns_topic.arn}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.sqs_queue.arn}"

  filter_policy = <<EOF
  {
    "filter-by": ["this-filter-value"]
  }
  EOF
}
