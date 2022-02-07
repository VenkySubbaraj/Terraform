##@provider_part##
provider "aws" {
region = "ap-south-1"
}

resource "aws_default_vpc" "default" {}

resource "aws_security_group" "allow" {
 name = var.security_group_name
 description = "Allow TLS in transcript"
 vpc_id = aws_default_vpc.default.id

## @Outbnound Rules ##
 egress {
 from_port = var.outbound_rule_fromport[0]
 to_port = var.outbound_rule_toport[0]
 cidr_blocks = ["${aws_default_vpc.default.cidr_block}"]
 protocol = "-1"
}

 tags = {
 Name = "Master_Instance_SG"
 }
 }

resource "aws_security_group_rule" "Master_Instance_sg-rule" {
 count = 5 
 type = "ingress"
 from_port = var.inbound_fromport[count.index]
 to_port = var.inbound_toport[count.index]
 protocol = var.protocol[count.index]
 cidr_blocks = [aws_default_vpc.default.cidr_block]
 security_group_id = aws_security_group.allow.id
}


data "http" "public_ip" {
 url = "https://ifconfig.co/json"
 request_headers = {
 Accept = "application.json"
}
}

locals {
 ifconfig_co_json = jsondecode(data.http.public_ip.body)
}

output "public_ip" {
 value = local.ifconfig_co_json.ip
}

## creating the Slave Instance Security Group ##


resource "aws_security_group" "Allow" {
 name = "Slave-Instance"
 description = "Allow TLS in transcript"
 vpc_id = aws_default_vpc.default.id
 tags = {
   Name = "Slave-Instance"
 }
}

resource "aws_security_group_rule" "Slave_Instance_sg_rule" {
 count = 3
 type = "ingress"
 from_port = var.inbound_fromport[count.index]
 to_port = var.inbound_toport[count.index]
 protocol = var.protocol[count.index]
 security_group_id = "${aws_security_group.Allow.id}"
 cidr_blocks = ["${aws_default_vpc.default.cidr_block}"]
}

