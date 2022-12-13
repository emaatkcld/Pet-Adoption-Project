output "route53-nameservers" {
  value = aws_route53_zone.PCJEU2_R53.name_servers
} 