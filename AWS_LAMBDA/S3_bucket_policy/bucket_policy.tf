terraform {
  required_providers {
    aws = {
      #source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

data "aws_caller_identity" "dev" {}

data "aws_caller_identity" "prod" {
  provider = aws.prod
}

# Utils account containing users
provider "aws" {
  profile = "dev"
  region  = var.region_dev
  access_key = var.access_key_dev
  secret_key = var.secret_key_dev
}

# Prod account
provider "aws" {
  profile = "prod"
  region  = var.region_prod
  access_key = var.access_key_prod
  secret_key = var.secret_key_prod
  alias   = "prod"
}


# prod account

resource "aws_iam_role" "prod_list_s3" {
  name = "s3listrole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = "sts:AssumeRole",
        Principal = { "AWS" : "arn:aws:iam::${data.aws_caller_identity.dev.account_id}:root" }
    }]
  })
  provider = aws.prod
}

resource "aws_iam_policy" "s3_list_all" {
  name        = "s3listall"
  description = "allows listing all s3 buckets"
  provider = aws.prod

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "arn:aws:s3:::*"
        },
	{
	    "Sid": "Stmt1643942365665",
            "Action": "s3:*",
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::venkat18jan2022"
        },
        {
            "Sid": "Stmt1643942388353",
            "Action": "s3:*",
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::venkat18jan2022/*"
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "s3_list_all" {
  name       = "listbucketspolicytorole"
  roles      = ["${aws_iam_role.prod_list_s3.name}"]
  policy_arn = aws_iam_policy.s3_list_all.arn
  provider   = aws.prod
}

# dev account
resource "aws_iam_user" "random" {
  name = "random_user"

  tags = {
    name = "random"
  }
}

resource "aws_iam_policy" "prod_s3" {
  name        = "prods3"
  description = "allow assuming prod_s3 role"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sts:AssumeRole",
        Resource = "arn:aws:iam::${data.aws_caller_identity.prod.account_id}:role/${aws_iam_role.prod_list_s3.name}"
    }]
  })
}

resource "aws_iam_user_policy_attachment" "prod_s3" {
  user       = aws_iam_user.random.name
  policy_arn = aws_iam_policy.prod_s3.arn
} 
