
resource "aws_instance" "web-ec2-instance-1" {
  ami                         = "ami-079db87dc4c10ac91"
  instance_type               = "t2.micro"
  key_name                    = "artisan"
  associate_public_ip_address = true
  security_groups             = [var.web_sg_id]
  subnet_id                   = var.two_tier_public_subnet_1_id
  tags = {
    Name = "web-01"
  }
}

resource "aws_instance" "web-ec2-instance-2" {
  ami                         = "ami-079db87dc4c10ac91"
  instance_type               = "t2.micro"
  key_name                    = "artisan"
  associate_public_ip_address = true
  security_groups             = [var.web_sg_id]
  subnet_id                   = var.two_tier_public_subnet_2_id
  tags = {
    Name = "web-02"
  }
}
resource "aws_db_instance" "db01" {
  allocated_storage           = 5
  storage_type                = "gp2"
  engine                      = "mysql"
  engine_version              = "5.7"
  instance_class              = "db.t2.micro"
  db_subnet_group_name        = "two-tier-db-subnet-group"
  vpc_security_group_ids      = [var.db_sg_id]
  parameter_group_name        = "default.mysql5.7"
  db_name                     = "db01"
  username                    = var.db_username
  password                    = var.db_password
  allow_major_version_upgrade = true
  auto_minor_version_upgrade  = true
  backup_retention_period     = 35
  backup_window               = "22:00-23:00"
  maintenance_window          = "Sat:00:00-Sat:03:00"
  multi_az                    = false
  skip_final_snapshot         = true
}
