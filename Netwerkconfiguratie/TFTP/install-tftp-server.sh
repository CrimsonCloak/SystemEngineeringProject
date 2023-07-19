#!/bin/bash
apt-get install xinetd tftpd tftp
touch /etc/xinetd.d/tftp
echo '
service tftp
{
protocol        = udp
port            = 69
socket_type     = dgram
wait            = yes
user            = nobody
server          = /usr/sbin/in.tftpd
server_args     = /tftpboot
disable         = no
}' >> /etc/xinetd.d/tftp
#homemap van tftp
mkdir /tftpboot
chmod -R 777 /tftpboot
chown -R nobody /tftpboot

service xinetd restart

#testen of het werkt
#tftp <ip-address>
#get test (een bestand met naam test moet in /tftpboot staan)
#Sent X bytes in X secods <- werkt