data "aws_ebs_volume" "ebs_volume" {
	most_recent = true

	filter {
		name = "attachment.instance-id"
		values = ["${aws_instance.venkatinstance.id}"]
	}
}
output "ebs_volume_id" {
 	value = "${data.aws_ebs_volume.ebs_volume.id}"
}


