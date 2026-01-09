#!/bin/bash
set -e

KEY_DIR="/etc/ssh/keys"

if [ -f "$KEY_DIR/ssh_host_rsa_key" ]; then
    cp "$KEY_DIR"/ssh_host_* /etc/ssh/
else
    ssh-keygen -A
    mkdir -p "$KEY_DIR"
    cp /etc/ssh/ssh_host_* "$KEY_DIR/"
fi

exec /usr/sbin/sshd -D
