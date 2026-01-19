# VPC - Virtual Private Cloud
# Cria uma rede isolada na AWS onde seus recursos irão residir
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
  }
}

# Subnets Públicas - Sub-redes que terão acesso à internet
# Distribuídas em 3 AZs diferentes para alta disponibilidade
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_a_cidr
  availability_zone       = var.public_subnet_a_az
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_a_name
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_b_cidr
  availability_zone       = var.public_subnet_b_az
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_b_name
  }
}

resource "aws_subnet" "public_c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_c_cidr
  availability_zone       = var.public_subnet_c_az
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_c_name
  }
}

# Internet Gateway - Porta de saída para a internet
# Permite que recursos na VPC acessem a internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.igw_name
  }
}

# Route Table - Tabela de roteamento
# Define como o tráfego é direcionado dentro da VPC
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Rota padrão - todo tráfego 0.0.0.0/0 vai para o Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = var.route_table_name
  }
}

# Route Table Associations - Associa subnets à tabela de roteamento
# Conecta as subnets públicas à rota que leva à internet
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id
}
