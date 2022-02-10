resource "aws_ssm_association" "instance" {
 name = var.aws_ssm_association_name

 targets {
    key = "InstanceIds"
    values = ["*"]
 }
}
