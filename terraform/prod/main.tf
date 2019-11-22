terraform {
  backend "s3" {
    bucket  = "sts-terraform-remote-state"
    key     = "jenkins_build/prod"
    region  = "us-east-1"
    profile = "sts"
  }
}
module "security_group" {
  source = "../modules/security_group"
  
  profile = "sts"

  sg_name = "dev_security_group"
  sg_description = "Allows access to demo resources"

  vpc_id = "vpc-0e3945d5888632944"


}
module "ec2_server" {
    source = "../modules/ec2"

    profile = "sts"
    instance_type = "t2.micro"

    security_groups = "${module.security_group.id}"
    subnet_id = "subnet-02ccc03ce0ce2a594"

    name = "dev_server"

    key = "demo_pipeline"
}