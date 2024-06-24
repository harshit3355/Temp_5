terraform {
  backend "s3" {
    bucket = "851725297111"
    region = "ap-south-1"
    key = "terraform.tfstate"
    }
}
