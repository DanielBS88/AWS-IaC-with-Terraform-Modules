# SSH Security Group
# Permite acesso SSH apenas de IPs confiáveis
resource "aws_security_group" "ssh" {
  name        = var.ssh_sg_name
  description = "Security group for SSH access"
  vpc_id      = var.vpc_id

  tags = {
    Name = var.ssh_sg_name
  }
}

# Regra de ingress para SSH
resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ip_range
  security_group_id = aws_security_group.ssh.id
  description       = "Allow SSH from allowed IP ranges"
}

# Regra de egress para SSH - permite todo tráfego de saída
resource "aws_security_group_rule" "ssh_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ssh.id
  description       = "Allow all outbound traffic"
}

# Public HTTP Security Group
# Para o Load Balancer - aceita HTTP de IPs confiáveis
resource "aws_security_group" "public_http" {
  name        = var.public_http_sg_name
  description = "Security group for public HTTP access"
  vpc_id      = var.vpc_id

  tags = {
    Name = var.public_http_sg_name
  }
}

resource "aws_security_group_rule" "public_http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ip_range
  security_group_id = aws_security_group.public_http.id
  description       = "Allow HTTP from allowed IP ranges"
}

resource "aws_security_group_rule" "public_http_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_http.id
  description       = "Allow all outbound traffic"
}

# Private HTTP Security Group
# Para as instâncias EC2 - aceita HTTP apenas do Load Balancer
resource "aws_security_group" "private_http" {
  name        = var.private_http_sg_name
  description = "Security group for private HTTP access from load balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name = var.private_http_sg_name
  }
}

# Note: usando source_security_group_id ao invés de cidr_blocks
# Isso permite tráfego apenas do security group do LB
resource "aws_security_group_rule" "private_http_ingress" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.public_http.id
  security_group_id        = aws_security_group.private_http.id
  description              = "Allow HTTP from public HTTP security group"
}

resource "aws_security_group_rule" "private_http_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.private_http.id
  description       = "Allow all outbound traffic"
}
