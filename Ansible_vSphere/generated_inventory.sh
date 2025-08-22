#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INVENTORY_FILE="$SCRIPT_DIR/inventory.ini"
TERRAFORM_OUTPUT="$SCRIPT_DIR/terraform-output.json"

echo "🔧 Generating Ansible inventory..."
echo "📁 Inventory file: $INVENTORY_FILE"
echo "📄 Terraform output: $TERRAFORM_OUTPUT"

# Check if file exists
if [[ ! -f "$TERRAFORM_OUTPUT" ]]; then
  echo "❌ ERROR: Terraform output file not found: $TERRAFORM_OUTPUT" >&2
  exit 1
fi

# Validate JSON
if ! jq -e . "$TERRAFORM_OUTPUT" > /dev/null 2>&1; then
  echo "❌ ERROR: Invalid JSON in $TERRAFORM_OUTPUT" >&2
  exit 1
fi

# Extract vm_inventory object and iterate over its entries
echo "🔍 Parsing VMs from vm_inventory..."

# Start fresh inventory
> "$INVENTORY_FILE"

# Add monitoring servers
echo "[monitoring_servers]" >> "$INVENTORY_FILE"
jq -r '
  .vm_inventory
  | to_entries[]
  | select(.value.role == "monitoring")
  | "\(.value.name) ansible_host=\(.value.ip) ansible_user=\(.value.ansible_user)"
' "$TERRAFORM_OUTPUT" >> "$INVENTORY_FILE" || echo "No monitoring servers found" >> "$INVENTORY_FILE"

# Add application servers
echo "" >> "$INVENTORY_FILE"
echo "[application_servers]" >> "$INVENTORY_FILE"
jq -r '
  .vm_inventory
  | to_entries[]
  | select(.value.role == "application")
  | "\(.value.name) ansible_host=\(.value.ip) ansible_user=\(.value.ansible_user)"
' "$TERRAFORM_OUTPUT" >> "$INVENTORY_FILE" || echo "No application servers found" >> "$INVENTORY_FILE"

# Add all_servers group
echo "" >> "$INVENTORY_FILE"
echo "[all_servers:children]" >> "$INVENTORY_FILE"
echo "monitoring_servers" >> "$INVENTORY_FILE"
echo "application_servers" >> "$INVENTORY_FILE"

# Add global variables
cat >> "$INVENTORY_FILE" << EOF

[all:vars]
ansible_ssh_pass = \${ANSIBLE_VM_CREDENTIALS}
ansible_ssh_common_args = -o StrictHostKeyChecking=no
EOF

# Final check
if [[ ! -s "$INVENTORY_FILE" ]]; then
  echo "❌ ERROR: Inventory file is empty!" >&2
  exit 1
fi

echo "✅ SUCCESS: Inventory generated at $INVENTORY_FILE"
echo ""
echo "📄 Final inventory contents:"
cat "$INVENTORY_FILE"
echo ""