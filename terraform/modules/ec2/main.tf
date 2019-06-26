provider "aws" {
  profile = "${var.profile}"
  region = "${var.region}"
  version = "2.14"
}

data "template_file" "init" {
  template = <<-EOF
  #!/bin/bash -xev

  # Do some chef pre-work
  /bin/mkdir -p /etc/chef
  /bin/mkdir -p /var/lib/chef
  /bin/mkdir -p /var/log/chef

  cd /etc/chef/

  # Copy the organization validator key
  aws s3 cp s3://sts-demo-bucket/simpletechnologysolutions-validator.pem /etc/chef/simpletechnologysolutions-validator.pem

  # Install chef
  curl -L https://omnitruck.chef.io/install.sh | bash || error_exit 'could not install chef'

  # Create client.rb
  /bin/echo 'log_location     STDOUT' >> /etc/chef/client.rb
  /bin/echo -e "chef_server_url  \"https://api.chef.io/organizations/simpletechnologysolutions\"" >> /etc/chef/client.rb
  /bin/echo -e "validation_client_name \"simpletechnologysolutions-validator\"" >> /etc/chef/client.rb
  /bin/echo -e "validation_key \"/etc/chef/simpletechnologysolutions-validator.pem\"" >> /etc/chef/client.rb
  /bin/echo -e "chef_license \"accept\"" >> /etc/chef/client.rb

  sudo chef-client
  EOF
}

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
  user_data = "${data.template_file.init.rendered}"
  ami           = "${data.aws_ami.amazon-linux-2.id}"
  instance_type = "${var.instance_type}"

  key_name = "${var.key}"

  vpc_security_group_ids = ["${var.security_groups}"]
  subnet_id = "${var.subnet_id}"

  associate_public_ip_address = true

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

