output "route53_name_servers" {
  description = "Route53 nameservers to add to Namecheap"
  value       = module.dns.route53_name_servers
}