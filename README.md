# packer-terraform-aws
Packer build custom ami with tomcat installed. while using in jenkins, copy war file to tomcat for creating ami with application installed.
Then create aws 2 tier infrastructure using Terraform.
Detailed infra:
VPC with 3 public and 3 private subnets
autoscalling group of ec2 instances in private subnets built using most recent custom packer built ami
ALB in public subnet
SGs IAM Roles etc.
Access application using ALB public dns on port 80.


