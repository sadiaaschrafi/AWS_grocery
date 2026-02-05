# 1. AWS Provider
provider "aws" {
  region = "us-east-1"
}

# 2. Security Group for EC2 (Allow SSH and Web)
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Allow SSH and outbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Recommendation: Replace with your IP for better security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Security Group for RDS (Allow only EC2 to connect)
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow MySQL traffic from EC2"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id] # Only allows traffic from the EC2 above
  }
}

# 4. EC2 Instance
resource "aws_instance" "web_server" {
  ami                    = "ami-0440d3b780d96b29d" # Amazon Linux 2023 (check for your region)
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "Terraform-EC2"
  }
}

# 5. RDS Instance (MySQL)
resource "aws_db_instance" "database" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "mydb"
  username               = "admin"
  password               = "password123" # Use variables for real passwords!
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}
