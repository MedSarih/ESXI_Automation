# Declare required Packer plugins
packer {
  required_plugins {
    vsphere = {
      source  = "github.com/hashicorp/vsphere" # Plugin source for vSphere
      version = ">= 1.0.0"                     
    }
  }
}

# How the VM is built
source "vsphere-iso" "ubuntu" {
  # Connection info to vSphere
  vcenter_server      = var.vcenter_server
  username            = var.username
  password            = var.password
  datacenter          = var.datacenter
  cluster             = var.cluster
  datastore           = var.datastore
  folder              = "Templates"          # vSphere folder to save template
  convert_to_template = true                 # Convert VM to template after creation
  insecure_connection = true                 # Accept self-signed certs (not for production)

  # VM network settings
  network              = var.network
  network_adapter_type = "vmxnet3"           # Modern, high-performance NIC
  guest_os_type        = "ubuntu64Guest"     # OS identifier for vSphere

  # Basic VM hardware settings
  vm_name   = var.template_name              # Name of the VM/template
  cpus      = 2
  memory    = 2048
  disk_size = 20000                          # Disk size in MB

  # SSH communicator settings for Packer to connect to the VM
  communicator       = "ssh"
  ssh_username       = "ubuntu"
  ssh_password       = "packer"
  ssh_timeout        = "20m"
  ssh_wait_timeout   = "20m"

  # ISO settings for Ubuntu installation
  iso_url            = var.iso_url
  iso_checksum       = var.iso_checksum
  iso_checksum_type  = "sha256"

  # Wait time after power-on before boot command
  boot_wait = "5s"

  # Boot command to automate the OS install using preseed
  boot_command = [
    "<esc><wait>",
    "<enter><wait>",
    "/install/vmlinuz auto",
    " console=ttyS0",
    " preseed/file=/floppy/ubuntu-preseed.cfg",
    " debian-installer=en_US auto locale=en_US",
    " hostname=ubuntu",
    " fb=false debconf/frontend=noninteractive",
    " keyboard-configuration/modelcode=SKIP keyboard-configuration/layout=USA",
    " initrd=/install/initrd.gz -- <enter>"
  ]

  # Preseed and cloud-init configuration files passed via floppy
  floppy_files = [
    "http/ubuntu-preseed.cfg",
    "http/meta-data",
    "http/user-data"
  ]
}

# Build block defines how Packer provisions the VM
build {
  sources = ["source.vsphere-iso.ubuntu"]

  # Inline shell provisioner to install tools and clean image
  provisioner "shell" {
    inline = [
      "echo 'Provisioning base template...'",           # Debug info
      "apt update",                                     # Update apt cache
      "apt install -y qemu-guest-agent",                # Install VMware tools alternative
      "systemctl enable qemu-guest-agent",              # Enable it on boot
      "cloud-init clean",                               # Clean cloud-init cache
      "shutdown -h now"                                 # Power off VM to allow snapshot/template creation
    ]
  }
}
