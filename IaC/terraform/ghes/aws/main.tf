
provider "aws" {
  version                 = "~> 2.43"
  region                  = var.region
}

# ##############################################################################
# AWS User-Date template
# ##############################################################################
data "aws_ami" "ghes" {
  owners = ["895557238572"]

  filter {
    name   = "name"
    values = ["GitHub Enterprise Server ${var.ghes_version}"]
  }
}

# ##############################################################################
# AWS User-Date template
# ##############################################################################
data "template_file" "ghes_user_data" {
  template = "${file("${path.module}/ghes-user-data.tpl")}"
  vars = {
    region            = var.region
  }
}

# ##############################################################################
# AWS Security Group
# ##############################################################################
resource "aws_security_group" "ghes" {
  name   = "${var.stack_name}-ghes-test-sg"
  vpc_id = var.vpc_id  

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 122
    to_port     = 122
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.stack_name}-ghes-test-sg"
  }
}

# ##############################################################################
# AWS SSM Setup | Profile -> Role -> Policy (has Permissions)
# ##############################################################################
resource "aws_iam_instance_profile" "ghes" {
  name = "${var.stack_name}-ghes-profile"
  role = aws_iam_role.ghes.name
}

resource "aws_iam_role" "ghes" {
  name = "${var.stack_name}-ghes-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# ##############################################################################
# Attach a Policy to Role (SSM)
# ##############################################################################
resource "aws_iam_policy_attachment" "AmazonEC2RoleforSSM" {
  name       = "AmazonEC2RoleforSSM"
  roles      = ["${aws_iam_role.ghes.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_policy_attachment" "AmazonSSMManagedInstanceCore" {
  name       = "AmazonSSMManagedInstanceCore"
  roles      = ["${aws_iam_role.ghes.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "AmazonSSMDirectoryServiceAccess" {
  name       = "AmazonSSMDirectoryServiceAccess"
  roles      = ["${aws_iam_role.ghes.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess"
}

resource "aws_iam_policy_attachment" "AmazonSSMFullAccess" {
  name       = "AmazonSSMFullAccess"
  roles      = ["${aws_iam_role.ghes.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonSSMAutomationRole" {
  name       = "AmazonSSMAutomationRole"
  roles      = ["${aws_iam_role.ghes.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole"
}

resource "aws_iam_policy_attachment" "AmazonSSMReadOnlyAccess" {
  name       = "AmazonSSMReadOnlyAccess"
  roles      = ["${aws_iam_role.ghes.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonSSMMaintenanceWindowRole" {
  name       = "AmazonSSMMaintenanceWindowRole"
  roles      = ["${aws_iam_role.ghes.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole"
}

# ##############################################################################
# AWS EC2 instance
# ##############################################################################
resource "aws_instance" "ghes" {
  ami           = data.aws_ami.ghes.id
  instance_type = var.instance_type
  key_name      = "automation-demo-key"
  user_data = data.template_file.ghes_user_data.rendered
  security_groups = [aws_security_group.ghes.name]

  ebs_block_device {
    device_name           = "/dev/sdb"
    delete_on_termination = false
    volume_size           = 1024
    volume_type           = "gp2"
  }

  tags = {
    Name = "${var.stack_name}-ghes-v${var.ghes_version}"
  }
}

# ##############################################################################
# Terraform AWS resource output
# ##############################################################################
output "instance" {
  value = aws_instance.ghes.public_dns
}
