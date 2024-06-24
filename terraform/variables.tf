variable "aws_region" {
  description = "The Name of the regin"
  default = "ap-south-1"
}

variable "instance_type" {
  description = "The type of instance"
  default = "t2.small"
}

variable "key_name" {
  description = "The name of the ssh key"
  default = "ex"
}

variable "ami_name" {
    description = "The name of the ami"
    default = "ami-05e00961530ae1b55"
}

