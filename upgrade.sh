#!/bin/bash

# Function to update the system
update_system() {
  local node=$1

  echo "Starting system upgrade on node $node"

  # Perform a general system upgrade
  nsenter --target 1 --mount --uts --ipc --net --pid -- bash -c "
    apt update -y
    apt upgrade -y
    update-grub
  "

  # Check if a reboot is required
  if nsenter --target 1 --mount --uts --ipc --net --pid -- bash -c "test -f /var/run/reboot-required && grep -q '*** System restart required ***' /var/run/reboot-required"; then
    echo "Reboot required for node $node. Rebooting now."
    nsenter --target 1 --mount --uts --ipc --net --pid -- reboot

    # Wait for the node to reboot and become ready
    while ! kubectl get node $node -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' | grep -q "True"; do
      echo "Waiting for node $node to be ready..."
      sleep 120
    done

    # Verify the uptime to ensure the node was rebooted
    node_uptime=$(kubectl get node $node -o jsonpath='{.status.nodeInfo.uptime}')
    if [ $(echo $node_uptime | awk '{print $1}') -lt 300 ]; then
      echo "Node $node was successfully rebooted."
    else
      echo "Node $node did not reboot as expected."
    fi
  else
    echo "Reboot not required for node $node."
  fi

  # Label the node as upgraded
  kubectl label nodes $node upgrade=done --overwrite

  echo "System upgrade on node $node completed."
  sleep 30

  # Add label after upgrade
  kubectl label nodes $(hostname) upgrade=done --overwrite
}

# Function to update the CronJob manifest with a new nodeSelector
update_cronjob_manifest() {
  local next_node=$(kubectl get nodes --no-headers -l='!upgrade' -o custom-columns=":metadata.name" | head -n 1)

  # If no more nodes are available, reset labels (optional)
  if [ -z "$next_node" ]; then
    echo "No more nodes to upgrade. Resetting labels."
    kubectl label nodes --all upgrade-
    next_node=$(kubectl get nodes --no-headers -l='!upgrade' -o custom-columns=":metadata.name" | head -n 1)
  fi

  # Update the CronJob's nodeSelector
  kubectl patch cronjob upgrade-cronjob --namespace kube-system --type='json' -p='[{"op": "add", "path": "/spec/jobTemplate/spec/template/spec/nodeSelector", "value": {"kubernetes.io/hostname": '$next_node'}}]'
  echo "CronJob nodeSelector updated to $next_node."
}

# Function to determine if a node needs an update
node_needs_update() {
  if nsenter --target 1 --mount --uts --ipc --net --pid -- bash -c "test -f /var/run/reboot-required && grep -q '*** System restart required ***' /var/run/reboot-required"; then
    echo "true"
  else
    echo "false"
  fi
}

# Main function to manage the update
manage_update() {

  # Get the current node that this CronJob pod is running on
  local current_node=$(hostname)

  echo "Current node: $current_node"

  # Check if the node needs an update
  if [ $(node_needs_update) == "true" ]; then
    echo "Node $current_node needs an update"
    
    # Update the system
    update_system $current_node
  else
    echo "Node $current_node does not need an update"
    # Label the node as upgraded even if no update is needed
    kubectl label nodes $current_node upgrade=done --overwrite
  fi

  # Update the CronJob manifest to target the next node
  update_cronjob_manifest $current_node
}

manage_update
