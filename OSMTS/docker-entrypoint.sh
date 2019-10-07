#!/bin/sh
echo "Initializing osmts ..."

echo "Searching files for upload in mapdb in /data/${OSM_IMPORTDIR}/IMPORT ..."
for FILE_UPLOAD in `find "/data/${OSM_IMPORTDIR}/IMPORT/" -type f`
do
    echo "load file ${FILE_UPLOAD}"
    echo "${FILE_UPLOAD} -C ${IMPORT_RAM_CACHE} ${IMPORT_PROCESS_NUM}" 
    export PGPASS=$POSTGRES_PASSWORD
    export PGPASSWORD=$POSTGRES_PASSWORD
    # If first load or need recreated DB looking .initialized file in OSM_IMPORTDIR
    if [ ! -f "/data/${OSM_IMPORTDIR}/.initialized" ]; then
        osm2pgsql -d "${POSTGRES_DB}" --create --slim -H mapdb -U "${POSTGRES_USER}" -G --hstore --tag-transform-script /src/openstreetmap-carto/openstreetmap-carto.lua -C  $IMPORT_RAM_CACHE --number-process $IMPORT_PROCESS_NUM -S /src/openstreetmap-carto/openstreetmap-carto.style "${FILE_UPLOAD}"
        echo "File init ${FILE_UPLOAD}"  > /data/${OSM_IMPORTDIR}/.initialized
    else
        osm2pgsql -d "${POSTGRES_DB}" --append --slim -H mapdb -U "${POSTGRES_USER}" -G --hstore --tag-transform-script /src/openstreetmap-carto/openstreetmap-carto.lua -C  $IMPORT_RAM_CACHE --number-process $IMPORT_PROCESS_NUM -S /src/openstreetmap-carto/openstreetmap-carto.style "${FILE_UPLOAD}"
    fi
    mv "${FILE_UPLOAD}" "/data/${OSM_IMPORTDIR}/UPLOAD/"
done
echo "Reload apache configuration"
service apache2 reload
service apache2 reload

service apache2 start
exec renderd -f -c /usr/local/etc/renderd.conf 