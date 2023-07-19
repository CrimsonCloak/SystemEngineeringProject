#! /bin/bash
#
# Provisioning script for theoracle

#------------------------------------------------------------------------------
# Bash settings
#------------------------------------------------------------------------------

# Enable "Bash strict mode"
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't mask errors in piped commands

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------

# Location of provisioning scripts and files
readonly PROVISIONING_SCRIPTS="/vagrant/provisioning/"
# Location of files to be copied to this server
readonly PROVISIONING_FILES="${PROVISIONING_SCRIPTS}/files/${HOSTNAME}"

#------------------------------------------------------------------------------
# "Imports"
#------------------------------------------------------------------------------

# Actions/settings common to all servers
source ${PROVISIONING_SCRIPTS}/common.sh

#------------------------------------------------------------------------------
# Provision server
#------------------------------------------------------------------------------
#https://www.informaticar.net/install-matrix-synapse-on-centos-8/
#https://matrix-org.github.io/synapse/latest/setup/installation.html#installing-as-a-python-module-from-pypi



log "Starting server specific provisioning tasks on ${HOSTNAME}"

dnf install -y tftp-server tftp
cp /usr/lib/systemd/system/tftp.service /etc/systemd/system/tftp-server.service
cp /usr/lib/systemd/system/tftp.socket /etc/systemd/system/tftp-server.socket

cp "${PROVISIONING_FILES}"/tftp-server.service /etc/systemd/system/tftp-server.service
systemctl daemon-reload
systemctl enable tftp-server
systemctl start tftp-server

chmod 777 /var/lib/tftpboot

firewall-cmd --add-service=tftp --permanent
firewall-cmd --reload