#!/bin/bash
set -o errexit

# allow external PG
sed -i -e "s/#listen_addresses = \'localhost\'/listen_addresses = \'*\'/" /srv/postgres14/postgresql.conf
echo 'host    all         all     0.0.0.0/0     trust' >> /srv/postgres14/pg_hba.conf
supervisorctl restart postgresql
