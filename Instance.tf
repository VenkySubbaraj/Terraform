resource "aws_instance" "testinstance" {
  count = 1
  ami = "ami-0d5075a2643fdf738"
  instance_type = "t2.micro"
  subnet_id = "subnet-87f159dd"
  associate_public_ip_address = "true"
  vpc_security_group_ids = [ aws_security_group.venkat-sg.id ]
  key_name = "DockerContainer"
  tags = { 
    Name = "terraform_instance"
  }
}