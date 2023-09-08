terraform {  
required_version = "~> 1.1.0"
required_providers {
     aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }    
  }
}

provider aws{
  //profile = "admin"
  //region = "us-east-1"
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

provider "archive" {}
data "archive_file" "zip" {
  type        = "zip"
  source_file = "snsProcessing.py"
  output_path = "snsProcessing.zip"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_lambda_function" "lambda" {
  function_name = "snsLambda"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  role    = aws_iam_role.iam_for_lambda.arn
  handler = "snsLambda.lambda_handler"
  runtime = "python3.9"
}

resource "aws_lambda_function" "lambda1" {
  function_name = "snsLambda1"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  role    = aws_iam_role.iam_for_lambda.arn
  handler = "snsLambda.lambda_handler"
  runtime = "python3.9"
}






