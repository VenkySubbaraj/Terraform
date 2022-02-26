###Attaching the policy for specific role###

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 role        = aws_iam_role.lambda_role.name
 policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}

resource "aws_iam_role_policy_attachment" "EMR" {
 role = aws_iam_role.lambda_role.name
 policy_arn = aws_iam_policy.EMR.arn
}

resource "aws_iam_role_policy_attachment" "s3" {
 role = aws_iam_role.lambda_role.name
 policy_arn = aws_iam_policy.S3.arn
}

resource "aws_iam_role_policy_attachment" "policy_role" {
 role = aws_iam_role.lambda_role.name
 policy_arn = aws_iam_policy.EC2_policy.arn
}

resource "aws_iam_role_policy_attachment" "FullAccesspolicy_EMR" {
 role = aws_iam_role.lambda_role.name
 policy_arn = aws_iam_policy.EMRFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "ServiceAccessPolicy_EMR" {
 role = aws_iam_role.lambda_role.name
 policy_arn = aws_iam_policy.ServiceEMR.arn
}

resource "aws_iam_role_policy_attachment" "ssm_policy_role" {
 role = aws_iam_role.lambda_role.name
 policy_arn = aws_iam_policy.policy_for_SSM.arn
}

resource "aws_iam_role_policy_attachment" "AmazonElasticMapEC2" {
 role = aws_iam_role.lambda_role.name
 policy_arn = aws_iam_policy.AmazonElasticMapEC2.arn
}

resource "aws_iam_role_policy_attachment" "AmazonElasticMap" {
 role = aws_iam_role.lambda_role.name
 policy_arn = aws_iam_policy.AmazonElasticMap.arn
}
