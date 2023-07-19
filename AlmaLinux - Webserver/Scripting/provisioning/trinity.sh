#! /bin/bash
#
# Provisioning script for srv001

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
readonly db_root_password='test123'
readonly db_name='wordpress_db'
readonly db_user='wordpress_user'
readonly db_password='wwNogAanpassen'

function main {
  install_packages
  enable_selinux
  configuration
  start_services
  installerenEnConfigurerenVanRallly
  installeerMonitoringSoftware
}

function install_packages {
  log "---Installing packages---"
  dnf -y install epel-release
  dnf -y install audit bash-completion bind-utils cockpit git httpd mod_ssl python3-policycoreutils php php-mysqlnd pciutils psmisc tree mod_http2
  dnf -y install mariadb-server
  dnf -y install nginx

  wget https://nl-be.wordpress.org/latest-nl_BE.tar.gz
}

function enable_selinux {
  log "---Enable selinux if not active---"
  if [ "$(getenforce)" != 'Enforcihng' ]; then
    log "Enabling SELinux"
    # Enable SELinux right now
    setenforce 0
    # Make the change permanent
    sed -i 's/^SELINUX=[a-z]*$/SELINUX=enforcing/' /etc/selinux/config
  fi
}

function start_services {
  log "---Starting services---"
  log "1. Cockpit"
  systemctl enable --now auditd.service
  systemctl enable --now firewalld.service
  systemctl enable --now cockpit.socket
  firewall-cmd --add-service=cockpit
  firewall-cmd --add-service=cockpit --permanent

  log "2. http"
  systemctl enable httpd
  systemctl start httpd

  log "3. https"
  systemctl enable mariadb
  systemctl start mariadb

  log "4. nginx"
  systemctl enable nginx
  systemctl start nginx

  log "5. firewall"
  firewall-cmd --zone=public --add-service=http --permanent
  firewall-cmd --zone=public --add-service=https --permanent
  firewall-cmd --reload
}

function configuration {
  log "---Configuring the server---"
  #----------------VUL HIER JE PUBLIC KEY IN----------------
  echo '' >> /home/vagrant/.ssh/authorized_keys
  #---------------------------------------------------------
  semanage port -m -t http_port_t -p tcp 8000
  sed -i 's/Listen 80/Listen 0.0.0.0:8000/' /etc/httpd/conf/httpd.conf
  tar -xvf latest-nl_BE.tar.gz
  cp wordpress/wp-config-sample.php wordpress/wp-config.php

  log "1. Wordpress Config"
  sed -i 's/database_name_here/wordpress_db/' wordpress/wp-config.php
  sed -i 's/username_here/wordpress_user/' wordpress/wp-config.php
  sed -i 's/password_here/wwNogAanpassen/' wordpress/wp-config.php
  sed -i 's/localhost/localhost/' wordpress/wp-config.php
  sudo cp -R wordpress /var/www/html/
  sudo chown -R apache:apache /var/www/html/wordpress
  sudo chcon -t httpd_sys_rw_content_t /var/www/html/wordpress -R
  sudo chmod -Rf 775  /var/www/html
  sed -i '124s/.*/ /' /etc/httpd/conf/httpd.conf
  semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/html/wordpress(/.*)?"
  restorecon -Rv /var/www/html/wordpress
  echo 'Documentroot /var/www/html/wordpress' >> /etc/httpd/conf/httpd.conf

  #h2 - tells the Apache server to support the HTTP/2 protocol over SSL/TLS.
  #h2c - tells the Apache server to support HTTP/2 over TCP.
  #http/1.1 - tells ver to the server that if the client does not accept HTTP/2, then serve the request over the HTTP/1.1 protocol.
  echo 'Protocols h2 h2c http/1.1
  <IfModule mod_setenvif.c>
  SetEnvIf X-Forwarded-Proto "^https$" HTTPS
  </IfModule>' >> /etc/httpd/conf/httpd.conf

  rm -f /etc/httpd/conf.d/ssl.conf
  if is_mysql_root_password_empty; then
  mysql <<_EOF_
    SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${db_root_password}');
    DELETE FROM mysql.user WHERE User='';
    DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
    DROP DATABASE IF EXISTS test;
    DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
    FLUSH PRIVILEGES;
_EOF_
  fi

  log "2. SSH Config"
  sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
  sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config

  log "SSL Certificates"
  mkdir /etc/nginx/ssl/
  cp "${PROVISIONING_FILES}/thematrix.eiland-x.be.crt" /etc/nginx/ssl/server.crt
  cp "${PROVISIONING_FILES}/thematrix.eiland-x.be.key" /etc/nginx/ssl/server.key

  log "3. Creating database and user"
  systemctl start mariadb
  mysql --user=root --password="${db_root_password}" << _EOF_
  CREATE DATABASE IF NOT EXISTS ${db_name};
  GRANT ALL ON ${db_name}.* TO '${db_user}'@'%' IDENTIFIED BY '${db_password}';
  FLUSH PRIVILEGES;
_EOF_

  log "4. Nginx Config"
  rm -f /etc/nginx/nginx.conf
  cp "${PROVISIONING_FILES}/nginx.conf" /etc/nginx/nginx.conf

  cp "${PROVISIONING_FILES}/proxy.conf" /etc/nginx/proxy.conf

  mkdir /etc/nginx/selinux/
  touch /etc/nginx/selinux/nginxlocalconf.te
  touch /etc/nginx/selinux/policy.log
  log 'Policy 1 aanmaken'
  echo '
  module nginxlocalconf 1.0;
  require {
    type httpd_t;
    type var_t;
    type transproxy_port_t;
    class tcp_socket name_connect;
    class file { read getattr open };
  }' >> /etc/nginx/selinux/nginxlocalconf.te

  log 'Policy 2 aanmaken'
  echo '
  type=AVC msg=audit(1678359685.972:111): avc:  denied  { setrlimit } for  pid=3610 comm="nginx" scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:system_r:httpd_t:s0 tclass=process permissive=0
  type=AVC msg=audit(1678365482.185:339): avc:  denied  { name_connect } for  pid=953 comm="nginx" dest=3000 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:ntop_port_t:s0 tclass=tcp_socket permissive=0
  type=AVC msg=audit(1678365498.111:344): avc:  denied  { name_connect } for  pid=953 comm="nginx" dest=8000 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:http_port_t:s0 tclass=tcp_socket permissive=0
  ' >> /var/log/audit/audit.log

  log 'Policy 3 aanmaken'
  grep nginx /var/log/audit/audit.log | grep denied | \
  audit2allow -M nginxlocalconf

  log 'Policy 4 aanmaken'
  semodule -i nginxlocalconf.pp
}

function installerenEnConfigurerenVanRallly {
  log '---Rallly---'
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

  npm install pm2 -g
  /usr/local/bin/pm2 start yarn --interpreter bash --name Rallly -- start
  /usr/local/bin/pm2 startup
  /usr/local/bin/pm2 save

  #firewall-cmd --add-port=3000/tcp --permanent
  #firewall-cmd --reload
}

function installeerMonitoringSoftware {
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
}

main
