# Output VM IP addresses as a map from VM name to IP
# lets ROOT easily see the IP addresses of all VMs 
output "vm_ips" {
  description = "Map of VM names to their IPs"
  value = {
    for name, vm in vsphere_virtual_machine.vm :
    name => vm.default_ip_address
  }
}
