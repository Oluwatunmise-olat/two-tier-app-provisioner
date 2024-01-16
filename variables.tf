variable "aws_region" {
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
