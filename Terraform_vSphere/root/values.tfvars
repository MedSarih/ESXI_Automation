vsphere_user     = "administrator@vsphere.local"
vsphere_password = "YourSuperSecretPassword"
vsphere_server   = "vcenter.example.com"

template_name    = "ubuntu-template"

vm_ip_subnet     = "192.168.1"
vm_gateway       = "192.168.1.1"

vm_configs = {
  VM1 = {
    cpu          = 2
    memory       = 4096
    disk_size    = 20
    ip_last_octet = 101

    datacenter   = "Datacenter1"
    cluster      = "Cluster1"
    datastore    = "datastore1"
    network      = "VM Network"

    role      = "application"
  }
  VM2 = {
    cpu          = 4
    memory       = 8192
    disk_size    = 50
    ip_last_octet = 102 

    datacenter   = "Datacenter2"
    cluster      = "Cluster2"
    datastore    = "datastore2"
    network      = "VM Network2"

    role      = "application"
  }
  Monitoring = {
    cpu          = 6
    memory       = 16384
    disk_size    = 100
    ip_last_octet = 103

    datacenter   = "Datacenter1"
    cluster      = "Cluster1"
    datastore    = "datastore3"
    network      = "VM Network"

    role      = "monitoring"
  }
}

