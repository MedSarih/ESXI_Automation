# Output a map of VM names to their IP addresses
output "vm_ips" {
  description = "Expose the VM IP map from the module"
  value       = module.vms.vm_ips
}


# Structured VM information for Ansible inventory generation
output "vm_inventory" {
  description = "Structured VM information for Ansible inventory generation"
  value = {
    # Loop through each VM configuration and create structured output
    for key, config in var.vm_configs : key => {
      name        = config.name              # VM name from configuration
      ip          = module.vms.vm_ips[key]   # IP from module output
      role        = config.role              # VM role from configuration
      ansible_user = "ubuntu"                # User Ansible will use to connect
    }
  }
}