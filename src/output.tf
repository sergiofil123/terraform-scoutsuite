output "public_ip" {
  description = "Public IP of Scout Suite VM"
  value       = module.ec2_vm.public_ip
}
