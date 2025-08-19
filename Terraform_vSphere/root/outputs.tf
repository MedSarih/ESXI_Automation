# Root essential outputs
output "vm_ips" {
  description = "Map of VM names to their IP addresses"
  value = {
    for name, vm in module.vm :
    name => vm.vm_ip
  }
}

output "vm_inventory" {
  description = "VM inventory for Ansible"
  value = {
    for name, cfg in var.vm_configs : name => {
      name         = name
      ip           = module.vm[name].vm_ip
      ansible_user = "ubuntu"
      role         = cfg.role
    }
  }
}

