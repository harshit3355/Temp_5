variable "aws_region" {
  description = "The Name of the regin"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "The type of instance"
  type        = string
  default     = "t2.small"
}

variable "route53_zone_id" {
  description = "The ID of the Route 53 hosted zone"
  type        = string
  default     = "Z0168181Y1IW2PDPC8NC"
}

variable "subdomain" {
  description = "The subdomain to create"
  type        = string
  default     = "admin.technobizz.biz" # Replace with your actual subdomain
}

variable "s3" {
  description = "S3 Bucket Name"
  type        = string
  default     = "851725297111"
}
