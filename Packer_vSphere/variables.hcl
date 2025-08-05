# Variable declarations 
variable "vcenter_server" {}     # vCenter hostname or IP
variable "username" {}           # vSphere username
variable "password" {}           # vSphere password
variable "datacenter" {}         # Datacenter name in vSphere
variable "cluster" {}            # Cluster name
variable "datastore" {}          # Datastore to use
variable "network" {}            # Network to attach the VM to
variable "template_name" {}      # Name for the new VM template
variable "iso_url" {}            # URL to Ubuntu ISO
variable "iso_checksum" {}       # SHA256 checksum of the ISO