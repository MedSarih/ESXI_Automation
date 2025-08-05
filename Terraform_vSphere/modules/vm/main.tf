# Fetch datacenter
data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

# Fetch cluster
data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Fetch datastore
data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Fetch network information for VM NIC-NetworkInterfaceCard
data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Fetch VM template created by Packer
data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = var.name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = var.cpu
  memory   = var.memory

  guest_id  = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

 # Configure network interface for the VM
  network_interface {
    network_id = data.vsphere_network.network.id
  }
 
   # Define virtual disk configuration
  disk {
    label            = "disk0"
    size             = var.disk_size
    thin_provisioned = true
  }

   # Clone settings to create VM from a template
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    # Customize the VM after cloning
    customize {
      linux_options {
        host_name = var.name     # Set VM hostname as the map key
        domain    = "example.local"    # Set the domain name for the VM
    }
      
    # Customize network settings for VM
    network_interface {
        ipv4_address = "${var.vm_ip_subnet}.${var.ip_last_octet}"   # Assign a static IP address by combining subnet and last octet
        ipv4_netmask = 24                                           # Set subnet mask (CIDR /24 = 255.255.255.0)
    }
      
    
    # Set the default gateway for the VM
      ipv4_gateway = var.vm_gateway
    }
  }
   # Assign tags for categorization and management
  tags = ["env:dev", "managed_by:terraform", "project:vmware-automation"]
}



