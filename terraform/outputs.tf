output "loadbalancer_private_ip" {
  value = aws_instance.loadbalancer.private_ip
}

output "loadbalancer_private_dns" {
  value = aws_instance.loadbalancer.private_dns
}

output "loadbalancer_public_dns" {
  value = aws_instance.loadbalancer.public_dns
}

output "loadbalancer_public_ip" {
  value = aws_instance.loadbalancer.public_ip
}

output "loadbalancer_eip" {
  value = var.loadbalancer_ip
}