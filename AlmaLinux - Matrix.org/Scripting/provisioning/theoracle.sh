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

dnf install -y libtiff-devel libjpeg-devel freetype-devel libwebp-devel tk-devel redhat-rpm-config libffi-devel openssl-devel python3-devel
dnf groupinstall -y "Development Tools"

pip install --upgrade pip
pip install --upgrade setuptools
pip install matrix-synapse

log "Aanmaken van de map /srv/synapse"
mkdir /srv/synapse

cd /srv/synapse
cp "${PROVISIONING_FILES}"/homeserver.yaml .
cp "${PROVISIONING_FILES}"/thematrix.eiland-x.be.crt .
cp "${PROVISIONING_FILES}"/thematrix.eiland-x.be.key .

log "Configureren homeserver.yaml"
#python -m synapse.app.homeserver --server-name theoracle.thematrix.local --config-path homeserver.yaml --report-stats=yes

log "firewall"
firewall-cmd --add-port=8448/tcp --permanent
firewall-cmd --add-port=443/tcp --permanent
firewall-cmd --reload

log "Start Synapse"
cp "${PROVISIONING_FILES}"/synapse.service /etc/systemd/system/synapse.service
systemctl daemon-reload
systemctl enable synapse
systemctl start synapse

log "Aanmaken users"
/usr/local/bin/register_new_matrix_user -c homeserver.yaml http://localhost:8008 -u ferre -p ferre -a
/usr/local/bin/register_new_matrix_user -c homeserver.yaml http://localhost:8008 -u joren -p joren -a
/usr/local/bin/register_new_matrix_user -c homeserver.yaml http://localhost:8008 -u quinten -p quinten -a
/usr/local/bin/register_new_matrix_user -c homeserver.yaml http://localhost:8008 -u alexander -p alexander -a
/usr/local/bin/register_new_matrix_user -c homeserver.yaml http://localhost:8008 -u lars -p lars -a

/usr/local/bin/register_new_matrix_user -c homeserver.yaml http://localhost:8008 -u uptime -p uptime -a


log "MONITORING"
useradd --no-create-home --shell /bin/false prometheus
log "Install Node_exporter"
cd /srv
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz -O nodeexp.tar.gz
tar -xvf nodeexp.tar.gz
mkdir node_exporter-files
mv node_exporter-1.5.0.linux-amd64 node_exporter-files
rm nodeexp.tar.gz

log "Start Node_exporter"
cp "${PROVISIONING_FILES}"/node_exporter.service /etc/systemd/system/node_exporter.service
cp /srv/node_exporter-files/node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin/

firewall-cmd --add-port=9100/tcp --permanent
firewall-cmd --reload

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

#/etc/rc6.d voor script in webserver, voor shutdown

#login token van uptime
#curl -XPOST -d '{"type": "m.login.password", "identifier": {"user": "uptime", "type": "m.id.user"}, "password": "uptime"}' "http://localhost:8008/_matrix/client/r0/login"