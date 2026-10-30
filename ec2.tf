resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  user_data_replace_on_change = true

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    AWS_REGION="${var.aws_region}"
    IMAGE="${var.image_uri}"
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
