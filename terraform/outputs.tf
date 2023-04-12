output "gateway_private_ip" {
  value = aws_instance.wireguard.private_ip
}

output "gateway_private_dns" {
  value = aws_instance.wireguard.private_dns
}

output "gateway_public_dns" {
  value = aws_instance.wireguard.public_dns
}

output "k8s_security_groups" {
  value = data.aws_security_group.k8s_security_groups.*.id
}

output "wireguard_security_groups" {
  value = data.aws_security_group.wireguard_security_groups.*.id
}

output "gateway_public_ip" {
  value = aws_instance.wireguard.public_ip
}

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

output "gateway_eip" {
  value = var.wireguard_ip
}
