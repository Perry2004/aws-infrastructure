output "vpc_id" {
  description = "ID of the test VPC"
  value       = aws_vpc.test_vpc.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the test VPC"
  value       = aws_vpc.test_vpc.cidr_block
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.test_public_subnet.id
}

output "security_group_id" {
  description = "ID of the test security group"
  value       = aws_security_group.test_sg.id
}

output "instance_id" {
  description = "ID of the test instance"
  value       = aws_instance.test-instance.id
}

output "instance_public_ip" {
  description = "Public IP of the test instance"
  value       = aws_instance.test-instance.public_ip
}
