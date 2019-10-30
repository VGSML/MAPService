FROM ubuntu:bionic

# Style dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    git ca-certificates curl gnupg postgresql-client python fonts-hanazono \
    fonts-noto-cjk fonts-noto-hinted fonts-noto-unhinted mapnik-utils \
    nodejs npm ttf-unifont unzip && rm -rf /var/lib/apt/lists/*

# Kosmtik with plugins, forcing prefix to /usr because bionic sets
# npm prefix to /usr/local, which breaks the install
#RUN npm set prefix /usr && npm install -g kosmtik
RUN mkdir /src && \
    cd /src && \
    git clone https://github.com/kosmtik/kosmtik.git && \
    cd /src/kosmtik && \
    npm set prefix /usr && npm install -g

WORKDIR /usr/lib/node_modules/kosmtik/
RUN kosmtik plugins --install kosmtik-overpass-layer \
                    --install kosmtik-fetch-remote \
                    --install kosmtik-overlay \
                    --install kosmtik-open-in-josm \
                    --install kosmtik-map-compare \
                    --install kosmtik-osm-data-overlay \
                    --install kosmtik-mapnik-reference \
                    --install kosmtik-geojson-overlay \
    && cp /root/.config/kosmtik.yml /tmp/.kosmtik-config.yml
COPY localconfig.json /tmp/localconfig.json

# Closing section
RUN mkdir -p /data
WORKDIR /data

RUN mkdir -p /docker-entrypoint.d
ADD docker-entrypoint.sh /docker-entrypoint.d
ENTRYPOINT ["sh","/docker-entrypoint.d/docker-entrypoint.sh"]
