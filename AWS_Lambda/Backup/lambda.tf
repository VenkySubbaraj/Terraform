provider "aws" {
 region = "ap-south-1"
}

##zip compression for python file ##
data "archive_file" "zip_the_python_code" {
type        = "zip"
source_dir  = "./python/"
output_path = "./python/hello.zip"
}

#module "lambda-cloudwatch-trigger" {
#  source  = "infrablocks/lambda-cloudwatch-events-trigger/aws"
#  region                = "ap-south-1"
#  component             = "my-lambda2"
#  deployment_identifier = "production"

#  lambda_arn =  aws_lambda_function.terraform_func.arn
#  lambda_function_name = aws_lambda_function.terraform_func.function_name
#  lambda_schedule_expression = "rate(10000000 days)"
#}

##creating the lambda function##

#resource "aws_lambda_function" "terraform_func" {
#filename                       = "./python/hello.zip"
#function_name                  = "Instance_By_Lambda_Function"
#role                           = aws_iam_role.lambda_role.arn
#handler                        = "index.lambda_handler"
#runtime                        = "python3.8"
#source_code_hash	       = filebase64sha256("./python/hello.zip")
#depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
#}

##################################################################################################################################################
##
## Creating Lambda Function for To Launch EMR Cluster #####
##################################################################################################################################################

##zip compression for Python File ##
data "archive_file" "zip_python_code" {
type = "zip"
source_dir = "./EMRpython/"
output_path = "./EMRpython/hello.zip"
}

##creating Lambda Function for EMR Cluster##
resource "aws_lambda_function" "EMR_Terraform" {
filename = "./EMRpython/hello.zip"
function_name = "EMR_Instance"
role = aws_iam_role.lambda_role.arn
handler = "index.lambda_handler"
runtime = "python3.8"
source_code_hash = filebase64sha256("./EMRpython/hello.zip")
depends_on = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}
