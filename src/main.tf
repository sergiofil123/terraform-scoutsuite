module "ec2_vm" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name          = "ScoutSuite VM"
  ami           = data.aws_ami.amazon_ubuntu_22.id
  instance_type = var.ec2_instance_type

  create_eip             = true
  subnet_id              = data.aws_subnets.subnets.ids[0]
  vpc_security_group_ids = [module.security_group.security_group_id]


  // IMDSv2
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 8
    instance_metadata_tags      = "enabled"
  }

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y apache2
              # Install ScoutSuite
              mkdir /home/ubuntu/scoutsuite
              cd /home/ubuntu/scoutsuite
              chown ubuntu:ubuntu -R /home/ubuntu/scoutsuite
              sudo apt install python3-venv -y
              python3 -m venv scout-venv
              source /home/ubuntu/scoutsuite/scout-venv/bin/activate
              pip install scoutsuite
              # Run Report
              scout aws -f --report-dir /home/ubuntu/scoutsuite/www --report-name index
              cp -r /home/ubuntu/scoutsuite/www/* /var/www/html/
              sudo systemctl restart apache2
              EOF

  tags = local.ss_tags
}

# Create an Instance Profile for the EC2 Role
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-security-audit-profile"
  role = aws_iam_role.ec2_role.name
}

# Attach AWS SecurityAudit Policy to the IAM Role
resource "aws_iam_role_policy_attachment" "security_audit_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

# Attach AWS ReadOnly Policy to the IAM Role
resource "aws_iam_role_policy_attachment" "security_read_only_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Create IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "ec2-security-audit-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = local.ss_tags
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.5.0"

  name        = "SG for ScoutSuite"
  description = "Allow connections on port 80 to access ScoutSuite report"
  vpc_id      = data.aws_vpc.default_vpc.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]
  egress_rules        = ["all-all"]

  tags = local.ss_tags
}
