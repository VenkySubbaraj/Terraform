provider "aws" {
    region = "us-west-1"  
}
resource "aws_security_group" "instancesecurity" {
    name = "venkatachalapathy"  
    vpc_id = "${aws_vpc.venkatvpc.id}"
}
resource "aws_vpc" "venkatvpc" {
    cidr_block = "192.168.0.0/16"
    tags = {
      "Name" = "Terraform-VPC"
    }
}
  
resource "aws_internet_gateway" "venkatinternetgw" {
    vpc_id = aws_vpc.venkatvpc.id
    tags = {
      "Name" = "Terraform-IGW"
    }
}

resource "aws_route" "venkatassociate" {
    route_table_id = aws_vpc.venkatvpc.main_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.venkatinternetgw.id
}

resource "aws_security_group_rule" "venkat-security-group" {
    to_port = 22
    from_port = 22
    cidr_blocks =  ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.instancesecurity.id}"
    protocol = "tcp"
    type = "ingress"    
}

resource "aws_subnet" "venkatsubnet" {
    cidr_block = "192.168.1.0/24"
    vpc_id = "${aws_vpc.venkatvpc.id}"
    availability_zone = "us-west-1a"
}

resource "aws_instance" "terraform-instance" {
    ami = "ami-0d5075a2643fdf738"
    instance_type = "t2.micro"
    key_name = "DockerContainer"
    subnet_id = "${aws_subnet.venkatsubnet.id}"
    associate_public_ip_address = "true"
    vpc_security_group_ids = [aws_security_group.instancesecurity.id]
    tags = {
      "Name" = "Terrainstance"
    }
}
