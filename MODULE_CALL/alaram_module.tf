
module "cloudwatch_alarms" {
  source = "./module/cloudwatch_alarms"
  
  # Define parameters for each alarm
  alarms = {
    high_cpu_utilization = {
      metric_name = "CPUUtilization"
      threshold = 90
      actions = ["arn:aws:sns:us-west-2:123456789012:MyTopic"]
      FunctionName = "lambda_function1"
    }
    low_disk_space = {
      metric_name = "DiskSpaceUtilization"
      threshold = 80
      actions = ["arn:aws:sns:us-west-2:123456789012:MyTopic"]
      FunctionName = "lambda_function1"
    }
    # Add more alarms as needed
  }
}
