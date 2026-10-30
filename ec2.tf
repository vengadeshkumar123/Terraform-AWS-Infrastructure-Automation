resource "aws_instance" "web" {
  ami                    = "ami-0c7632fb77f35db43"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
}

output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}