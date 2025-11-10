resource "aws_sqs_queue" "this" {
  name                      = var.name
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds = 345600
}

resource "aws_sqs_queue" "dlq" {
  count                     = var.create_dlq ? 1 : 0
  name                      = "${var.name}-dlq"
  message_retention_seconds = 1209600
}
