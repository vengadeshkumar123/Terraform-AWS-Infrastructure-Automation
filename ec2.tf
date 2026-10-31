
resource "aws_ecr_repository" "web" {
  name                 = "practice"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0c7632fb77f35db43"
  instance_type = "t2.micro"

  key_name = "practice"

  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data_replace_on_change = true

  user_data = <<-EOF
    #!/bin/bash
    set -eux

    apt-get update -y
    apt-get install -y docker.io awscli

    systemctl enable docker
    systemctl start docker

    AWS_REGION="ap-south-1"
    IMAGE="354780327224.dkr.ecr.ap-south-1.amazonaws.com/practice:latest"

    aws ecr get-login-password --region "$AWS_REGION" \
      | docker login --username AWS --password-stdin \
      354780327224.dkr.ecr.ap-south-1.amazonaws.com

    docker pull "$IMAGE"

    docker rm -f myapp-container || true

    docker run -d \
      --name myapp-container \
      --restart unless-stopped \
      -p 80:80 \
      "$IMAGE"
  EOF

  depends_on = [
    aws_iam_role_policy_attachment.ecr_read
  ]

  tags = {
    Name = "terraform-ecr-web-server"
  }
}
