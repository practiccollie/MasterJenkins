# Output for the public IP of the EC2 instance
output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.jenkins.public_ip
}

# Output for the public DNS of the EC2 instance
output "public_dns" {
  description = "Public DNS of the EC2 instance"
  sensitive   = false
  value       = aws_instance.jenkins.public_dns
}

# Output for the private IP of the EC2 instance
output "private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.jenkins.private_ip
}
