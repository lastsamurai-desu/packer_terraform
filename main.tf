provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "packer-ec2" {
  ami           = data.aws_ami.terra.id
  instance_type = "t2.micro"
  tags = {
    Name = "Terra_Packer"
  }
}

data "aws_ami" "terra" {
  most_recent = true
  filter {
    name   = "name"
    values = ["packer-terraform-ami"]
  }
}  