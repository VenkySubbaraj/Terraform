resource "aws_cloudwatch_metric_alarm" "alarms" {
  for_each = var.alarms

  alarm_name          = each.key
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = each.value["metric_name"]
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = each.value["threshold"]

  dimensions = {
  FunctionName = each.value.function_name
  }

  alarm_description = "This metric monitors ${each.value["metric_name"]} and triggers an alarm if it exceeds ${each.value["threshold"]} for 2 evaluation periods."
  
  alarm_actions = each.value["actions"]
}
