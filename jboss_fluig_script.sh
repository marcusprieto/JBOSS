#!/bin/bash

FLUIG_DIR=/opt/fluig/jboss
SYSTEMD_DIR=/etc/systemd/system

# Atualiza mirrors localmente
yum update

# Criando o grupo do Tomcat
groupadd jboss

# Criando usuario do tomcat e chrootando para um diretorio especifico
useradd -M -s /bin/nologin -g jboss -d $FLUIG_DIR jboss

# FLuig possui um versao personalizada do Jboss EAP empacotada juntamente 
# com a aplicacao

# Mudando as permissoes de arquivos e diretorios

chgrp -R jboss $FLUIG_DIR/
chmod g+rwx $FLUIG_DIR/
chown -R jboss: $FLUIG_DIR/

# Criando arquivo daemon de inicializacao do Jboss conforme os padroes do systemd
echo "
## JBoss Bootstrap Environment
## JBOSS_HOME: /opt/fluig/jboss
## JAVA: /opt/fluig/jdk-64/bin/java

[Service]
Type=idle
Environment=JAVA_HOME=/usr/lib/jvm/java JBOSS_HOME=/opt/fluig/jboss JAVA=/opt/fluig/jdk-64/bin/java JBOSS_LOG_DIR=/var/log/jboss "JAVA_OPTS=-XX:+UseCompressedOops -verbose:gc -Xloggc:"/opt/fluig/jboss/standalone/log/gc.log" -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=5 -XX:GCLogFileSize=3M -XX:-TraceClassUnloading -server  -Djboss.modules.system.pkgs= -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -Xms2g -Xmx4g -XX:MaxPermSize=512m -XX:+UseG1GC -Xloggc:gc.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:-TraceClassUnloading -Dfile.encoding=utf8 -Djsse.enableSNIExtension=false"

User=jboss
Group=jboss

ExecStart=/opt/fluig/jboss/bin/standalone.sh
TimeoutStartSec=600
TimeoutStopSec=600

[Install]
WantedBy=multi-user.target" > $SYSTEMD_DIR/jboss.service

# Criando as permissoes de execucao para o servico do jboss
chmod +x $SYSTEMD_DIR/jboss.service

# Reload nas daemons
## systemctl daemon-reload

# Iniciando jboss
systemctl start jboss.service

# Habilitando jboss 
## systemctl enable jboss.service
