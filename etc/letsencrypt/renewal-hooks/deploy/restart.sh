#!/bin/bash

#　Restart the services that is using the certificate.

for service in \
    zentyal.webadmin-nginx.service \
    apache2.service \
    dovecot.service
do 
    systemctl -q restart $service
done

exit 0
