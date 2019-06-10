provider "aws" {
  profile = "${var.profile}"
  region = "${var.region}"
}
# data "aws_ami" "amazon-linux-2" {
#  most_recent = true
#  owners = ["amazon"]

#  filter {
#    name   = "name"
#    values = ["amzn2-ami-hvm*"]
#  }
# }
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners = ["amazon"]
  
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}
resource "aws_instance" "server" {
  ami           = "${data.aws_ami.amazon-linux-2.id}"
  instance_type = "${var.instance_type}"

  key_name = "${var.key}"

  vpc_security_group_ids = ["${var.security_groups}"]
  subnet_id = "${var.subnet_id}"

  # iam_instance_profile = "${var.role}"

  lifecycle {
    # prevent rebuild if a newer ami is released
    ignore_changes = [ "ami" ]
  }

  root_block_device {
    volume_size = "${var.OSDiskSize}"
    volume_type = "gp2"
    delete_on_termination = true
  }
  tags = {
    Name = "${var.name}"
  }
}

