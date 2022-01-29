provider "aws" {
	region = "us-west-1"
}
resource "aws_lb_target_group" "venkatTG" {
 health_check {
	interval = 10
	path = "/"
	protocol = "HTTP"
	timeout = 5
	healthy_threshold = 2
 }

	name = "my-test-tg"
	port = 80
	protocol = "HTTP"
	target_type = "instance"
  vpc_id = "${aws_security_group.Venkat-sg.vpc_id}"
}

resource "aws_lb_target_group_attachment" "TG1" {
  target_group_arn = "${aws_lb_target_group.venkatTG.arn}"
  target_id        = "${aws_instance.testinstance[0].id}"
  port             = 80
}

resource "aws_subnet" "privatesubnet" {
    vpc_id = "${aws_security_group.Venkat-sg.vpc_id}"  
    cidr_block = "172.31.32.0/20"
    tags = {
      "Name" = "Private"
    }
}

resource "aws_lb" "a" {
  name     = "venkat"
  internal = false

security_groups = [
    "${aws_security_group.Venkat-sg.id}",
  ]

subnets = ["${aws_instance.testinstance[0].subnet_id}", "${aws_subnet.privatesubnet.id}"]
}

resource "aws_lb_listener" "my-test-alb-listner" {
  load_balancer_arn = "${aws_lb.a.arn}"
  port              = 80
  protocol          = "HTTP"

default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.venkatTG.arn}"
  }
}

resource "aws_security_group" "Venkat-sg" {
  name   = "Venkat-sg"
}
resource "aws_security_group_rule" "inbound_ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.Venkat-sg.id}"
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "inbound_http" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.Venkat-sg.id}"
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_all" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.Venkat-sg.id}"
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
