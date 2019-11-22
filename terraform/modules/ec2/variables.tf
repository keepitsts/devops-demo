variable "profile" {
  description = "aws cli profile/keys to use"
}
variable "region" {
  default = "us-east-1"
}
variable "instance_type" {
  default = "t3.micro"
}
variable "key" {
  
}

variable "security_groups" {
  
}
variable "subnet_id" {
  
}
variable "role" {
  default = "s3_access_for_ec2"
}

variable "OSDiskSize" {
  default = "8"
}
variable "name" {
  
}
