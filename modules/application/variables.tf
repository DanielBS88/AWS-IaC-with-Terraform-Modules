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
