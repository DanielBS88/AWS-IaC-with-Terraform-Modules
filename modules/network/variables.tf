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
