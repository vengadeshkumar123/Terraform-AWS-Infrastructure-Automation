output "ec2_public_ip" {
  description = "Public IPv4 address of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "application_url" {
  description = "HTTP URL of the application"
  value       = "http://${aws_instance.web.public_ip}"
}
