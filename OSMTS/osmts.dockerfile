# Create image for openstreetmap tile server, connect to postgis and load osmmap via osm2pgsql
FROM ubuntu:18.04
LABEL name="osmts"
LABEL version="0.1"
# Install dependencies for map tile server
RUN apt-get update && \
    apt-get install -y \
                    libboost-all-dev git-core tar unzip wget bzip2 build-essential \
                    autoconf libtool libxml2-dev libgeos-dev libgeos++-dev libpq-dev \
                    libbz2-dev libproj-dev munin-node munin libprotobuf-c0-dev \
                    protobuf-c-compiler libfreetype6-dev libtiff5-dev libicu-dev \
                    libgdal-dev libcairo-dev libcairomm-1.0-dev apache2 apache2-dev \
                    libagg-dev liblua5.2-dev ttf-unifont lua5.1 liblua5.1-dev libgeotiff-epsg \
                    curl
# install build  osm2pgsql prerequisites
RUN apt-get install -y \
                    make cmake g++ libboost-dev libboost-system-dev libboost-filesystem-dev \
                    libexpat1-dev zlib1g-dev libbz2-dev libpq-dev libgeos-dev libgeos++-dev \
                    libproj-dev lua5.2 liblua5.2-dev

# install osm2pgsql
# load source code 
RUN mkdir /src && cd /src && \
        git clone git://github.com/openstreetmap/osm2pgsql.git && \
        cd osm2pgsql \
    && \
# build
    mkdir build && cd build && cmake .. && \ 
    make && \
    make install 

# install Mapnik
RUN apt-get install -y \
                    autoconf apache2-dev libtool libxml2-dev libbz2-dev libgeos-dev \
                    libgeos++-dev libproj-dev gdal-bin libmapnik-dev mapnik-utils python-mapnik

RUN cd /src && \ 
    git clone -b switch2osm git://github.com/SomeoneElseOSM/mod_tile.git && \
    cd mod_tile && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    make install-mod_tile && \
    ldconfig

# install carto (Stylesheet configuration)
RUN apt-get install -y npm nodejs
RUN cd /src && \
    git clone git://github.com/gravitystorm/openstreetmap-carto.git && \
    cd openstreetmap-carto && \
    npm install -g carto && \
    carto project.mml > mapnik.xml

# loading data into OSMDB
RUN mkdir -p /data
#VOLUME [ "/data" ]

# download shapefile
#RUN /src/openstreetmap-carto/scripts/get-shapefiles.py
RUN apt-get install -y fonts-noto-cjk fonts-noto-hinted fonts-noto-unhinted ttf-unifont

RUN mkdir -p /docker-entrypoint.d
ADD docker-entrypoint.sh /docker-entrypoint.d
ENTRYPOINT ["sh","/docker-entrypoint.d/docker-entrypoint.sh"]










