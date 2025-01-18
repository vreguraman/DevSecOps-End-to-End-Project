output "instance_ips" {
  value = aws_instance.Sample-Ecommerce-Instance.*.public_ip
}
