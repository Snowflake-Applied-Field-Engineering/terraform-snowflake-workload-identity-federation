#!/usr/bin/env bash
# GCE startup-script that bootstraps cloud-init on images that don't ship it
# (notably Google's `debian-cloud/debian-*` family). After installing
# cloud-init, this script invokes all four cloud-init stages against the
# user-data we've placed in instance metadata. The Google guest agent runs
# this script on first boot (and on every boot thereafter, but we no-op
# subsequent runs via a sentinel file).
#
# References:
#   https://cloud.google.com/compute/docs/instances/startup-scripts/linux
#   https://cloudinit.readthedocs.io/en/latest/explanation/boot.html
set -euxo pipefail

SENTINEL=/var/lib/snowflake-test/.cloud-init-bootstrap.done
LOG=/var/log/snowflake-test-bootstrap.log
exec > >(tee -a "$LOG") 2>&1

mkdir -p "$(dirname "$SENTINEL")"

if [[ -f "$SENTINEL" ]]; then
  echo "Cloud-init bootstrap already ran on $(cat "$SENTINEL"); skipping."
  exit 0
fi

echo "[$(date -Is)] Starting cloud-init bootstrap..."

# Wait for any apt-daily lock to clear; otherwise our install can fail
# while the daily timer is doing its thing on first boot.
for i in $(seq 1 60); do
  if ! fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 \
     && ! fuser /var/lib/apt/lists/lock >/dev/null 2>&1 \
     && ! fuser /var/lib/dpkg/lock >/dev/null 2>&1; then
    break
  fi
  echo "Waiting for apt lock... ($i/60)"
  sleep 5
done

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y cloud-init

# Tell cloud-init this is a GCE instance. Without this, on an image that
# never had cloud-init, the datasource list isn't pinned and detection can
# fall back to NoCloud (which won't read GCE metadata).
mkdir -p /etc/cloud/cloud.cfg.d
cat >/etc/cloud/cloud.cfg.d/90_dpkg.cfg <<'EOF'
datasource_list: [ GCE, None ]
EOF

# Clean any partial state from the apt install (which can leave behind
# instance-id artifacts that cause cloud-init to think it's already run).
cloud-init clean --logs

# Run all four cloud-init stages in order. On newer cloud-init versions
# this could be `cloud-init init --all-stages`, but invoking each stage
# explicitly works across versions.
cloud-init init --local || true
cloud-init init        || true
cloud-init modules --mode=config || true
cloud-init modules --mode=final  || true

echo "[$(date -Is)] cloud-init bootstrap finished."
date -Is > "$SENTINEL"
