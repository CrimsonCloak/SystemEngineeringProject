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
export readonly PROVISIONING_SCRIPTS="/vagrant/provisioning/"
# Location of files to be copied to this server
export readonly PROVISIONING_FILES="${PROVISIONING_SCRIPTS}/files/${HOSTNAME}"

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

cd /srv
wget https://github.com/lukevella/rallly/archive/refs/tags/v2.4.0.zip -O /srv/rallly.zip
dnf install -y unzip
unzip rallly.zip -d /srv
cd /srv/rallly-2.4.0/apps/web
curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
dnf install -y yarn
yarn
cp sample.env .env

sed -i 's/^DATABASE_URL=.*/DATABASE_URL=postgres:\/\/postgres:postgres@localhost:5432\/rallly/' .env
sed -i 's/^SECRET_PASSWORD=.*/SECRET_PASSWORD=azertyuiopqsdfghjklmwxcvbnazerty/' .env

dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
dnf install -y postgresql14-server
dnf install -y postgresql14-contrib
/usr/pgsql-14/bin/postgresql-14-setup initdb
systemctl start postgresql-14
systemctl enable postgresql-14

sudo -u postgres createdb rallly
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"

cd /srv/rallly-2.4.0
cp /srv/rallly-2.4.0/apps/web/.env .
cp .env packages/database/prisma
yarn prisma generate
yarn db:generate && yarn db:deploy

cd /srv/rallly-2.4.0/apps/web
yarn build

yarn global add pm2
/usr/local/bin/pm2 start yarn --interpreter bash --name Rallly -- start

firewall-cmd --add-port=3000/tcp --permanent
firewall-cmd --reload