FROM centos:centos7
LABEL maintainer="Rainer Hörbe <r2h2@hoerbe.at>" \
      version="0.5.0" \
      capabilities='--cap-drop=all'

RUN yum -y install epel-release curl ip lsof net-tools unzip wget which xmlstarlet \
 && yum -y install usbutils gcc gcc-c++ git openssl redhat-lsb-core opensc pcsc-lite \
 && yum -y install python-pip python-devel libxslt-devel \
 && yum clean all \
 && pip install --upgrade pip \
 && pip install six
#use easy_install solves install bug
# InsecurePlatformWarning can be ignored - this system does not use TLS
RUN easy_install --upgrade six \
 && pip install importlib
#using iso8601 0.1.9 because of str/int compare bug in pyff
RUN pip install future iso8601==0.1.9 \
 && pip install lxml \
 && pip install pykcs11==1.3.0 # using pykcs11 1.3.0 because of missing wrapper in v 1.3.1

# changed defaults for c14n, digest & signing alg - used rhoerbe fork
COPY install/opt/pyXMLSecurity /opt/source/pyXMLSecurity
RUN cd /opt/source/pyXMLSecurity \
 && python setup.py install

# mdsplit function has not been pushed upstream yet - used rhoerbe fork
COPY install/opt/pyff /opt/source/pyff
# auto-installing  Cherry-Py dependency failed with 7.1.0 (UnicodeDecodeError)
RUN pip install cherrypy \
 && cd /opt/source/pyff && python setup.py install

# install Shibboleth XMLSECTOOL used in pyffsplit.sh (requires JRE, but installing JDK because of /etc/alternatives support)
RUN yum -y install java-1.8.0-openjdk-devel.x86_64
ENV JAVA_HOME=/etc/alternatives/jre_1.8.0_openjdk
COPY install/opt/xmlsectool-2 /opt/xmlsectool-2
ENV XMLSECTOOL=/opt/xmlsectool-2/xmlsectool.sh

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/pyff_batch.log \
 && ln -sf /dev/stderr /var/log/pyff_batch.error

COPY install/testdata /opt/testdata
COPY install/testdata/etc/pki/tls/openssl.cnf /opt/testdata/etc/pki/tls/
COPY install/scripts/*.sh /
COPY install/tests/* /tests/

# Application will run as a non-root user
# DAC Permission strategy: group 0 & no group access for private directories
ARG USERNAME=pyff
ARG UID=343003
ENV GID=0
RUN adduser -g $GID -u $UID $USERNAME \
 && chmod +x /*.sh /tests/* \
 && chmod -R 700 $(find /opt -type d) \
 && chown -R $UID:$GID /opt

VOLUME       /etc/pki/sign /etc/pyff /home/$USERNAME/.ssh /var/log /var/md_feed /var/md_source
ENV VOLDIRS="/etc/pki/sign /etc/pyff /home/$USERNAME/.ssh /var/log /var/md_feed /var/md_source"
RUN mkdir -p $VOLDIRS \
 && chmod -R 700 $(find $VOLDIRS -type d) \
 && chmod -R 755 $(find /var/md_feed -type d) \
 && chown -R $UID:$GID $VOLDIRS

COPY install/gitconfig /home/$USERNAME/.gitconfig