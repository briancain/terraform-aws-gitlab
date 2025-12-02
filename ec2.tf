# Get latest GitLab CE AMI
data "aws_ami" "gitlab" {
  most_recent = true
  owners      = ["782774275127"] # GitLab official AWS account

  filter {
    name   = "name"
    values = ["GitLab CE *"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Key Pair (optional - only created if ssh_public_key_path is provided)
resource "aws_key_pair" "gitlab" {
  count      = var.ssh_public_key_path != "" ? 1 : 0
  key_name   = "${var.project_name}-key"
  public_key = file(var.ssh_public_key_path)
}

# GitLab EC2 Instance
resource "aws_instance" "gitlab" {
  ami           = data.aws_ami.gitlab.id
  instance_type = var.instance_type
  key_name      = var.ssh_public_key_path != "" ? aws_key_pair.gitlab[0].key_name : null

  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.gitlab.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.gitlab.name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-instance"
  }
}
