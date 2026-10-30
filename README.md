# Combined Docker + ECR + Terraform + GitHub Actions

## Project structure

```text
.
├── .github/workflows/deploy.yml
├── proj/                   # Existing Docker build context
├── versions.tf             # Terraform version, provider version, S3 backend
├── provider.tf             # AWS provider
├── variables.tf            # Input variables
├── data.tf                 # Latest Amazon Linux 2023 AMI lookup
├── security_group.tf       # HTTP Security Group
├── iam.tf                  # EC2 role, ECR pull policy, instance profile
├── ec2.tf                  # EC2 and Docker image deployment
├── outputs.tf              # Public IP and application URL
└── README.md
```

Terraform automatically loads all `.tf` files in the same directory. Do not add separate module wiring for these files.

## Pipeline
1. Push code to `main`.
2. GitHub Actions authenticates to AWS through OIDC.
3. It ensures ECR repository `practice` exists.
4. It builds the image from `./proj` and pushes it with the commit SHA as the tag.
5. Terraform creates/updates the Security Group, EC2 IAM role/profile, and EC2.
6. EC2 uses its instance profile to log in to ECR, pulls that exact image, and runs it on port 80.

## Before running
- The S3 bucket `venky-terraform-state-2026-unique` must already exist in `ap-south-1`. Backend key: `ecr-deployment/terraform.tfstate`.
- Configure GitHub secret `AWS_ROLE_ARN` to an AWS IAM role trusted by GitHub OIDC for this repository and `main` branch.
- That GitHub Actions role needs ECR repository create/push permissions, Terraform permissions for EC2/security group/IAM resources (including `iam:PassRole` for the EC2 role), and S3 state/lockfile permissions.
- The workflow currently targets AWS account `354780327224` indirectly through the configured OIDC role. Confirm that this is the account you intend to use.
- No SSH key is used; EC2 user data performs initial deployment.

## Notes
- EC2 role uses `AmazonEC2ContainerRegistryReadOnly`; no AWS keys are stored on EC2.
- Security Group permits HTTP port 80. The Docker image must listen on port 80 (the supplied Nginx image does).
- This simple design replaces EC2 when the image URI changes; that can cause downtime and extra charges. Later, update a running instance with SSM or use ECS for safer rolling deployment.
