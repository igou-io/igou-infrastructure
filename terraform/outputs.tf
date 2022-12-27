output "gateway_private_ip" {
  value = aws_instance.wireguard.private_ip
}

output "gateway_private_dns" {
  value = aws_instance.wireguard.private_dns
}

output "gateway_public_dns" {
  value = aws_instance.wireguard.public_dns
}

output "gateway_public_ip" {
  value = aws_eip.wireguard.public_ip
}

output "var_vpc_main_route_table" {
  value = module.vpc_main.vpc_main_route_table_id 
}

output "var_default_route_table_id" {
  value = module.vpc_main.default_route_table_id 
}

output "var_default_vpc_default_route_table_id" {
  value = module.vpc_main.default_vpc_default_route_table_id 
}

output "var_default_vpc_main_route_table_id" {
  value = module.vpc_main.default_vpc_main_route_table_id
}

output "var_vpc_public_route_table_ids" {
  value = module.vpc_main.public_route_table_ids
}

