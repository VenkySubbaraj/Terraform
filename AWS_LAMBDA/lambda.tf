provider "aws" {
 region = "ap-south-1"
}

##zip compression for python file ##
data "archive_file" "zip_the_python_code" {
type        = "zip"
source_dir  = "./python/"
output_path = "./python/hello.zip"
}

module "lambda-cloudwatch-trigger" {
  source  = "infrablocks/lambda-cloudwatch-events-trigger/aws"
  region                = var.region
  component             = var.component
  deployment_identifier = var.deployment_identifier

  lambda_arn =  aws_lambda_function.terraform_func.arn
  lambda_function_name = aws_lambda_function.terraform_func.function_name
  lambda_schedule_expression = "rate(10000000 days)"
}

##creating the lambda function##

resource "aws_lambda_function" "terraform_func" {
filename                       = "./python/hello.zip"
function_name                  = var.function_name
role                           = aws_iam_role.lambda_role.arn
handler                        = var.handler
runtime                        = var.runtime
source_code_hash	       = filebase64sha256("./python/hello.zip")
depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}

##################################################################################################################################################
##
## Creating Lambda Function for To Launch EMR Cluster #####
##################################################################################################################################################

##zip compression for Python File ##
#data "archive_file" "zip_python_code" {
#type = "zip"
#source_dir = "./EMRpython/"
#output_path = "./EMRpython/hello.zip"
#}

##creating Lambda Function for EMR Cluster##
#resource "aws_lambda_function" "EMR_Terraform" {
#filename = "./EMRpython/hello.zip"
#function_name =var.lambda_function_name
#role = aws_iam_role.lambda_role.arn
#handler = var.handler
#runtime = var.runtime
#source_code_hash = filebase64sha256("./EMRpython/hello.zip")
#depends_on = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
#}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "Instance_Profile"
  role = aws_iam_role.lambda_role.name
}
