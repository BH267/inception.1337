#!/bin/bash
set -e

mkdir -p /var/run/vsftpd/empty

FTP_IP=${FTP_IP:-10.14.57.3}

cat > /etc/vsftpd.conf <<EOF
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
seccomp_sandbox=NO
pasv_enable=YES
pasv_min_port=21100
pasv_max_port=21110
pasv_address=${FTP_IP}
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
EOF

if [ ! -f "/run/secrets/db_password" ]; then
  echo "ERROR: /run/secrets/db_password not found!" >&2
  exit 1
fi

FTP_PASSWORD=$(cat /run/secrets/db_password)

if [ -z "$FTP_PASSWORD" ]; then
  echo "ERROR: Password is empty!" >&2
  exit 1
fi

# Set password for wpuser
echo "wpuser:${FTP_PASSWORD}" | chpasswd

# Verify user exists
if ! id wpuser &>/dev/null; then
    echo "ERROR: wpuser does not exist!" >&2
    exit 1
fi

# Verify password was set (test with getent)
if ! getent shadow wpuser | grep -q ':'; then
    echo "ERROR: wpuser shadow entry not found!" >&2
    exit 1
fi

mkdir -p /var/www/html
chown -R wpuser:wpuser /var/www/html
chmod 755 /var/www/html

echo "FTP user 'wpuser' configured successfully."
echo "Password set for wpuser."
echo "Starting vsftpd..."

exec /usr/sbin/vsftpd /etc/vsftpd.conf
