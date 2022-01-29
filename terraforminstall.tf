provider "aws" { 
	region = "us-west-1"
}

resource "aws_volume_attachment" "venkatinstancevolume"  {
	device_name = "/dev/xvda"
	volume_id = "$(aws_ebs_volume.venkatinstance.id)"
	instance_id = "$(aws_instance.venkatinstance.id)"
}

resource "aws_instance" "venkatinstance" {
	ami = "ami-03ab7423a204da002"
	instance_type = "t2.micro"
	key_name = "DockerContainer"
	vpc_security_group_ids = ["sg-0126be558371393a3"]
	subnet_id = "subnet-87f159dd"
	tags = {
		Name = "terraformInstance"
	}
	root_block_device { 
		volume_size = "20"
		volume_type = "gp2"
		delete_on_termination = "true"
	}
	ebs_block_device {
		device_name = "/dev/xvdf"
		volume_size = "30"
		volume_type = "gp2"
		delete_on_termination = "true"
	}

	associate_public_ip_address = "true"
	provisioner "local-exec" {
		command = "sudo bash venkatshell.sh"
	}
}

