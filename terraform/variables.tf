variable "aws_region" {
  description = "The Name of the regin"
  type = string
  default = "ap-south-1"
}

variable "instance_type" {
  description = "The type of instance"
  type = string
  default = "t2.small"
}


variable "s3" {
  description = "S3 Bucket Name"
  type = string
  default = "851725297111"
}
