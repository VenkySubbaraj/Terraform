resource "aws_s3_bucket" "dockercontainer" { 
	bucket="dockercontainer1"
	acl="public-read"
	
	tags = {
		Name = "DockerContainer2"
	}
}
