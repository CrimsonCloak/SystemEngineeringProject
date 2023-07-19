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

log "---Install Uptime Kuma---"
log "1. Install Tools"
log "Install Git"
dnf install -y git
log "Install nodejs 14+"
curl -sL https://rpm.nodesource.com/setup_18.x | bash -
dnf install -y nodejs
log "Install pm2"
npm install pm2 -g

log "2. Install Uptime Kuma"
git clone https://github.com/louislam/uptime-kuma.git /srv/uptime-kuma
cd /srv/uptime-kuma
npm run setup
cp -rf "${PROVISIONING_FILES}"/data /srv/uptime-kuma/
log "Start Uptime Kuma"
pm2 start server/server.js --name uptime-kuma
pm2 startup
pm2 save

log "---Fix Firewall---"
firewall-cmd --permanent --add-port=3001/tcp
firewall-cmd --reload

#https://github.com/louislam/uptime-kuma/wiki/Prometheus-Invagrant sstegration
#https://github.com/louislam/uptime-kuma/wiki/Reverse-Proxy

log "---Install Prometheus---"
log "1. Download Prometheus"
cd /srv
wget https://github.com/prometheus/prometheus/releases/download/v2.43.0/prometheus-2.43.0.linux-amd64.tar.gz -O prometheus.tar.gz
tar -xvf prometheus.tar.gz
mv prometheus-2.43.0.linux-amd64 prometheus-files
rm prometheus.tar.gz

log "2. Create Prometheus user and folders"
useradd --no-create-home --shell /bin/false prometheus
mkdir /etc/prometheus
mkdir /var/lib/prometheus
chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus

log "3. Copy Prometheus files"
cp /srv/prometheus-files/prometheus /usr/local/bin/
cp /srv/prometheus-files/promtool /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool

log "4. Copy console_libraries and consoles"
cp -r /srv/prometheus-files/consoles /etc/prometheus
cp -r /srv/prometheus-files/console_libraries /etc/prometheus
chown -R prometheus:prometheus /etc/prometheus/consoles
chown -R prometheus:prometheus /etc/prometheus/console_libraries

log "5. Copy prometheus.yml"
cp "${PROVISIONING_FILES}"/prometheus.yml /etc/prometheus/prometheus.yml
chown prometheus:prometheus /etc/prometheus/prometheus.yml

log "6. Copy prometheus.service"
cp "${PROVISIONING_FILES}"/prometheus.service /etc/systemd/system/prometheus.service

log "7. Start Prometheus"
systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus

log "---Fix Firewall---"
firewall-cmd --permanent --add-port=9000/tcp
firewall-cmd --reload

log "---Install Grafana---"
log "1. Download Grafana"
dnf install -y https://dl.grafana.com/enterprise/release/grafana-enterprise-9.4.7-1.x86_64.rpm
cp "${PROVISIONING_FILES}"/grafana.ini /etc/grafana/grafana.ini

log "2. Start Grafana"
systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server

log "---Fix Firewall---"
firewall-cmd --permanent --add-port=3000/tcp
firewall-cmd --reload

log "---Install Node_exporter---"
log "1. Install Node_exporter"
cd /srv
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz -O nodeexp.tar.gz
tar -xvf nodeexp.tar.gz
mkdir node_exporter-files
mv node_exporter-1.5.0.linux-amd64 node_exporter-files
rm nodeexp.tar.gz

log "2. Start Node_exporter"
cp "${PROVISIONING_FILES}"/node_exporter.service /etc/systemd/system/node_exporter.service
cp /srv/node_exporter-files/node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin/
systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

log "3. Add Dashboards and datasources"
cp "${PROVISIONING_FILES}"/prometheus.yaml /etc/grafana/provisioning/datasources
cp "${PROVISIONING_FILES}"/node_exporter.json /etc/grafana/provisioning/dashboards
cp "${PROVISIONING_FILES}"/uptime_kuma.json /etc/grafana/provisioning/dashboards
cp "${PROVISIONING_FILES}"/windows_stats.json /etc/grafana/provisioning/dashboards
cp "${PROVISIONING_FILES}"/home.json /etc/grafana/provisioning/dashboards
cp "${PROVISIONING_FILES}"/dashboards.yaml /etc/grafana/provisioning/dashboards

log "4. Installing Alertmanager and Adding Alerts"
wget https://github.com/prometheus/alertmanager/releases/download/v0.25.0/alertmanager-0.25.0.linux-amd64.tar.gz
tar -xvf alertmanager-0.25.0.linux-amd64.tar.gz
mv alertmanager-0.25.0.linux-amd64 alertmanager-files
rm alertmanager-0.25.0.linux-amd64.tar.gz

mkdir /etc/alertmanager
mkdir /var/lib/alertmanager
chown root:root /etc/alertmanager
chown root:root /var/lib/alertmanager

cp -r /srv/alertmanager-files/alertmanager /usr/local/bin/
cp /srv/alertmanager-files/amtool /usr/local/bin/
cp "${PROVISIONING_FILES}"/alertmanager.service /etc/systemd/system/alertmanager.service
cp "${PROVISIONING_FILES}"/alerts.yml /etc/prometheus/alerts.yml
cp "${PROVISIONING_FILES}"/alertmanager.yml /etc/alertmanager.yml

systemctl daemon-reload
systemctl enable alertmanager
systemctl start alertmanager

log "5. Restart Grafana & Prometheus"
systemctl restart grafana-server
systemctl restart prometheus