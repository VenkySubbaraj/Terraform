resource "aws_cloudwatch_event_rule" "trigger_on_crawler_failure" {
  name        = "TriggerOnCrawlerFailure"
  description = "Triggers Lambda on Glue Crawler Failure"
  event_pattern = jsonencode({
    source = ["aws.glue"],
    detail_type = ["Glue Crawler State Change"],
    detail = {
      state = ["FAILED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "invoke_lambda_on_failure" {
  rule      = aws_cloudwatch_event_rule.trigger_on_crawler_failure.name
  target_id = "invoke_lambda"
  arn       = aws_lambda_function.notify_on_crawler_failure.arn
}

resource "aws_sns_topic" "crawler_failure_topic" {
  name = "GlueCrawlerFailureTopic"
}

resource "aws_sns_topic_policy" "crawler_failure_topic_policy" {
  arn = aws_sns_topic.crawler_failure_topic.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "CrawlerFailureTopicPolicy",
    Statement = [
      {
        Sid       = "AllowLambdaPublish",
        Effect    = "Allow",
        Principal = "*",
        Action    = "sns:Publish",
        Resource  = aws_sns_topic.crawler_failure_topic.arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_lambda_function.notify_on_crawler_failure.arn
          }
        }
      }
    ]
  })
}

resource "aws_lambda_function" "example_lambda" {
  function_name    = "example-lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"

  filename = "lambda.zip"  # Your deployment package (ZIP file or container image)

  source_code_hash = filebase64sha256("lambda.zip")  # Hash of the deployment package

  # Assuming your Python code is in a file named "lambda_function.py"
  source_code = file("lambda_function.py")

  environment {
    variables = {
      MESSAGE = "Hello from Terraform Lambda!"
    }
  }
}

resource "aws_lambda_permission" "allow_sns_invoke_lambda" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notify_on_crawler_failure.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.crawler_failure_topic.arn
}


resource "aws_iam_role" "lambda_invoker_role" {
  name = "LambdaInvokerRole"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_invoker_policy" {
  name        = "LambdaInvokerPolicy"
  description = "Policy to allow invoking Lambda functions"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "lambda:InvokeFunction",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_invoker_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_invoker_policy.arn
  role       = aws_iam_role.lambda_invoker_role.name
}
