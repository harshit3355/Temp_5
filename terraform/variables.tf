variable "aws_region" {
  description = "The Name of the regin"
  type        = string
}

variable "instance_type" {
  description = "The type of instance"
  type        = string
}

variable "route53_zone_id" {
  description = "The ID of the Route 53 hosted zone"
  type        = string
}

variable "subdomain" {
  description = "The subdomain to create"
  type        = string
}

variable "s3" {
  description = "S3 Bucket Name"
  type        = string
}
