#!/usr/bin/env bash

if [ ! -f "${KAPOW_HOME}/data/Configuration/roboserver.settings" ]; then
   # run ConfigureMC to get (most of) the data-folder created
   ${KAPOW_HOME}/bin/ConfigureRS 1> /dev/null 2>&1
   # then we can (re-)configure
   ${KAPOW_HOME}/jre/bin/java -jar /roboServerConfigurator.jar
fi

${KAPOW_HOME}/bin/RoboServer $@
