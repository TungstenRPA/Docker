FROM tomcat:8.5.66-jdk11-adoptopenjdk-hotspot

# preparing base environment
ENV KAPOW_HOME=/kapow LANG=en_US.UTF-8 TERM=xterm

RUN apt-get update \
 && apt-get --assume-yes install --no-install-recommends dos2unix locales zip \
 && rm -rf /var/lib/apt/lists/* \
 && locale-gen en_US.UTF-8 \
 && localedef en_US.UTF-8 -i en_US -f UTF-8

RUN rm -rf /usr/local/tomcat/webapps/ROOT \
 && mkdir -p /usr/local/tomcat/conf/Catalina/localhost \
 && mkdir -p /usr/local/tomcat/lib/jdbc \
 && mkdir -p ${KAPOW_HOME}/backup

# change this line to add the JDBC driver relevant to your setup
ADD https://jdbc.postgresql.org/download/postgresql-42.2.19.jar /usr/local/tomcat/lib/jdbc/

RUN echo "common.loader=\"$\{catalina.base\}/lib\",\"$\{catalina.base\}/lib/*.jar\",\"$\{catalina.home\}/lib\",\
        \"$\{catalina.home\}/lib/*.jar\", \"$\{catalina.home\}/lib/jdbc/*.jar\"" >> /usr/local/tomcat/conf/catalina.properties

COPY docker/managementconsole/*.sh /usr/local/tomcat/bin/
COPY docker/managementconsole/backup/ ${KAPOW_HOME}/backup/

RUN dos2unix /usr/local/tomcat/bin/*.sh \
 && chmod +x /usr/local/tomcat/bin/*.sh

COPY WebApps/Configurator.jar /managementConsoleConfigurator.jar

COPY WebApps/ManagementConsole.war /usr/local/tomcat/webapps/ROOT.war

HEALTHCHECK --interval=30s --timeout=30s --retries=3 --start-period=180s CMD curl --fail http://localhost:8080/Ping | grep "<string>application<\/string>" || exit 1

CMD ["managementconsole.sh", "run"]
