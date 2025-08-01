#!/bin/bash
USERNAME=$1
SAMACCOUNTNAME=$(echo "$USERNAME" | cut -d@ -f1)
USER_HOME=$(getent passwd "$USERNAME" | cut -d: -f6)
SSH_DIR="$USER_HOME/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"
LOG="/tmp/ssh_key_debug.log"
echo "$USERNAME"
echo "$SAMMACOUNTNAME"
echo "$SSH_DIR"
echo "[$(date)] USERNAME=$USERNAME" >> "$LOG"
echo "SAMACCOUNTNAME=$SAMACCOUNTNAME" >> "$LOG"
echo "USER_HOME=$USER_HOME" >> "$LOG"
# Si ya tiene la llave guardada localmente, usar esa
if [[ -f "$AUTHORIZED_KEYS" ]]; then
    tail -n 1 "$AUTHORIZED_KEYS"
    exit 0
fi
# Si no, buscarla en AD
LDAP_URI="ldap://some.com"
BASE_DN="dc=some,dc=com"
BIND_DN="jhon@some.com"
BIND_PW=$(cat /etc/ssh/ldap_bind_pw)
KEY=$(ldapsearch -x -o ldif-wrap=no \
    -H "$LDAP_URI" \
    -D "$BIND_DN" -w "$BIND_PW" \
    -b "$BASE_DN" "(sAMAccountName=$SAMACCOUNTNAME)" altSecurityIdentities 2>>"$LOG" | \
    grep '^altSecurityIdentities: SSHKey:' | sed 's/^altSecurityIdentities: SSHKey://')
echo "$KEY" >> "$LOG"
# Crear .ssh y guardar la llave
if [[ ! -d "$SSH_DIR" ]]; then
    mkdir -p "$SSH_DIR"
    chown "$USERNAME": "$SSH_DIR"
    chmod 700 "$SSH_DIR"
fi
echo "$KEY" > "$AUTHORIZED_KEYS"
chown "$USERNAME": "$AUTHORIZED_KEYS"
chmod 600 "$AUTHORIZED_KEYS"
chown "$USERNAME": "$USER_HOME"
chmod 700 "$USER_HOME"
# Mostrar la llave como salida
echo "$KEY"
chmod 700 "$LOG"
