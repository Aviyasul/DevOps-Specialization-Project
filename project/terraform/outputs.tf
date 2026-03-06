output "ssh_private_key_path" {
  value       = local_file.private_key.filename
  description = "Path to the generated private SSH key"
  sensitive   = true
}

output "ssh_key_name" {
  value       = aws_key_pair.builder_key.key_name
  description = "Name of the AWS SSH key pair"
}

output "public_ip" {
  value       = aws_instance.builder.public_ip
  description = "Public IP of the EC2 instance"
}

output "security_group_id" {
  value       = aws_security_group.builder_sg.id
  description = "Security Group ID"
}