# create postgre with postgis extensions, create database, user for osmdb
FROM postgres:10.10
ENV PG_MAJOR 10
ENV POSTGIS_MAJOR 2.4
# Update repository and install postgis
RUN apt-get update \
#        && apt-chache showpkg postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
        && apt-get install -y --no-install-recommends \
                                postgis \ 
                                postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
                                postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts
RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/

# copy postgress configuration file
COPY postgresql.conf /var/lib/postgresql/data/

