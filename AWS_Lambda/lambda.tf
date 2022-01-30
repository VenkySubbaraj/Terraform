provider "aws" {
	region = "ap-south-1"
}

##creating the role for Lambda##
resource "aws_iam_role" "lambda_role" {
name   = "Lambda_Function_Role"
assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

## creating the policy for EC2 instance for Lambda ##
resource "aws_iam_policy" "EC2_policy"{
name = "RunInstance_policy"
path = "/"
policy = <<EOF
{
 "Version":"2012-10-17",
 "Statement" : [{
	"Action": "ec2:RunInstances",
	"Effect": "Allow",
	"Sid": "VisualEditor0",
	"Resource":"*"
}]}
EOF
}

##creating the policy for SSM and attaching to the role##

resource "aws_iam_policy" "policy_for_SSM" {
name = "session_manager"
path = "/"
policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "ds:CreateComputer",
                "ds:DescribeDirectories",
                "ec2:DescribeInstanceStatus",
                "logs:*",
                "ssm:*",
                "ec2messages:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "arn:aws:iam::*:role/aws-service-role/ssm.amazonaws.com/AWSServiceRoleForAmazonSSM*",
            "Condition": {
                "StringLike": {
                    "iam:AWSServiceName": "ssm.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:DeleteServiceLinkedRole",
                "iam:GetServiceLinkedRoleDeletionStatus"
            ],
            "Resource": "arn:aws:iam::*:role/aws-service-role/ssm.amazonaws.com/AWSServiceRoleForAmazonSSM*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


##creating policy for Lambda##
resource "aws_iam_policy" "iam_policy_for_lambda" {
 
 name         = "aws_iam_policy_for_terraform_aws_lambda_role"
 path         = "/"
 description  = "AWS IAM Policy for managing aws lambda role"
 policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   }
 ]
}
EOF
}

###Attaching the policy for specific role###

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 role        = aws_iam_role.lambda_role.name
 policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}

resource "aws_iam_role_policy_attachment" "policy_role" {
 role = aws_iam_role.lambda_role.name
 policy_arn = aws_iam_policy.EC2_policy.arn
}

resource "aws_iam_role_policy_attachment" "ssm_policy_role" {
 role = aws_iam_role.lambda_role.name
 policy_arn = aws_iam_policy.policy_for_SSM.arn
}

##zip compression for python file ##
data "archive_file" "zip_the_python_code" {
type        = "zip"
source_dir  = "./python/"
output_path = "./python/hello.zip"
}

resource "aws_cloudwatch_log_group" "exp" {
  name              = aws_lambda_function.terraform_func.function_name
  retention_in_days = 14
}

module "lambda-cloudwatch-trigger" {
  source  = "infrablocks/lambda-cloudwatch-events-trigger/aws"
  region                = "ap-south-1"
  component             = "my-lambda2"
  deployment_identifier = "production"

  lambda_arn =  aws_lambda_function.terraform_func.arn
  lambda_function_name = aws_lambda_function.terraform_func.function_name
  lambda_schedule_expression = "rate(10000000 days)"
}

##creating the lambda function##

resource "aws_lambda_function" "terraform_func" {
filename                       = "./python/hello.zip"
function_name                  = "Instance_By_Lambda_Function"
role                           = aws_iam_role.lambda_role.arn
handler                        = "index.lambda_handler"
runtime                        = "python3.8"
source_code_hash	       = filebase64sha256("./python/hello.zip")
depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}


