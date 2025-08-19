output "vm_ip" {
  value       = esxi_guest.vm.ip_address
  description = "The IP address of this VM"
}
