# Locals - valores computados/concatenados usados em múltiplos lugares
locals {
  vpc_name             = "${var.project_prefix}-vpc"
  subnet_public_a_name = "${var.project_prefix}-subnet-public-a"
  subnet_public_b_name = "${var.project_prefix}-subnet-public-b"
  subnet_public_c_name = "${var.project_prefix}-subnet-public-c"
  igw_name             = "${var.project_prefix}-igw"
  route_table_name     = "${var.project_prefix}-rt"
  ssh_sg_name          = "${var.project_prefix}-ssh-sg"
  public_http_sg_name  = "${var.project_prefix}-public-http-sg"
  private_http_sg_name = "${var.project_prefix}-private-http-sg"
  launch_template_name = "${var.project_prefix}-template"
  asg_name             = "${var.project_prefix}-asg"
  lb_name              = "${var.project_prefix}-lb"
}

# Módulo Network - Cria toda a infraestrutura de rede
module "network" {
  source = "./modules/network"

  vpc_name             = local.vpc_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_a_name = local.subnet_public_a_name
  public_subnet_a_cidr = var.public_subnet_a_cidr
  public_subnet_a_az   = "${var.aws_region}a"
  public_subnet_b_name = local.subnet_public_b_name
  public_subnet_b_cidr = var.public_subnet_b_cidr
  public_subnet_b_az   = "${var.aws_region}b"
  public_subnet_c_name = local.subnet_public_c_name
  public_subnet_c_cidr = var.public_subnet_c_cidr
  public_subnet_c_az   = "${var.aws_region}c"
  igw_name             = local.igw_name
  route_table_name     = local.route_table_name
  allowed_ip_range     = var.allowed_ip_range
}

# Módulo Network Security - Cria os security groups
module "network_security" {
  source = "./modules/network_security"

  vpc_id               = module.network.vpc_id
  ssh_sg_name          = local.ssh_sg_name
  public_http_sg_name  = local.public_http_sg_name
  private_http_sg_name = local.private_http_sg_name
  allowed_ip_range     = var.allowed_ip_range
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
