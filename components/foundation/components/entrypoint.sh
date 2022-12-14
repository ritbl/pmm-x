#!/bin/bash
set -o errexit

# init /srv if empty
DIST_FILE=/srv/pmm-distribution
if [ ! -f $DIST_FILE ]; then
    echo "File $DIST_FILE doesn't exist. Initizlize /srv..."
    echo docker > $DIST_FILE
    mkdir -p /srv/{clickhouse,grafana,logs,postgres14,prometheus,nginx,victoriametrics,alertmanager}
    echo "Copy plugins and VERSION file"
    cp /usr/share/percona-dashboards/VERSION /srv/grafana/PERCONA_DASHBOARDS_VERSION
    cp -r /usr/share/percona-dashboards/panels/ /srv/grafana/plugins
    chown -R grafana:grafana /srv/grafana
    chown pmm:pmm /srv/{victoriametrics,prometheus,logs,alertmanager}
    chown postgres:postgres /srv/postgres14
    echo "Init Postgres"
    su postgres -c "/usr/lib/postgresql/14/bin/initdb -D /srv/postgres14"
    echo "Temporary start postgres and enable pg_stat_statements"
    su postgres -c "/usr/lib/postgresql/14/bin/pg_ctl start -D /srv/postgres14"
    su postgres -c "psql postgres postgres -c 'CREATE EXTENSION pg_stat_statements SCHEMA public'"
    su postgres -c "/usr/lib/postgresql/14/bin/pg_ctl stop -D /srv/postgres14"
    /dev-setup.sh
fi

exec /usr/bin/supervisord -n -c /etc/supervisord.conf
