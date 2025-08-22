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
  echo "Contents preview:"
  head -10 "$TERRAFORM_OUTPUT"
  exit 1
fi

echo "🔍 Parsing VMs from vm_inventory.value..."

# Start fresh inventory
> "$INVENTORY_FILE"

# Add monitoring servers - Correct path: .vm_inventory.value
echo "[monitoring_servers]" >> "$INVENTORY_FILE"
jq -r '
  .vm_inventory.value
  | to_entries[]
  | select(.value | type == "object")
  | select(.value.role == "monitoring")
  | "\(.value.name) ansible_host=\(.value.ip) ansible_user=\(.value.ansible_user // "ubuntu")"
' "$TERRAFORM_OUTPUT" >> "$INVENTORY_FILE" || echo "# No monitoring servers found or error parsing" >> "$INVENTORY_FILE"

# Add application servers - Correct path: .vm_inventory.value
echo "" >> "$INVENTORY_FILE"
echo "[application_servers]" >> "$INVENTORY_FILE"
jq -r '
  .vm_inventory.value
  | to_entries[]
  | select(.value | type == "object")
  | select(.value.role == "application")
  | "\(.value.name) ansible_host=\(.value.ip) ansible_user=\(.value.ansible_user // "ubuntu")"
' "$TERRAFORM_OUTPUT" >> "$INVENTORY_FILE" || echo "# No application servers found or error parsing" >> "$INVENTORY_FILE"

# Add all_servers group
echo "" >> "$INVENTORY_FILE"
echo "[all_servers:children]" >> "$INVENTORY_FILE"
echo "monitoring_servers" >> "$INVENTORY_FILE"
echo "application_servers" >> "$INVENTORY_FILE"

# Add global variables (using Jenkins variable placeholder)
echo "" >> "$INVENTORY_FILE"
echo "[all:vars]" >> "$INVENTORY_FILE"
echo "ansible_ssh_pass = \${ANSIBLE_VM_CREDENTIALS}" >> "$INVENTORY_FILE"
echo "ansible_ssh_common_args = -o StrictHostKeyChecking=no" >> "$INVENTORY_FILE"

# Final check
if [[ ! -s "$INVENTORY_FILE" ]]; then
  echo "❌ ERROR: Inventory file is empty after generation!" >&2
  echo "This usually means vm_inventory data was missing or malformed."
  exit 1
fi

echo "✅ SUCCESS: Inventory generated at $INVENTORY_FILE"
echo ""
echo "📄 Final inventory contents:"
cat "$INVENTORY_FILE"
echo ""