# Creating Route53 Hosted Zone
resource "aws_route53_zone" "PCJEU2_R53" {
  name = "awaiye.com"
  tags = {
    Environment = "PCJEU2_R53"
  }
}  

# A record pointing to a load balancer
resource "aws_route53_record" "PCJEU2_lb" {
  zone_id = aws_route53_zone.PCJEU2_R53.id
  name    = "awaiye.com"
  type    = "A"
  alias {
    name                   = aws_lb.PCJEU2-alb.dns_name
    zone_id                = aws_lb.PCJEU2-alb.zone_id
    evaluate_target_health = true
  }
}