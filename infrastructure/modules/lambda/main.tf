data "aws_iam_policy_document" "assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "_" {
  name               = "${var.name}-lambda"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

data "aws_iam_policy_document" "_" {
  statement {
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["${aws_lambda_function._.arn}"]
    actions   = ["lambda:InvokeFunction"]
  }
}

resource "aws_iam_policy" "_" {
  name   = "${var.name}-lambda-policy"
  policy = data.aws_iam_policy_document._.json
}

resource "aws_iam_role_policy_attachment" "_" {
  role       = aws_iam_role._.name
  policy_arn = aws_iam_policy._.arn
}

resource "aws_lambda_function" "_" {
  function_name = var.name
  role          = aws_iam_role._.arn
  handler       = "main"
  runtime       = "provided.al2023"

  s3_bucket = var.source_bucket
  s3_key    = var.name

  publish = true

  timeout = var.timeout

  depends_on = [
    aws_s3_object._
  ]
}

resource "aws_lambda_alias" "_" {
  name             = "${var.name}-latest"
  description      = "Latest function version"
  function_name    = aws_lambda_function._.function_name
  function_version = "$LATEST"
}

resource "aws_s3_object" "_" {
  bucket = var.source_bucket
  key    = var.name
  source = data.archive_file._.output_path
}

data "archive_file" "_" {
  type        = "zip"
  output_path = "${path.module}/files/archive.zip"
  source {
    content  = "exports.handler = e => {console.log(e)}"
    filename = "index.js"
  }
}
