##@provider_part##
provider "aws" {
region = "ap-south-1"
}
resource "aws_default_vpc" "default" {}

resource "aws_security_group" "allow" {
 name = "Master_Instance"
 description = "Allow TLS in transcript"
 vpc_id = aws_default_vpc.default.id

## @Inbound Rules ##
ingress {
from_port = 0
to_port = 65535
protocol = "tcp"
cidr_blocks= ["${aws_default_vpc.default.cidr_block}"]
}

## @ALL_ICMP_IPV4 Protocol ##
ingress {
from_port = 8
to_port = 0
protocol = "icmp"
cidr_blocks = ["${aws_default_vpc.default.cidr_block}"]
}

## @UDP_Security_group##
ingress {
from_port = 0
to_port = 65535
protocol = "udp"
cidr_blocks = ["${aws_default_vpc.default.cidr_block}"]
}

## @Custom_TCP_part##
ingress {
from_port = 8443
to_port = 8443
protocol = "tcp"
cidr_blocks = ["${aws_default_vpc.default.cidr_block}"]
}
## @SSH_MY_IP_PART ##
ingress {
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["${local.ifconfig_co_json.ip}/32"]
}

## @Outbnound Rules ##
egress {
from_port = 0
to_port = 0
cidr_blocks = ["${aws_default_vpc.default.cidr_block}"]
protocol = "-1"
}

tags = {
Name = "Master_Instance_SG"
}
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

##Allocating security group rules of Master_Instance to Slave instance ##


resource "aws_security_group" "Allow" {
 name = "Slave-Instance"
 description = "Allow TLS in transcript"
 vpc_id = aws_default_vpc.default.id

ingress {
from_port = 8
to_port = 0
protocol = "icmp"
cidr_blocks = ["${aws_default_vpc.default.cidr_block}"]
}

## @UDP_Security_group##
ingress {
from_port = 0
to_port = 65535
protocol = "udp"
cidr_blocks = ["${aws_default_vpc.default.cidr_block}"]
}

## @Custom_TCP_part##
ingress {
from_port = 8443
to_port = 8443
protocol = "tcp"
cidr_blocks = ["${aws_default_vpc.default.cidr_block}"]
}
tags = {
  Name = "Slave-Instance"
}
}

## creating the Slave Instance Security Group  ##

#resource "aws_security_group_rule" "Slave_inbound_ICMP"{
#type = "ingress"
#from_port = 8
#to_port = 0
#protocol = "icmp"
#security_group_id = "${aws_security_group.allow.id}"
#cidr_blocks = ["${aws_default_vpc.default.cidr_block}"]
#}

## @UDP_Security_group##
#resource "aws_security_group_rule" "Slave_inbound_udp"{
#type = "ingress"
#from_port = 0
#to_port = 65535
#protocol = "udp"
#security_group_id = "${aws_security_group.allow.id}"
#cidr_blocks = ["${aws_default_vpc.default.cidr_block}"]
#}


## @Custom_TCP_part##
#resource "aws_security_group_rule" "Slave_inbound_tcp"{
#type = "ingress"
#from_port = 8443
#to_port = 8443
#protocol = "tcp"
#security_group_id = "${aws_security_group.allow.id}"
#cidr_blocks = ["${aws_default_vpc.default.cidr_block}"]
#}
