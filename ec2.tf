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

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    AWS_REGION="ap-south-1"
    IMAGE="${aws_ecr_repository.web.repository_url}:latest"
    ECR_REGISTRY="$(echo "$IMAGE" | cut -d/ -f1)"
    CONTAINER_NAME="myapp-container"

    dnf install -y docker awscli
    systemctl enable --now docker

    for i in $(seq 1 30); do
      if docker info >/dev/null 2>&1; then
        break
      fi
      sleep 2
    done

    aws ecr get-login-password --region "$AWS_REGION" \
      | docker login --username AWS --password-stdin "$ECR_REGISTRY"

    docker pull "$IMAGE"
    docker rm -f "$CONTAINER_NAME" || true

    docker run -d \
      --name "$CONTAINER_NAME" \
      --restart unless-stopped \
      -p 80:80 \
      "$IMAGE"

    docker ps
  EOF

  depends_on = [
    aws_iam_role_policy_attachment.ecr_read
  ]

  tags = {
    Name = "terraform-ecr-web-server"
  }
}
