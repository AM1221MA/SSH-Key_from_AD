#!/bin/bash
USERNAME=$1
SAMACCOUNTNAME=$(echo "$USERNAME" | cut -d@ -f1)
USER_HOME=$(getent passwd "$USERNAME" | cut -d: -f6)
SSH_DIR="$USER_HOME/.ssh"
AUTH_KEYS="$SSH_DIR/authorized_keys"
LOGS="/tmp/ssh_key_debug.log"
echo "$USERNAME"
echo "$SAMMACOUNTNAME"
echo "$SSH_DIR"
echo "[$(date)] USERNAME=$USERNAME" >> "$LOGS"
echo "SAMACCOUNTNAME=$SAMACCOUNTNAME" >> "$LOGS"
echo "USER_HOME=$USER_HOME" >> "$LOGS"
# Si ya tiene la llave guardada localmente, usar esa
if [[ -f "$AUTH_KEYS" ]]; then
    tail -n 1 "$AUTH_KEYS"
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
    -b "$BASE_DN" "(sAMAccountName=$SAMACCOUNTNAME)" altSecurityIdentities 2>>"$LOGS" | \
    grep '^altSecurityIdentities: SSHKey:' | sed 's/^altSecurityIdentities: SSHKey://')
echo "$KEY" >> "$LOGS"
# Crear .ssh y guardar la llave
if [[ ! -d "$SSH_DIR" ]]; then
    mkdir -p "$SSH_DIR"
    chown "$USERNAME": "$SSH_DIR"
    chmod 700 "$SSH_DIR"
fi
echo "$KEY" > "$AUTH_KEYS"
chown "$USERNAME": "$AUTH_KEYS"
chmod 600 "$AUTH_KEYS"
chown "$USERNAME": "$USER_HOME"
chmod 700 "$USER_HOME"
# Mostrar la llave como salida
echo "$KEY"
chmod 700 "$LOGS"
