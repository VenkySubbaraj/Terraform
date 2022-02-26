resource "tls_private_key" "mykey" {
   algorithm = "RSA"
   rsa_bits = "4096"
}

resource "aws_key_pair" "keypair" {
  key_name = "mykey"
  public_key = tls_private_key.mykey.public_key_openssh
  provisioner "local-exec" {
   command = "echo '${tls_private_key.mykey.private_key_pem}' > ./mykey.pem"
  }
}
  
