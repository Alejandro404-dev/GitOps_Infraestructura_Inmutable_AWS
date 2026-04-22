resource "aws_security_group" "web_sg" {
  name        = "${var.app_name}-web-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami                  = local.ami_id_effective
  instance_type        = "t3.micro"
  key_name             = "vockey"
  iam_instance_profile = "LabInstanceProfile" # <-- ¡EL PASE VIP DE AWS ACADEMY!

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "${var.app_name}-standalone-server"
  }
}

output "public_ip" {
  value = aws_instance.app_server.public_ip
}