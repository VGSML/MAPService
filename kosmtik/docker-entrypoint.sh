#!/bin/sh

# Creating default Kosmtik settings file
if [ ! -e ".kosmtik-config.yml" ]; then
  cp /tmp/.kosmtik-config.yml .kosmtik-config.yml  
fi
export KOSMTIK_CONFIGPATH=".kosmtik-config.yml"

# copy localconfig.json to project dir

cp /tmp/localconfig.json "/data/${PROJECTDIR}/"

# Starting Kosmtik
exec kosmtik serve "/data/${PROJECTDIR}/project.mml" --localconfig "/data/${PROJECTDIR}/localconfig.json" --host 0.0.0.0
# It needs Ctrl+C to be interrupted
