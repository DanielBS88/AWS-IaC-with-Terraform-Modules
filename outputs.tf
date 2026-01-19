output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "load_balancer_dns" {
  description = "DNS name of the Application Load Balancer"
  value       = module.application.lb_dns_name
}
