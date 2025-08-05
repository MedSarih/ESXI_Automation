#!/bin/bash
#Generate Ansible inventory from Terraform output

set -e  # Exit script if any command fails

INVENTORY_FILE="inventory.ini"
TEMP_OUTPUT="terraform-output.json"


# Extract Terraform output as JSON
terraform output -json vm_inventory > "$TEMP_OUTPUT"

> "$INVENTORY_FILE"

# Add monitoring servers group
echo "[monitoring_servers]" >> "$INVENTORY_FILE"
jq -r '
  to_entries[] 
  | select(.value.role == "monitoring") 
  | "\(.value.name) ansible_host=\(.value.ip) ansible_user=\(.value.ansible_user) ansible_ssh_private_key_file=~/.ssh/id_rsa"
' "$TEMP_OUTPUT" >> "$INVENTORY_FILE"

# Add application servers group
echo "" >> "$INVENTORY_FILE"
echo "[application_servers]" >> "$INVENTORY_FILE"
jq -r '
  to_entries[] 
  | select(.value.role == "application") 
  | "\(.value.name) ansible_host=\(.value.ip) ansible_user=\(.value.ansible_user) ansible_ssh_private_key_file=~/.ssh/id_rsa"
' "$TEMP_OUTPUT" >> "$INVENTORY_FILE"

# Add common variables
echo "" >> "$INVENTORY_FILE"
echo "[all:vars]" >> "$INVENTORY_FILE"
echo "ansible_ssh_private_key_file = ~/.ssh/id_rsa" >> "$INVENTORY_FILE"
echo "ansible_ssh_common_args = -o StrictHostKeyChecking=no" >> "$INVENTORY_FILE"

# Clean up temporary file
rm -f "$TEMP_OUTPUT"
