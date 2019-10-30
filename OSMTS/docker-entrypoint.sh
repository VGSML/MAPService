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

echo "Searching new configuration file ..."

cp /etc/apache2/sites-available/000-default.conf "/data/${CONFIGDIR}/current/apache.conf"
if [ -f "/data/${CONFIGDIR}/apache.conf" ]; then
    echo "Load new apache config"
    cp "/data/${CONFIGDIR}/apache.conf" /etc/apache2/sites-available/000-default.conf
    mv "/data/${CONFIGDIR}/apache.conf" "/data/${CONFIGDIR}/current/apache.conf"
fi
cp /etc/apache2/conf-available/security.conf "/data/${CONFIGDIR}/current/security.conf"
if [ -f "/data/${CONFIGDIR}/security.conf" ]; then
    echo "Load new style apache security config"
    cp "/data/${CONFIGDIR}/current/security.conf" /etc/apache2/conf-available/security.conf
    mv "/data/${CONFIGDIR}/current/security.conf" "/data/${CONFIGDIR}/current/security.conf"
fi
cp /usr/local/etc/renderd.conf "/data/${CONFIGDIR}/current/renderd.conf"
if [ -f "/data/${CONFIGDIR}/renderd.conf" ]; then
    echo "Load new render config"
    cp "/data/${CONFIGDIR}/renderd.conf" /usr/local/etc/renderd.conf
    mv "/data/${CONFIGDIR}/renderd.conf" "/data/${CONFIGDIR}/current/renderd.conf"
fi
cp -R /src/openstreetmap-carto/ "/data/${CONFIGDIR}/Stylesheet/current/"

if [ -f "/data/${CONFIGDIR}/project.mml" ]; then
    echo "Load new style project.mml config"
    cp "/data/${CONFIGDIR}/project.mml" /src/openstreetmap-carto/project.mml
    for ss_file in `find "/data/${CONFIGDIR}/Stylesheet/" -type f`
    do
        echo "Copy ss file: ${ss_file}"
        cp "${ss_file}" /src/openstreetmap-carto/
        mv "${ss_file}" "/data/${CONFIGDIR}/Stylesheet/current/"
    done
    carto /src/openstreetmap-carto/project.mml > /src/openstreetmap-carto/mapnik.xml
    cp -R /src/openstreetmap-carto/ "/data/${CONFIGDIR}/Stylesheet/current/"
    mv "/data/${CONFIGDIR}/project.mml" "/data/${CONFIGDIR}/current/project.mml"
fi
# copy style_dev carto files if does not exists
if [ ! -d "/data/${STYLE_DEV}" ]; then
    cp -R /src/openstreetmap-carto/ "/data/${STYLE_DEV}/"
    mkdir "/data/${STYLE_DEV}/mod_tile"
fi


echo "Reload apache configuration"
service apache2 reload
service apache2 reload

service apache2 start
exec renderd -f -c /usr/local/etc/renderd.conf 