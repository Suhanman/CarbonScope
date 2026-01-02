output "app_key_name" {
  value       = aws_key_pair.app_key.key_name
}

output "app_key_public" {
  value       = tls_private_key.app_key.public_key_openssh
}

output "app_private_key_local_file" {
  description = "Local path to the private key file"
  value       = local_file.app_private_key.filename
}