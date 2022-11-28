output "public_IP_address_of_Docker_host-public-ip" {
  value = aws_instance.PCJEU2_Docker_Host.public_ip
}

output "my-docker_host-id" {
  value = aws_instance.PCJEU2_Docker_Host.id
}

output "docker-host-private-ip" {
  value = aws_instance.PCJEU2_Docker_Host.private_ip
}