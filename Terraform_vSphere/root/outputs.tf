# Root essential outputs
output "vm_ips" {
  description = "Map of VM names to their IP addresses"
  value = {
    for name, vm in module.vm :
    name => vm.vm_ip
  }
}



