
variable "aws_region" {
  type    = "string"
  default = "us-east-1"
}

variable "aws_profile" {
  type    = "string"
  default = ""
}

variable "aws_credentials_file" {
  type    = "string"
  default = "~/.aws/credentials"
}

variable "s3_bucket_name" {
  type    = "string"
  default = ""
}

variable "sns_topic_name" {
  type    = "string"
  default = ""
}

variable "sqs_queue_name" {
  type    = "string"
  default = ""
}
