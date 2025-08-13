resource "aws_security_group" "sg" {
  name        = "template-sg"
  description = "allow-public-traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.port
    to_port     = var.expose_port
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

output "security_group_id" {
  value = aws_security_group.sg.id
}
