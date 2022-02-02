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

## creating policy for EMR ##
resource "aws_iam_policy" "EMR" {
 name = "EMR"
 path = "/"
 description = "AWS IAM policy for creating the EMR"
 policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
{
 "Sid": "VisualEditor0",
 "Effect": "Allow",
 "Action": "elasticmapreduce:*",
 "Resource": "*"
}
]
}
EOF
}

## creating policy for S3 ##
resource "aws_iam_policy" "S3" {
 name = "S3"
 path = "/"
 description = "AWS IAM policy for creating the s3"
 policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
{
"Sid" : "S3FullAccess",
"Action": "s3:*",
"Effect": "Allow",
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
