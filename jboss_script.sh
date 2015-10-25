#!/bin/bash

#JBOSS7 no CentOs7 
J_VERSION=7.0.0
J2_VERSION=7.0
INST_DIR=/opt/jboss
SYSTEMD_DIR=/etc/systemd/system
SPEC_USER_DIR=/root/jboss_user

# Atualiza mirrors localmente
yum update

# Instalando java-openjdk
yum install java-1.7.0-openjdk-devel -y

# Setando o Home do JAVA que instalamos
export JAVA_HOME=/usr/lib/jvm/java

# Criando o grupo do Tomcat
groupadd jboss

# Criando usuario do tomcat e chrootando para um diretorio especifico
useradd -M -s /bin/nologin -g jboss -d /opt/jboss jboss

# Baixando a versão do Tomcat de acordo com as variaveis setadas acima
wget http://download.jboss.org/jbossas/$J2_VERSION/jboss-as-$J_VERSION.Final/jboss-as-$J_VERSION.Final.tar.gz

# Extraindo tomcat no diretorio de instalacao
tar xf jboss-as-$J_VERSION.Final.tar.gz -C /opt/
ln -s /opt/jboss-as-$J_VERSION.Final/ /opt/jboss 

# Mudando as permissoes de arquivos e diretorios

chgrp -R jboss $INST_DIR/
chmod g+rwx $INST_DIR/
chown -R jboss: $INST_DIR/

# Criando arquivo daemon de inicializacao do Jboss conforme os padroes do systemd
echo "
[Unit]
Description=Jboss Application Server
After=network.target

[Service]
Type=idle
Environment=JAVA_HOME=/usr/lib/jvm/java JBOSS_HOME=/opt/jboss JAVA=/usr/lib/jvm/java/bin/java JBOSS_LOG_DIR=/var/log/jboss "JAVA_OPTS=-Xms256m -Xmx512m -XX:MaxPermSize=768m"
User=jboss
Group=jboss
ExecStart=/opt/jboss/bin/standalone.sh
TimeoutStartSec=600
TimeoutStopSec=600

[Install]
WantedBy=multi-user.target" > $SYSTEMD_DIR/jboss.service

# Criando as permissoes de execucao para o servico do jboss
chmod +x $SYSTEMD_DIR/jboss.service

# Reload nas daemons
systemctl daemon-reload

# Iniciando jboss
systemctl start jboss.service

# Habilitando jboss 
systemctl enable jboss.service
