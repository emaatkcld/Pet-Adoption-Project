output "route53-nameservers" {
  value = aws_route53_zone.PCJEU2_R53.name_servers
} 

output "Docker_host-public-ip" {
  value = aws_instance.PCJEU2_Docker_Host.public_ip
}

output "Ansible_host-ip" {
  value = aws_instance.PCJEU2_Ansible_Node.public_ip
}

output "Sonaqube-public-ip" {
  value = aws_instance.Sonarqube_Server.public_ip
}

output "Jenkins-public-ip" {
  value = aws_instance.jenkins_instance.public_ip
}