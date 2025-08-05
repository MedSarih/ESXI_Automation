# Configure the vSphere provider and authentication details
provider "vsphere" {
  user                 = var.vsphere_user          
  password             = var.vsphere_password      
  vsphere_server       = var.vsphere_server        
  allow_unverified_ssl = true                      
}

# calling module to create multiple VMs based on vm_configs map variable
module "vms" {
  source = "./modules/vm"                          

  for_each = var.vm_configs                        # Loop over each VM config entry (key = VM name)

  # Pass parameters to the module from the vm_configs map and variables
  name          = each.key                         # VM name from map key (e.g., vm1, vm2)
  cpu           = each.value.cpu                   # Number of CPUs for this VM
  memory        = each.value.memory                # Memory size (MB) for this VM
  disk_size     = each.value.disk_size             # Disk size in GB
  ip_last_octet = each.value.ip_last_octet         # Last octet for VM IP address

  datacenter    = each.value.datacenter            # vSphere datacenter where VM will be created
  cluster       = each.value.cluster               # vSphere cluster for placement
  datastore     = each.value.datastore             # Datastore to store VM files
  network       = each.value.network               # Network name to connect the VM to

  template_name = var.template_name                 # VM template to clone from (same for all VMs)

  vm_ip_subnet  = var.vm_ip_subnet                  # Subnet part of the VM IP address (e.g., 192.168.1)
  vm_gateway    = var.vm_gateway                    # Default gateway for VMs
}



# Generate Ansible inventory file with role-based groups automatically
# This runs during terraform apply and creates inventory.ini in your current directory
resource "null_resource" "generate_inventory" {
  depends_on = [module.vms]
  
  provisioner "local-exec" {
    command = <<EOT
echo "🔄 Generating smart Ansible inventory from Terraform..."

# Create temporary file with structured VM data
echo '${jsonencode({
  for key, config in var.vm_configs: key => {
    name = config.name
    ip   = module.vms.vm_ips[key]
    role = config.role
    ansible_user = "ubuntu"
  }
})}' > terraform-output.json

# Generate smart inventory file
echo "# 🚀 Auto-generated Ansible Inventory" > inventory.ini
echo "# Generated on: $(date)" >> inventory.ini
echo "" >> inventory.ini

# Monitoring servers group
echo "[monitoring_servers]" >> inventory.ini
jq -r 'to_entries[] | select(.value.role == "monitoring") | "\(.value.name) ansible_host=\(.value.ip) ansible_user=\(.value.ansible_user) ansible_ssh_private_key_file=~/.ssh/id_rsa"' terraform-output.json >> inventory.ini

echo "" >> inventory.ini

# Application servers group
echo "[application_servers]" >> inventory.ini
jq -r 'to_entries[] | select(.value.role == "application") | "\(.value.name) ansible_host=\(.value.ip) ansible_user=\(.value.ansible_user) ansible_ssh_private_key_file=~/.ssh/id_rsa"' terraform-output.json >> inventory.ini

echo "" >> inventory.ini

# Global variables
echo "[all:vars]" >> inventory.ini
echo "ansible_ssh_private_key_file = ~/.ssh/id_rsa" >> inventory.ini
echo "ansible_ssh_common_args = -o StrictHostKeyChecking=no" >> inventory.ini

# Cleanup temporary file
rm -f terraform-output.json

echo "✅ Smart inventory generated: inventory.ini"
echo "📋 Inventory contents:"
cat inventory.ini
EOT
  }
}