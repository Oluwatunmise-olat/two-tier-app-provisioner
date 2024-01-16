variable "aws_region" {
  type = string
}

variable "two_tier_public_subnet_1_id" {
  type = string
}

variable "two_tier_public_subnet_2_id" {
  type = string
}
variable "web_sg_id" {
  type = string
}
variable "db_sg_id" {
  type = string
}

variable "db_password" {
  nullable = false
  sensitive = true
  type = string
}
variable "db_username" {
  nullable = false
  sensitive = true
  type = string
}
