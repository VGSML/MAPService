#!/bin/sh
if [ ! -f /data/.initialized ]; then
    echo "Initializing osmts"
    #touch /data/.initialized
    echo "/data/${OSM_IMPORTFILE} -C ${IMPORT_RAM_CACHE} ${IMPORT_PROCESS_NUM}" 
    export PGPASS=$POSTGRES_PASSWORD
    export PGPASSWORD=$POSTGRES_PASSWORD
    exec osm2pgsql -d "${POSTGRES_DB}" --create --slim -G --hstore -H mapdb -U "${POSTGRES_USER}" \
              --tag-transform-script /src/openstreetmap-carto/openstreetmap-carto.lua \ 
              -C  $IMPORT_RAM_CACHE --number-process $IMPORT_PROCESS_NUM \
              -S default.style -r pbf "/data/${OSM_IMPORTFILE}"
    exec /src/openstreetmap-carto/scripts/get-shapefiles.py
    exec cp /usr/local/etc/renderd.conf /data
    exec cp /src/openstreetmap-carto/mapnik.xml /data
    exec cp /etc/apache2/conf-available/mod_tile.conf /data/
    exec cp /etc/apache2/sites-available/000-default.conf /data
    touch /data/.initialized
fi

#exec "@"