FROM centos:centos7
MAINTAINER Rainer Hörbe <r2h2@hoerbe.at>

RUN yum -y install epel-release curl ip lsof net-tools \
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
WORKDIR /opt/source/pyXMLSecurity
RUN python setup.py install

# mdsplit function has not been pushed upstream yet - used rhoerbe fork
COPY install/opt/pyff /opt/source/pyff
WORKDIR /opt/source/pyff
# auto-installing  Cherry-Py dependency failed with 7.1.0 (UnicodeDecodeError)
RUN pip install cherrypy \
 && python setup.py install

# install Shibboleth XMLSECTOOL used in pyffsplit.sh (requires JRE, but installing JDK because of /etc/alternatives support)
RUN yum -y install java-1.8.0-openjdk-devel.x86_64
ENV JAVA_HOME=/etc/alternatives/jre_1.8.0_openjdk
COPY install/opt/xmlsectool-2 /opt/xmlsectool-2

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/pyff_batch.log \
 && ln -sf /dev/stderr /var/log/pyff_batch.error

# Application will run as a non-root user/group that must map to the docker host
ARG USERNAME
ARG UID
RUN groupadd -g $UID $USERNAME \
 && adduser -g $UID -u $UID $USERNAME \
 && mkdir -p /opt \
 && chmod 750 /opt
ENV JAVA_HOME=/etc/alternatives/jre_1.8.0_openjdk
ENV XMLSECTOOL=/opt/xmlsectool-2/xmlsectool.sh

COPY install/sample_data /opt/sample_data
COPY install/sample_data/etc/pki/tls/openssl.cnf /etc/pki/tls/
COPY install/scripts/*.sh /
RUN chmod +x /*.sh \
 && chmod -R 755 /opt

