output "public_ips" {
  value = aws_instance.Sample-Ecommerce-Instance.*.public_ip
  description = "Public IP addresses of the created instances"
}