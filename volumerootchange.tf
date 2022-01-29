resource "aws_instance" "volumerootchange" {
	root_block_device {
		volume_id = "${aws_instance.venkatinstance.id}"	
		volume_size = 30
		volume_type = "gp2"
	}
}

