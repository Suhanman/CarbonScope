output "nat_id" {
  value = aws_instance.nat.id
}

output "nat_network_interface_id" {
  value       = aws_instance.nat.primary_network_interface_id
  description = "NAT 인스턴스의 네트워크 인터페이스 ID"
}