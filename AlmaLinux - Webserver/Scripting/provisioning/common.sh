#! /bin/bash
#
# Provisioning script common for all servers

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
# TODO: put all variable definitions here. Tip: make them readonly if possible.

# Set to 'yes' if debug messages should be printed.
readonly debug_output='yes'

#------------------------------------------------------------------------------
# Helper functions
#------------------------------------------------------------------------------
# Three levels of logging are provided: log (for messages you always want to
# see), debug (for debug output that you only want to see if specified), and
# error (obviously, for error messages).

# Usage: log [ARG]...
#
# Prints all arguments on the standard error stream
log() {
  printf '\e[0;33m[LOG]  %s\e[0m\n' "${*}"
}

# Usage: debug [ARG]...
#
# Prints all arguments on the standard error stream
debug() {
  if [ "${debug_output}" = 'yes' ]; then
    printf '\e[0;36m[DBG] %s\e[0m\n' "${*}"
  fi
}

# Usage: error [ARG]...
#
# Prints all arguments on the standard error stream
error() {
  printf '\e[0;31m[ERR] %s\e[0m\n' "${*}" 1>&2
}

#------------------------------------------------------------------------------
# Provisioning tasks
#------------------------------------------------------------------------------

log '=== Starting common provisioning tasks ==='

# TODO: insert common provisioning code here, e.g. install EPEL repository, add
# users, enable SELinux, etc.

log "Ensuring SELinux is active"

if [ "$(getenforce)" != 'Enforcing' ]; then
    # Enable SELinux now
    setenforce 1

    # Change the config file
    sed -i 's/SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
fi

log "Installing useful packages"

dnf install -y \
    bind-utils \
    cockpit \
    nano \
    tree

log "Enabling essential services"

systemctl enable --now firewalld.service
systemctl enable --now cockpit.socket
