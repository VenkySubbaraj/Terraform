 provider "aws"{
    region = "eu-central-1"
 }



 resource "aws_cloudwatch_event_rule" "trigger_on_Gluejob_failure" {
  name        = "TriggerOnGluejobFailure"
  description = "Triggers Lambda on Glue Job Failure"
  event_pattern = jsonencode({
    source = ["aws.glue"],
    detail_type = ["Glue Job State Change"],
    detail = {
      state = ["FAILED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "invoke_lambda_on_failure" {
  depends_on = [aws_cloudwatch_event_rule.trigger_on_Gluejob_failure]  
  rule      = aws_cloudwatch_event_rule.trigger_on_Gluejob_failure.name
  target_id = "invoke_lambda"
  arn       = aws_lambda_function.notify_on_Gluejob_failure.arn
}

resource "aws_sns_topic" "Gluejob_failure_topic" {
  name = "GlueGluejobFailureTopic"
}

resource "aws_sns_topic_policy" "Gluejob_failure_topic_policy" {
  depends_on  = [aws_lambda_function.notify_on_Gluejob_failure]
  arn = aws_sns_topic.Gluejob_failure_topic.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "GluejobFailureTopicPolicy",
    Statement = [
      {
        Sid       = "AllowLambdaPublish",
        Effect    = "Allow",
        Principal = "*",
        Action    = "sns:Publish",
        Resource  = aws_sns_topic.Gluejob_failure_topic.arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_lambda_function.notify_on_Gluejob_failure.arn
          }
        }
      }
    ]
  })
}

resource "aws_lambda_function" "notify_on_Gluejob_failure" {
  depends_on       = [aws_iam_role_policy_attachment.lambda_invoker_policy_attachment]
  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("./lambda_function.zip")
  function_name    = "NotifyGluejobFailure"
  role             = aws_iam_role.lambda_invoker_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  timeout          = "180"
  environment {
        variables = {
            "BUCKETNAME"  = "yara-das-ffdp-raw-eucentral1-479055760150-stage-stitch"
            "OBJECTKEY"   = "runbook/runbook_reference.json"
            "secret_name" = "yard_webhook_teams"
            }
        }
}

resource "aws_lambda_permission" "allow_sns_invoke_lambda" {
  depends_on       = [aws_lambda_function.notify_on_Gluejob_failure]  
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notify_on_Gluejob_failure.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.Gluejob_failure_topic.arn
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
  depends_on       = [aws_iam_role.lambda_invoker_role]  
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
  depends_on       = [aws_iam_policy.lambda_invoker_policy]    
  policy_arn = aws_iam_policy.lambda_invoker_policy.arn
  role       = aws_iam_role.lambda_invoker_role.name
}

resource "aws_cloudwatch_metric_alarm" "glue_failed_jobs_alarm" {
  alarm_name          = "GlueJobProcessingFailedAlarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = "1"
  metric_name         = "glue.driver.aggregate.numFailedTasks"
  namespace           = "Glue"
  period              = "60" 
  statistic           = "Sum"
  threshold           = "1"
  alarm_description  = "Alarm for Glue failed jobs"
  dimensions = {
    JobName = "ALL"
    JobRunId = "ALL"
    unit = "count"
  }

  alarm_actions = [aws_sns_topic.Gluejob_failure_topic.arn]
}
