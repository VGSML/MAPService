#!/bin/sh
if [ ! -f /data/.initialized ]; then
    echo "Initializing osmts"
    #touch /data/.initialized
    echo "/data/${OSM_IMPORTFILE} -C ${IMPORT_RAM_CACHE} ${IMPORT_PROCESS_NUM}" 
    export PGPASS=$POSTGRES_PASSWORD
    export PGPASSWORD=$POSTGRES_PASSWORD
    #mkdir ~/data
    #cd /data
    #wget http://download.geofabrik.de/asia/azerbaijan-latest.osm.pbf
    osm2pgsql -d "${POSTGRES_DB}" --create --slim -H mapdb -U "${POSTGRES_USER}" -G --hstore --tag-transform-script /src/openstreetmap-carto/openstreetmap-carto.lua -C  $IMPORT_RAM_CACHE --number-process $IMPORT_PROCESS_NUM -S /src/openstreetmap-carto/openstreetmap-carto.style "/data/${OSM_IMPORTFILE}"
    echo "Shape file download"
    /src/openstreetmap-carto/scripts/get-shapefiles.py
    echo "Configure appach"
    mkdir /var/lib/mod_tile
    mkdir /var/run/renderd
    echo "LoadModule tile_module /usr/lib/apache2/modules/mod_tile.so" > /etc/apache2/conf-available/mod_tile.conf
    cp /data/apache_cfg.conf /etc/apache2/sites-available/000-default.conf
    cp /data/renderd_cfg.conf /usr/local/etc/renderd.conf
    a2enconf mod_tile
    echo "copy file to /data volume"
    cp /usr/local/etc/renderd.conf /data
    cp /src/openstreetmap-carto/mapnik.xml /data
    cp /etc/apache2/conf-available/mod_tile.conf /data/
    cp /etc/apache2/sites-available/000-default.conf /data
    service apache2 reload
    service apache2 reload
    echo "ok" > /data/.initialized
    renderd -f -c /usr/local/etc/renderd.conf
    cp /src/mod_tile/debian/renderd.init /etc/init.d/renderd
    cp /src/mod_tile/debian/renderd.service /lib/systemd/system/
    systemctl enable renderd
    #exit 'ok'
fi

exec apachectl -D FOREGROUND