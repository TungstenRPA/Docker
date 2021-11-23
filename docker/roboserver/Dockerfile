FROM debian:stretch-slim

# preparing base environment
ENV KAPOW_HOME=/kapow LANG=en_US.UTF-8 TERM=xterm

RUN apt-get update \
 && apt-get --assume-yes install --no-install-recommends libx11-6 libxext6 libx11-6 ttf-dejavu-core gettext libc-bin libssl1.0.2 \
                                                         login procps gconf-service libasound2 libatk1.0-0 libc6 libcairo2 locales\
                                                         libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 \
                                                         libgdk-pixbuf2.0-0 libglib2.0-0 libgtk2.0-0 libnspr4 libnss3 libpango-1.0-0 \
                                                         libpangocairo-1.0-0 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 \
                                                         libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 xvfb dos2unix libgomp1 \
                                                         libatk-bridge2.0-0 libgbm1 curl \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p ${KAPOW_HOME}/lib/jdbc/ \
 && locale-gen en_US.UTF-8 \
 && localedef en_US.UTF-8 -i en_US -f UTF-8

# change this line to add the JDBC driver relevant to your setup
ADD https://jdbc.postgresql.org/download/postgresql-42.2.19.jar ${KAPOW_HOME}/lib/jdbc/

ADD jre ${KAPOW_HOME}/jre

ADD nativelib ${KAPOW_HOME}/nativelib

RUN find ${KAPOW_HOME}/nativelib -name 'chrome-sandbox' -exec chmod 4755 {} \; \
 && find ${KAPOW_HOME}/nativelib -name 'cef.cfg' -exec bash -c 'echo >> {}' \; \
 && find ${KAPOW_HOME}/nativelib -name 'cef.cfg' -exec bash -c 'echo chrome:no-sandbox=true >> {}' \;

ADD Resources ${KAPOW_HOME}/Resources
ADD bin ${KAPOW_HOME}/bin

COPY docker/roboserver/roboserver.sh ${KAPOW_HOME}/bin/.

ADD lib ${KAPOW_HOME}/lib

RUN dos2unix ${KAPOW_HOME}/bin/*.sh \
 && chmod +x ${KAPOW_HOME}/bin/* \
 && echo "wrapper.java.additional.22=-Dkapow.applicationDataFolder=%KAPOW_HOME%/data" >> ${KAPOW_HOME}/bin/common.conf

COPY docker/roboserver/roboServerConfigurator.jar /.

HEALTHCHECK --interval=30s --timeout=30s --retries=3 --start-period=180s CMD ${KAPOW_HOME}/jre/bin/java -cp /roboServerConfigurator.jar com.kapowtech.healthcheck.RoboServerHealthCheck

CMD [ "sh", "-c", "${KAPOW_HOME}/bin/roboserver.sh"]
