cd /home/dansanto/Courses/Terraform/AWS_IaC_with_Terraform_Modules1

cat > Lab_solution.md << 'EOF'
# AWS IaC with Terraform: Modules - Solução Completa

## Índice
1. [Visão Geral](#visão-geral)
2. [Pré-requisitos](#pré-requisitos)
3. [Estrutura do Projeto](#estrutura-do-projeto)
4. [Passo a Passo Detalhado](#passo-a-passo-detalhado)
5. [Arquivos Criados](#arquivos-criados)
6. [Validação e Troubleshooting](#validação-e-troubleshooting)
7. [Conceitos Aprendidos](#conceitos-aprendidos)

---

## Visão Geral

Este lab implementa uma arquitetura AWS completa usando Terraform com abordagem modular, criando:
- VPC com 3 subnets públicas em diferentes Availability Zones
- Security Groups com princípio de menor privilégio
- Application Load Balancer
- Auto Scaling Group com 2 instâncias EC2
- Alta disponibilidade e escalabilidade

**Recursos AWS criados**: ~24 recursos  
**Tempo estimado**: 2-3 horas  
**Nível**: Intermediário

---

## Pré-requisitos

### Software Necessário
- Terraform >= 1.5.7
- AWS CLI configurado
- Git
- Editor de texto (vim, nano, VS Code)

### Conhecimentos
- Básico de Linux/Bash
- Conceitos de redes (CIDR, subnets)
- Fundamentos de AWS (VPC, EC2, ELB)
- Git básico

### Obter seu IP Público
```bash
curl -s ifconfig.me
```
Anote este IP - você vai usá-lo nas configurações de segurança.

---

## Estrutura do Projeto
```
AWS_IaC_with_Terraform_Modules1/
├── modules/
│   ├── network/                    # Módulo de rede
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── network_security/          # Módulo de segurança
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── application/               # Módulo de aplicação
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── main.tf                        # Configuração root
├── variables.tf                   # Variáveis root
├── outputs.tf                     # Outputs root
├── versions.tf                    # Versões Terraform/Providers
├── provider.tf                    # Configuração AWS Provider
├── terraform.tfvars              # Valores das variáveis
├── .gitignore                    # Arquivos ignorados pelo Git
└── README.md                      # Documentação
```

---

## Passo a Passo Detalhado

### 1. Preparação do Ambiente
```bash
# Criar diretório do projeto
mkdir -p ~/Courses/Terraform/AWS_IaC_with_Terraform_Modules1
cd ~/Courses/Terraform/AWS_IaC_with_Terraform_Modules1

# Criar estrutura de módulos
mkdir -p modules/{network,network_security,application}

# Obter seu IP público
MY_IP=$(curl -s ifconfig.me)
echo "Seu IP: $MY_IP"
```

### 2. Criar .gitignore

**Por que é importante?**
- Evita commit de arquivos sensíveis (states com dados da infraestrutura)
- Reduz tamanho do repositório (cache, binários)
- Mantém repositório limpo (arquivos temporários)
```bash
cat > .gitignore << 'GITIGNORE'
# Terraform state files
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl

# Crash log files
crash.log
crash.*.log

# Override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Backup tfvars
*.tfvars.backup

# OS files
.DS_Store
Thumbs.db

# IDE
.idea/
.vscode/
*.swp
*.swo
*~

# Backup files
*.backup
*.bak
GITIGNORE
```

**⚠️ IMPORTANTE**: Note que `*.tfvars` NÃO está no .gitignore. Isso é necessário para o validador automático ter acesso aos valores das variáveis.

### 3. Criar Módulo Network

#### modules/network/variables.tf

**Conceito**: Variáveis tornam o módulo reutilizável e parametrizável.
```bash
cat > modules/network/variables.tf << 'EOF'
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_a_name" {
  description = "Name of public subnet A"
  type        = string
}

variable "public_subnet_a_cidr" {
  description = "CIDR block for public subnet A"
  type        = string
}

variable "public_subnet_a_az" {
  description = "Availability zone for public subnet A"
  type        = string
}

variable "public_subnet_b_name" {
  description = "Name of public subnet B"
  type        = string
}

variable "public_subnet_b_cidr" {
  description = "CIDR block for public subnet B"
  type        = string
}

variable "public_subnet_b_az" {
  description = "Availability zone for public subnet B"
  type        = string
}

variable "public_subnet_c_name" {
  description = "Name of public subnet C"
  type        = string
}

variable "public_subnet_c_cidr" {
  description = "CIDR block for public subnet C"
  type        = string
}

variable "public_subnet_c_az" {
  description = "Availability zone for public subnet C"
  type        = string
}

variable "igw_name" {
  description = "Name of the Internet Gateway"
  type        = string
}

variable "route_table_name" {
  description = "Name of the route table"
  type        = string
}

variable "allowed_ip_range" {
  description = "List of IP address ranges for secure access"
  type        = list(string)
}
EOF
```

#### modules/network/main.tf

**Conceito**: Define os recursos de infraestrutura de rede.
```bash
cat > modules/network/main.tf << 'EOF'
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
EOF
```

#### modules/network/outputs.tf

**Conceito**: Outputs exportam valores do módulo para serem usados por outros módulos.
```bash
cat > modules/network/outputs.tf << 'EOF'
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [aws_subnet.public_a.id, aws_subnet.public_b.id, aws_subnet.public_c.id]
}
EOF
```

### 4. Criar Módulo Network Security

#### modules/network_security/variables.tf
```bash
cat > modules/network_security/variables.tf << 'EOF'
variable "vpc_id" {
  description = "ID of the VPC where security groups will be created"
  type        = string
}

variable "ssh_sg_name" {
  description = "Name of the SSH security group"
  type        = string
}

variable "public_http_sg_name" {
  description = "Name of the public HTTP security group"
  type        = string
}

variable "private_http_sg_name" {
  description = "Name of the private HTTP security group"
  type        = string
}

variable "allowed_ip_range" {
  description = "List of IP address ranges for secure access"
  type        = list(string)
}
EOF
```

#### modules/network_security/main.tf

**Conceito**: Security Groups funcionam como firewalls virtuais.
```bash
cat > modules/network_security/main.tf << 'EOF'
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

resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ip_range
  security_group_id = aws_security_group.ssh.id
  description       = "Allow SSH from allowed IP ranges"
}

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

# IMPORTANTE: usando source_security_group_id ao invés de cidr_blocks
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
EOF
```

#### modules/network_security/outputs.tf
```bash
cat > modules/network_security/outputs.tf << 'EOF'
output "ssh_sg_id" {
  description = "ID of the SSH security group"
  value       = aws_security_group.ssh.id
}

output "public_http_sg_id" {
  description = "ID of the public HTTP security group"
  value       = aws_security_group.public_http.id
}

output "private_http_sg_id" {
  description = "ID of the private HTTP security group"
  value       = aws_security_group.private_http.id
}
EOF
```

### 5. Criar Módulo Application

#### modules/application/variables.tf
```bash
cat > modules/application/variables.tf << 'EOF'
variable "launch_template_name" {
  description = "Name of the launch template"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ssh_sg_id" {
  description = "ID of the SSH security group"
  type        = string
}

variable "private_http_sg_id" {
  description = "ID of the private HTTP security group"
  type        = string
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
}

variable "asg_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
}

variable "asg_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
}

variable "asg_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Auto Scaling Group"
  type        = list(string)
}

variable "lb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
}

variable "public_http_sg_id" {
  description = "ID of the public HTTP security group for load balancer"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}
EOF
```

#### modules/application/main.tf

**Conceito**: Este módulo cria a aplicação completa com Auto Scaling e Load Balancing.
```bash
cat > modules/application/main.tf << 'EOF'
# Data source para pegar a AMI mais recente do Amazon Linux 2023
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Launch Template
# Define como as instâncias EC2 serão criadas
resource "aws_launch_template" "main" {
  name          = var.launch_template_name
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  # IMPORTANTE: Security groups devem estar dentro de network_interfaces
  # quando você usa essa configuração
  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = [var.ssh_sg_id, var.private_http_sg_id]
  }

  # User data - script executado na inicialização da instância
  user_data = base64encode(<<-EOF
    #!/bin/bash
    exec > /var/log/user-data.log 2>&1
    set -x
    
    yum update -y
    yum install -y httpd
    
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    MACHINE_UUID=$(cat /sys/devices/virtual/dmi/id/product_uuid | tr '[:upper:]' '[:lower:]')
    
    cat > /var/www/html/index.html << 'HTML'
    <!DOCTYPE html>
    <html>
    <head><title>Instance Info</title></head>
    <body><h1>Instance Information</h1>
    HTML
    
    echo "<p>This message was generated on instance $INSTANCE_ID with the following UUID $MACHINE_UUID</p>" >> /var/www/html/index.html
    
    echo '</body></html>' >> /var/www/html/index.html
    
    systemctl start httpd
    systemctl enable httpd
    EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.launch_template_name
    }
  }
}

# Target Group
# Define onde o Load Balancer deve enviar o tráfego
resource "aws_lb_target_group" "main" {
  name     = "${var.asg_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  # Health check - verifica se as instâncias estão saudáveis
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name = "${var.asg_name}-tg"
  }
}

# Auto Scaling Group
# Gerencia automaticamente o número de instâncias EC2
resource "aws_autoscaling_group" "main" {
  name                      = var.asg_name
  desired_capacity          = var.asg_desired_capacity
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = [aws_lb_target_group.main.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  # Lifecycle - ignora mudanças em load_balancers e target_group_arns
  # Evita que o Terraform tente recriar o ASG desnecessariamente
  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }

  tag {
    key                 = "Name"
    value               = var.asg_name
    propagate_at_launch = true
  }
}

# Application Load Balancer
# Distribui tráfego entre as instâncias
resource "aws_lb" "main" {
  name               = var.lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.public_http_sg_id]
  subnets            = var.subnet_ids

  tags = {
    Name = var.lb_name
  }
}

# Listener
# Escuta requisições HTTP na porta 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Auto Scaling Attachment
# Conecta o ASG ao Load Balancer
resource "aws_autoscaling_attachment" "main" {
  autoscaling_group_name = aws_autoscaling_group.main.name
  lb_target_group_arn    = aws_lb_target_group.main.arn
}
EOF
```

#### modules/application/outputs.tf
```bash
cat > modules/application/outputs.tf << 'EOF'
output "lb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}
EOF
```

### 6. Criar Arquivos Root

#### versions.tf

**Conceito**: Define versões mínimas do Terraform e providers para garantir compatibilidade.
```bash
cat > versions.tf << 'EOF'
terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
EOF
```

#### provider.tf
```bash
cat > provider.tf << 'EOF'
provider "aws" {
  region = var.aws_region
}
EOF
```

#### variables.tf
```bash
cat > variables.tf << 'EOF'
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "project_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_a_cidr" {
  description = "CIDR block for public subnet A"
  type        = string
}

variable "public_subnet_b_cidr" {
  description = "CIDR block for public subnet B"
  type        = string
}

variable "public_subnet_c_cidr" {
  description = "CIDR block for public subnet C"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "asg_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
}

variable "asg_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
}

variable "asg_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
}

variable "allowed_ip_range" {
  description = "List of IP address ranges for secure access"
  type        = list(string)
}
EOF
```

#### main.tf

**Conceito**: Usa locals para gerar nomes de recursos dinamicamente, evitando hardcoding.
```bash
cat > main.tf << 'EOF'
# Locals - valores computados/concatenados usados em múltiplos lugares
locals {
  vpc_name              = "${var.project_prefix}-vpc"
  subnet_public_a_name  = "${var.project_prefix}-subnet-public-a"
  subnet_public_b_name  = "${var.project_prefix}-subnet-public-b"
  subnet_public_c_name  = "${var.project_prefix}-subnet-public-c"
  igw_name              = "${var.project_prefix}-igw"
  route_table_name      = "${var.project_prefix}-rt"
  ssh_sg_name           = "${var.project_prefix}-ssh-sg"
  public_http_sg_name   = "${var.project_prefix}-public-http-sg"
  private_http_sg_name  = "${var.project_prefix}-private-http-sg"
  launch_template_name  = "${var.project_prefix}-template"
  asg_name              = "${var.project_prefix}-asg"
  lb_name               = "${var.project_prefix}-lb"
}

# Módulo Network - Cria toda a infraestrutura de rede
module "network" {
  source = "./modules/network"

  vpc_name               = local.vpc_name
  vpc_cidr               = var.vpc_cidr
  public_subnet_a_name   = local.subnet_public_a_name
  public_subnet_a_cidr   = var.public_subnet_a_cidr
  public_subnet_a_az     = "${var.aws_region}a"
  public_subnet_b_name   = local.subnet_public_b_name
  public_subnet_b_cidr   = var.public_subnet_b_cidr
  public_subnet_b_az     = "${var.aws_region}b"
  public_subnet_c_name   = local.subnet_public_c_name
  public_subnet_c_cidr   = var.public_subnet_c_cidr
  public_subnet_c_az     = "${var.aws_region}c"
  igw_name               = local.igw_name
  route_table_name       = local.route_table_name
  allowed_ip_range       = var.allowed_ip_range
}

# Módulo Network Security - Cria os security groups
module "network_security" {
  source = "./modules/network_security"

  vpc_id                = module.network.vpc_id
  ssh_sg_name           = local.ssh_sg_name
  public_http_sg_name   = local.public_http_sg_name
  private_http_sg_name  = local.private_http_sg_name
  allowed_ip_range      = var.allowed_ip_range
}

# Módulo Application - Cria a aplicação com LB e ASG
module "application" {
  source = "./modules/application"

  launch_template_name = local.launch_template_name
  instance_type        = var.instance_type
  ssh_sg_id            = module.network_security.ssh_sg_id
  private_http_sg_id   = module.network_security.private_http_sg_id
  asg_name             = local.asg_name
  asg_desired_capacity = var.asg_desired_capacity
  asg_min_size         = var.asg_min_size
  asg_max_size         = var.asg_max_size
  subnet_ids           = module.network.public_subnet_ids
  lb_name              = local.lb_name
  public_http_sg_id    = module.network_security.public_http_sg_id
  vpc_id               = module.network.vpc_id
}
EOF
```

#### outputs.tf
```bash
cat > outputs.tf << 'EOF'
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "load_balancer_dns" {
  description = "DNS name of the Application Load Balancer"
  value       = module.application.lb_dns_name
}
EOF
```

#### terraform.tfvars

**⚠️ IMPORTANTE**: Substitua `YOUR_IP_HERE` pelo seu IP real!
```bash
# Substituir pelo seu IP
MY_IP=$(curl -s ifconfig.me)

cat > terraform.tfvars << EOF
aws_region           = "us-east-1"
project_prefix       = "cmtr-k5vl9gpq"
vpc_cidr             = "10.10.0.0/16"
public_subnet_a_cidr = "10.10.1.0/24"
public_subnet_b_cidr = "10.10.3.0/24"
public_subnet_c_cidr = "10.10.5.0/24"
instance_type        = "t3.micro"
asg_desired_capacity = 2
asg_min_size         = 2
asg_max_size         = 2
allowed_ip_range     = ["18.153.146.156/32", "$MY_IP/32"]
EOF
```

### 7. Validar e Aplicar
```bash
# Formatar código
terraform fmt -recursive

# Inicializar Terraform
terraform init

# Validar configuração
terraform validate

# Ver plano de execução
terraform plan

# Aplicar (criar infraestrutura)
terraform apply -auto-approve

# Aguardar 3-5 minutos para instâncias iniciarem e passarem health check

# Testar aplicação
LB_DNS=$(terraform output -raw load_balancer_dns)
curl http://$LB_DNS

# Testar balanceamento (ver UUIDs diferentes)
for i in {1..5}; do
  curl -s http://$LB_DNS | grep UUID
  sleep 2
done
```

### 8. Git - Versionamento
```bash
# Inicializar repositório
git init

# Adicionar remote (substitua pela URL do seu repositório)
git remote add origin https://github.com/seu-usuario/seu-repo.git

# Adicionar arquivos
git add .

# Commit
git commit -m "feat: implementa infraestrutura AWS modular com Terraform

- Adiciona módulo network com VPC, subnets e IGW
- Adiciona módulo network_security com security groups
- Adiciona módulo application com ASG e ALB
- Configura .gitignore adequadamente
- Adiciona terraform.tfvars para validação automática"

# Push
git push -u origin main
```

---

## Arquivos Criados

### Hierarquia Completa
```
.
├── .gitignore
├── main.tf
├── outputs.tf
├── provider.tf
├── terraform.tfvars
├── variables.tf
├── versions.tf
└── modules/
    ├── application/
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── network/
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    └── network_security/
        ├── main.tf
        ├── outputs.tf
        └── variables.tf
```

### Recursos AWS Criados

| Módulo | Recurso | Quantidade |
|--------|---------|------------|
| Network | VPC | 1 |
| Network | Subnet | 3 |
| Network | Internet Gateway | 1 |
| Network | Route Table | 1 |
| Network | Route Table Association | 3 |
| Network Security | Security Group | 3 |
| Network Security | Security Group Rule | 6 |
| Application | Launch Template | 1 |
| Application | Auto Scaling Group | 1 |
| Application | EC2 Instance | 2 |
| Application | Load Balancer | 1 |
| Application | Target Group | 1 |
| Application | Listener | 1 |
| Application | ASG Attachment | 1 |
| **TOTAL** | | **~24 recursos** |

---

## Validação e Troubleshooting

### Comandos de Validação
```bash
# Verificar formatação
terraform fmt -check -recursive

# Validar sintaxe
terraform validate

# Ver estado atual
terraform state list

# Ver recursos específicos
terraform state show module.network.aws_vpc.main

# Ver outputs
terraform output

# Verificar recursos na AWS
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=cmtr-k5vl9gpq-vpc"
aws elbv2 describe-load-balancers --names "cmtr-k5vl9gpq-lb"
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "cmtr-k5vl9gpq-asg"
```

### Problemas Comuns e Soluções

#### 1. Erro: "InvalidInstanceID.Malformed"
**Causa**: Instâncias ainda não foram criadas  
**Solução**: Aguarde 2-3 minutos após o apply

#### 2. Erro: "502 Bad Gateway" no Load Balancer
**Causa**: Instâncias ainda não passaram no health check  
**Solução**: 
```bash
# Verificar health do target group
aws elbv2 describe-target-health \
  --target-group-arn $(aws elbv2 describe-target-groups \
    --names "cmtr-k5vl9gpq-asg-tg" \
    --query 'TargetGroups[0].TargetGroupArn' \
    --output text)
```
Aguarde até o estado ser "healthy"

#### 3. Erro no terraform plan: "Exit Code 1"
**Causa**: `terraform.tfvars` não está no Git  
**Solução**: 
- Verificar que `*.tfvars` NÃO está no `.gitignore`
- Commitar `terraform.tfvars`
- Fazer push

#### 4. Erro no terraform apply: "Data output was skipped due to excessive size"
**Causa**: Outputs muito grandes ou recursos duplicados  
**Solução**:
- Simplificar `outputs.tf`
- Destruir infraestrutura existente antes de recriar
- Remover outputs desnecessários

#### 5. Erro: "New SetDesiredCapacity value 0 is below min value 2"
**Causa**: Tentativa de escalar ASG para 0 quando min_size=2  
**Solução**: Para destruir, use `terraform destroy` ao invés de modificar desired_capacity

### Teste em Ambiente Limpo (Simular Validador)
```bash
# Criar diretório temporário
cd /tmp
mkdir terraform-test
cd terraform-test

# Copiar projeto
cp -r ~/Courses/Terraform/AWS_IaC_with_Terraform_Modules1/* .

# Limpar cache
rm -rf .terraform* terraform.tfstate*

# Testar
terraform init
terraform validate
terraform plan

# Verificar exit code (deve ser 0)
echo $?
```

---

## Conceitos Aprendidos

### 1. Modularização em Terraform

**Por que usar módulos?**
- ✅ **Reutilização**: Mesmo código em dev, staging, prod
- ✅ **Organização**: Separação por responsabilidade
- ✅ **Manutenção**: Altere em um lugar, afeta todos
- ✅ **Testabilidade**: Teste módulos independentemente

**Estrutura de um módulo**:
```
module/
├── main.tf       # Recursos
├── variables.tf  # Inputs
└── outputs.tf    # Outputs
```

### 2. Variáveis e Locals

**Variáveis** (`var.`): Inputs parametrizáveis
```hcl
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}
```

**Locals** (`local.`): Valores computados reutilizáveis
```hcl
locals {
  vpc_name = "${var.project_prefix}-vpc"
}
```

**Por que não hardcode?**
- ❌ Dificulta reutilização
- ❌ Torna código inflexível
- ❌ Aumenta manutenção
- ✅ Use variáveis e locals!

### 3. Outputs

Exportam valores para:
- Outros módulos (comunicação entre módulos)
- Usuário final (URLs, IDs)
- Outros stacks Terraform (remote state)

### 4. Data Sources

Buscam informações existentes na AWS:
```hcl
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  # ...
}
```

### 5. Dependências Implícitas

Terraform detecta automaticamente:
```hcl
# ASG depende de Launch Template
resource "aws_autoscaling_group" "main" {
  launch_template {
    id = aws_launch_template.main.id  # Dependência!
  }
}
```

### 6. Lifecycle Rules

Controlam comportamento do Terraform:
```hcl
lifecycle {
  ignore_changes = [load_balancers]  # Ignora mudanças externas
}
```

### 7. Security Groups

**Ingress**: Tráfego entrando  
**Egress**: Tráfego saindo

**Best Practice**: Use referências entre SGs
```hcl
# ✅ BOM: Referência de SG
source_security_group_id = aws_security_group.public_http.id

# ❌ EVITE: CIDR block
cidr_blocks = ["10.0.0.0/16"]
```

### 8. Auto Scaling

**Componentes**:
1. **Launch Template**: Como criar instâncias
2. **Auto Scaling Group**: Quantas criar
3. **Target Group**: Onde registrar
4. **Health Check**: Como verificar saúde

**Grace Period**: Tempo antes de verificar saúde (300s = 5min)

### 9. Load Balancing

**Fluxo**:
```
Internet → ALB (porta 80) → Target Group → Instâncias EC2
```

**Health Check**: ALB verifica `/` retorna 200

### 10. User Data

Script executado na primeira inicialização:
```bash
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
```

**IMPORTANTE**: Usar heredoc inline evita problemas com validadores

---

## Checklist Final

### Antes de Submeter ao Validador

- [ ] Todos os arquivos `.tf` formatados (`terraform fmt -recursive`)
- [ ] `terraform validate` passa sem erros
- [ ] `terraform plan` retorna exit code 0 em ambiente limpo
- [ ] `terraform.tfvars` está commitado no Git
- [ ] `.gitignore` NÃO ignora `terraform.tfvars`
- [ ] Infraestrutura local foi destruída (`terraform destroy`)
- [ ] Último commit foi feito push
- [ ] Repository URL, branch e folder estão corretos

### Verificação em Ambiente Limpo
```bash
cd /tmp && mkdir test && cd test
git clone <seu-repo> .
terraform init
terraform validate
terraform plan
echo "Exit code: $?"  # Deve ser 0
```

### Parâmetros do Validador

- **Repository URL**: `https://<username>:<deploy_token>@<repository-url>.git`
- **Repository branch**: `main`
- **Repository folder**: `.` (raiz do repositório)

---

## Comandos Úteis de Referência

### Terraform Básico
```bash
terraform init          # Inicializar
terraform validate      # Validar sintaxe
terraform fmt          # Formatar código
terraform plan         # Ver mudanças
terraform apply        # Aplicar mudanças
terraform destroy      # Destruir tudo
terraform output       # Ver outputs
terraform state list   # Listar recursos
```

### AWS CLI
```bash
# VPC
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=cmtr-k5vl9gpq-vpc"

# Instâncias
aws ec2 describe-instances --filters "Name=tag:Name,Values=cmtr-k5vl9gpq-template"

# Load Balancer
aws elbv2 describe-load-balancers --names "cmtr-k5vl9gpq-lb"

# Target Health
aws elbv2 describe-target-health --target-group-arn <ARN>

# Auto Scaling Group
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "cmtr-k5vl9gpq-asg"
```

### Git
```bash
git status             # Ver status
git add .              # Adicionar tudo
git commit -m "msg"    # Commitar
git push               # Enviar para remoto
git log -1 --oneline   # Ver último commit
git ls-files           # Listar arquivos rastreados
```

---

## Recursos Adicionais

### Documentação Oficial
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Modules](https://developer.hashicorp.com/terraform/language/modules)
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [AWS Auto Scaling](https://docs.aws.amazon.com/autoscaling/)
- [AWS ELB](https://docs.aws.amazon.com/elasticloadbalancing/)

### Boas Práticas
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

---

## Conclusão

Você implementou com sucesso uma arquitetura AWS completa e profissional usando Terraform com módulos! 

**Principais conquistas**:
- ✅ Arquitetura modular e reutilizável
- ✅ Alta disponibilidade (multi-AZ)
- ✅ Auto scaling e load balancing
- ✅ Security seguindo least privilege
- ✅ Infraestrutura como código versionada
- ✅ Código limpo e bem documentado

**Próximos passos sugeridos**:
- Adicionar HTTPS com ACM
- Implementar políticas de auto scaling baseadas em métricas
- Adicionar CloudWatch alarms
- Implementar CI/CD com GitHub Actions
- Criar ambientes separados (dev/staging/prod)

---

**Versão**: 1.0  
**Data**: Janeiro 2026  
**Autor**: Lab Solution AWS IaC with Terraform Modules
EOF

# Formatar
terraform fmt

# Adicionar ao Git
git add Lab_solution.md
git commit -m "docs: adiciona documentação completa da solução do lab"
git push
