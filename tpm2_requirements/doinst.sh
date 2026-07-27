#!/bin/sh

# Ensure tss group exists
if ! getent group tss >/dev/null 2>&1; then
  echo "Creating group 'tss' (gid 374)..."
  groupadd -g 374 tss
fi

# Reload udev rules and trigger for existing TPM devices
if [ -x /sbin/udevadm ]; then
  /sbin/udevadm control --reload-rules 2>/dev/null || true
  /sbin/udevadm trigger --subsystem-match=tpm --subsystem-match=tpmrm 2>/dev/null || true
fi
