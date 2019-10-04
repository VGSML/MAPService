#!/bin/sh
if [ ! -f .initialized ]; then
    echo "Initializing osmts"
    echo "-d ${POSTGRES_DB} --create --slim -G --hstore -H mapdb -U ${POSTGRES_USER} -W ${POSTGRES_PASSWORD}" 
    export PGPASS=$POSTGRES_PASSWORD
    exec osm2pgsql -d "${POSTGRES_DB}" --create --slim -G --hstore -H mapdb -U "${POSTGRES_USER}" -W "${POSTGRES_PASSWORD}" \
              --tag-transform-script /src/openstreetmap-carto/openstreetmap-carto.lua \ 
              -C  $IMPORT_RAM_CACHE --number-process $IMPORT_PROCESS_NUM \
              -S /src/openstreetmap-carto/openstreetmap-carto.style /data/$OSM_IMPORTFILE
    exec /src/openstreetmap-carto/scripts/get-shapefiles.py
    exec cp /usr/local/etc/renderd.conf /data/ 
    exec cp /src/openstreetmap-carto/mapnik.xml /data/ 
    #cp /etc/apache2/conf-available/mod_tile.conf /data/ && \
    exec cp /etc/apache2/sites-available/000-default.conf /data
    touch .initialized
fi

exec "@"