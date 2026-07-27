#!/bin/bash
# OpenVPN wrapper — adds PKCS#11 options when launched by NetworkManager
# for connections whose name contains "tpm".
#
# Loads tpm2-pkcs11.so directly via OpenSSL 3.x provider config.
# Installed as /usr/sbin/openvpn, real binary is /usr/sbin/openvpn-real.
# Debug log: /tmp/openvpn-wrapper.log
# OpenSSL config for TPM: /etc/ssl/openssl_tpm.cnf

REAL=/usr/sbin/openvpn-real
LOG=/tmp/openvpn-wrapper.log
TPM_OPENSSL_CONF=/etc/ssl/openssl_tpm.cnf

log() { printf '%s  %s\n' "$(date '+%H:%M:%S')" "$*" >>"$LOG"; }

log "=== WRAPPER START ==="
log "args: $*"

# If --pkcs11-providers is already present, pass through unchanged
for arg in "$@"; do
  [ "$arg" = "--pkcs11-providers" ] && { log "pkcs11 already present, pass-through"; exec "$REAL" "$@"; }
done

# Extract connection UUID from management socket path
# NM passes: --management /var/run/NetworkManager/nm-openvpn-<UUID> unix
uuid=
for arg in "$@"; do
  case "$arg" in
    *nm-openvpn-*)
      uuid=$(printf '%s' "$arg" | grep -oE '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')
      log "found uuid=$uuid from arg=$arg"
      [ -n "$uuid" ] && break
      ;;
  esac
done

# Determine REAL_USER / REAL_HOME
REAL_USER=
REAL_HOME=

if [ -n "$uuid" ] && command -v nmcli >/dev/null; then
  conn_name=$(nmcli -t -f connection.id connection show "$uuid" 2>/dev/null)
  conn_name="${conn_name#connection.id:}"
  log "conn_name=$conn_name"
  case "$conn_name" in
    *tpm*|*TPM*)
      conn_perms=$(nmcli -t -f connection.permissions connection show "$uuid" 2>/dev/null)
      log "conn_perms=$conn_perms"
      case "${conn_perms#connection.permissions:}" in
        user:*) REAL_USER="${conn_perms#connection.permissions:user:}"; REAL_USER="${REAL_USER%:}" ;;
      esac

      [ -z "$REAL_USER" ] && REAL_USER=${SUDO_USER:-$(logname 2>/dev/null || echo root)}
      log "REAL_USER=$REAL_USER"

      REAL_HOME=$(getent passwd "$REAL_USER" 2>/dev/null | awk -F: '{print $6}')

      if [ -z "$REAL_HOME" ] || [ ! -f "$REAL_HOME/.config/vpn/pin" ]; then
        log "scanning /home/* for config..."
        for d in /home/*; do
          [ -f "$d/.config/vpn/pin" ] || continue
          REAL_HOME="$d"
          REAL_USER=$(basename "$d")
          log "  found at $REAL_HOME (user=$REAL_USER)"
          break
        done
      fi

      [ -n "$REAL_HOME" ] && export TPM2_PKCS11_STORE="${REAL_HOME}/.local/share/tpm2-pkcs11"
      log "TPM2_PKCS11_STORE=$TPM2_PKCS11_STORE"

      PIN_FILE="${REAL_HOME}/.config/vpn/pin"
      PIN=
      [ -r "$PIN_FILE" ] && PIN="$(head -1 "$PIN_FILE")" && log "PIN_OK=true"

      PKCS11_ID_FILE="${REAL_HOME}/.config/vpn/pkcs11-id"
      PKCS11_ID=
      [ -r "$PKCS11_ID_FILE" ] && PKCS11_ID=$(head -1 "$PKCS11_ID_FILE") && PKCS11_ID="${PKCS11_ID#"${PKCS11_ID%%[![:space:]]*}"}" && log "PKCS11_ID=$PKCS11_ID"

      # Read pkcs11 URI from config
      PKCS11_URI_FILE="${REAL_HOME}/.config/vpn/pkcs11-uri"
      PKCS11_URI=
      [ -r "$PKCS11_URI_FILE" ] && PKCS11_URI="$(head -1 "$PKCS11_URI_FILE")" && log "PKCS11_URI=$PKCS11_URI"

      [ -n "$PIN" ] && PKCS11_URI="${PKCS11_URI};pin-value=${PIN}" && log "PKCS11_URI (with pin)=${PKCS11_URI%%pin-value=*}pin-value=***"

      # Build final args: replace --key with pkcs11 URI, skip --pkcs11-*,
      # skip --pkcs11-providers (not used), skip --cert (we keep it),
      # skip --verb (overridden)
      filtered=()
      skip_next=false

      for arg in "$@"; do
        $skip_next && { skip_next=false; continue; }

        case "$arg" in
          --cert|--ca)
            # Keep --cert and --ca as-is (they reference temp files from NM)
            filtered+=("$arg")
            ;;
          --key)
            # Skip the original --key <file>, will add pkcs11 URI instead
            skip_next=true
            log "  skip --key (replacing with pkcs11 URI)"
            ;;
          --verb|--user|--group)
            skip_next=true
            log "  skip $arg and its value"
            ;;
          --pkcs11-*)
            skip_next=true
            log "  skip $arg (using OpenSSL provider config instead)"
            ;;
          *)
            filtered+=("$arg")
            ;;
        esac
      done

      # Prepend TPM2 PKCS#11 options and the pkcs11 URI as --key
      pkcs11_opts=(
        --resolv-retry infinite
        --verb 3
        --tls-version-min 1.2
        --tls-version-max 1.2
        --key "$PKCS11_URI"
      )

      log "OPENSSL_CONF=$TPM_OPENSSL_CONF"
      log "exec $REAL ${pkcs11_opts[*]} ${filtered[*]}"
      export OPENSSL_CONF="$TPM_OPENSSL_CONF"
      exec "$REAL" "${pkcs11_opts[@]}" "${filtered[@]}"
      ;;
  esac
fi

log "pass-through (no TPM connection)"
exec "$REAL" "$@"
