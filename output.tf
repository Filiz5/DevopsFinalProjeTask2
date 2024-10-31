output "public_ip" {
    value = aws_instance.devops_project_instance[*].public_ip
}

output "workspace_instance_ip" {
  description = "Public IP"
  value       = "${terraform.workspace}-instance ip: ${aws_instance.tfmyec2.public_ip}"
}

output "instance_id" {
  description = "Public Id"
  value       = aws_instance.tfmyec2.id
}
