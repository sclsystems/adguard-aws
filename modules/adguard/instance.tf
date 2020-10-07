data "aws_iam_policy_document" "ec2_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "ssm_role" {
  name = "ssm_role"

  assume_role_policy = data.aws_iam_policy_document.ec2_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ssm_role_policy_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "adguard_instance_profile" {
  name_prefix = "adguard-instance-profile-"
  role        = aws_iam_role.ssm_role.name
}

resource "aws_security_group" "allow_instance_access" {
  name_prefix = "adguard-instance-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 53
    to_port   = 53
    protocol  = "tcp"
    cidr_blocks = [
      "${var.allowed_client}/32"
    ]
  }

  ingress {
    from_port = 53
    to_port   = 53
    protocol  = "udp"
    cidr_blocks = [
      "${var.allowed_client}/32"
    ]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    security_groups = [
      aws_security_group.allow_web_access_lb.id
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    ]
  }

  filter {
    name = "virtualization-type"
    values = [
      "hvm"
    ]
  }

  owners = [
    "099720109477"
  ]
}

data "template_cloudinit_config" "adguard_init" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/../../config/cloud-init.sh", {
      adguard_config = templatefile("${path.module}/../../config/config.yaml", {
        password_hash : var.admin_password_hash
        allowed_client : var.allowed_client
      })
    })
  }
}

resource "aws_eip" "instance_eip" {
  instance = aws_instance.adguard_instance.id
  vpc      = true
}

resource "aws_instance" "adguard_instance" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.adguard_instance_profile.name
  user_data            = data.template_cloudinit_config.adguard_init.rendered
  vpc_security_group_ids = [
    aws_security_group.allow_instance_access.id
  ]
}
