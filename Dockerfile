FROM centos:centos7
LABEL maintainer="Rainer Hörbe <r2h2@hoerbe.at>" \
      version="0.6.1"
      #didi_dir="https://raw.githubusercontent.com/identinetics/docker-pyff/master/didi" \
      # capabilities='--cap-drop=all'  # TODO: needs testing to enable

RUN yum update -y && yum clean all \
 && yum -y install epel-release curl ip lsof net-tools sudo sysvinit-tools unzip wget which xmlstarlet \
 && yum -y install usbutils gcc gcc-c++ git openssl redhat-lsb-core \
                   opensc pcsc-lite engine_pkcs11 gnutls-utils \
 && yum -y install python-pip python-devel libxslt-devel \
 && yum clean all
RUN pip install --upgrade pip \
 && pip install six

# use easy_install, solves install bug
# InsecurePlatformWarning can be ignored - this system does not use TLS
RUN easy_install --upgrade six \
 && pip install importlib
#using iso8601 0.1.9 because of str/int compare bug in pyff
RUN pip install babel future iso8601==0.1.9 \
 && pip install lxml \
 && pip install pykcs11

#RUN pip install pykcs11==1.3.0 # using pykcs11 1.3.0 because of missing wrapper in v 1.3.1 - tested with 1.4.2: OK
# use leifj's fork of pykcs11
#ENV repodir='/opt/source/PyKCS11'
#ENV repourl='https://github.com/leifj/PyKCS11'
#RUN mkdir -p $repodir && cd $repodir \
# && git clone $repourl . \
# && python setup.py install

# install Shibboleth XMLSECTOOL used in pyffsplit.sh (requires JRE, but installing JDK because of /etc/alternatives support)
# --- XMLSECTOOL ---
ENV version='2.0.0'
RUN mkdir -p /opt && cd /opt \
 && wget "https://shibboleth.net/downloads/tools/xmlsectool/${version}/xmlsectool-${version}-bin.zip" \
 && unzip "xmlsectool-${version}-bin.zip" \
 && ln -s "xmlsectool-${version}" 'xmlsectool-2' \
 && rm "xmlsectool-${version}-bin.zip" \
 && yum -y install java-1.8.0-openjdk-devel.x86_64 \
 && yum clean all
ENV JAVA_HOME=/etc/alternatives/jre_1.8.0_openjdk
ENV XMLSECTOOL=/opt/xmlsectool-2/xmlsectool.sh

# changed defaults for c14n, digest & signing alg - used rhoerbe fork
ENV repodir='/opt/source/pyXMLSecurity'
ENV repourl='https://github.com/rhoerbe/pyXMLSecurity'
# the branch has patches for sig/digest als and unlabeld privated keys in HSM
ENV repobranch='rh_fork'
RUN mkdir -p $repodir && cd $repodir \
 && git clone $repourl . \
 && git checkout $repobranch \
 && python setup.py install

# mdsplit function has not been pushed upstream yet - used rhoerbe fork
# auto-installing  Cherry-Py dependency failed with 7.1.0 (UnicodeDecodeError)
RUN pip install cherrypy
COPY install/opt/pyFF /opt/source/pyff/
RUN cd /opt/source/pyff/ && python setup.py install
#ENV repodir='/opt/source/pyff'
#ENV repourl='https://github.com/identinetics/pyFF'
#RUN mkdir -p $repodir && cd $repodir \
# && git clone $repourl . \
# && git checkout i18n \
# && python setup.py compile_catalog \
# && python setup.py install
# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/pyff_batch.log \
 && ln -sf /dev/stderr /var/log/pyff_batch.error

COPY install/testdata /opt/testdata
COPY install/testdata/etc/pki/tls/openssl.cnf /opt/testdata/etc/pki/tls/
COPY install/scripts/* /scripts/
COPY install/tests/* /tests/
COPY VERSION /opt/VERSION

# Application will run as a non-root user
# DAC Permission strategy: group 0 & no group access for private directories
ARG USERNAME=pyff
ARG UID=343003
ENV GID=0
RUN adduser -g $GID -u $UID $USERNAME \
 && chmod +x /scripts/* /tests/* \
 && chmod -R 700 $(find /opt -type d) \
 && chown -R $UID:$GID /opt \
 && mkdir -p /etc/sudoers.d \
 && echo "$USERNAME ALL=(root) NOPASSWD: /usr/sbin/pcscd" > /etc/sudoers.d/$USERNAME

ENV VOLDIRS="/etc/pki/sign /etc/pyff /home/$USERNAME/.ssh /var/log /var/md_feed /var/md_source"
RUN mkdir -p $VOLDIRS \
 && mkdir -p /etc/pki/sign/certs /etc/pki/sign/private \
 && chmod -R 700 $(find $VOLDIRS -type d) \
 && chmod -R 755 $(find /var/md_feed -type d) \
 && chown -R $UID:$GID $VOLDIRS
VOLUME /etc/pki/sign \
       /etc/pyff \
       /home/$USERNAME/.ssh \
       /var/log \
       /var/md_feed \
       /var/md_source

COPY install/opt/gitconfig /home/$USERNAME/.gitconfig
COPY install/opt/known_hosts /home/$USERNAME/.ssh/
COPY install/opt/xslt/* /etc/pyff/xslt/
COPY install/opt/html_resources/* /opt/md_feed/

# Install PKCS#11 drivers for Safenet eTokenPro
COPY install/safenet/Linux/Installation/Standard/RPM/RPM-GPG-KEY-SafenetAuthenticationClient /opt/sac/
COPY install/safenet/Linux/Installation/Standard/RPM/SafenetAuthenticationClient-9.1.7-0.x86_64.rpm /opt/sac/SafenetAuthenticationClient_x86_64.rpm
RUN yum -y install gtk2 xdg-utils \
 && rpm --import /opt/sac/RPM-GPG-KEY-SafenetAuthenticationClient \
 && rpm -i /opt/sac/SafenetAuthenticationClient_x86_64.rpm --nodeps \
 && yum clean all
ENV PKCS11_CARD_DRIVER='/usr/lib64/libetvTokenEngine.so'

EXPOSE 8080

# For development/debugging - map port in config and start sshd with /start_sshd.sh
#RUN yum -y install openssh-server \
# && yum clean all \
# && echo changeit | passwd -f --stdin $USERNAME \
# && echo changeit | passwd -f --stdin root \
# && echo 'GSSAPIAuthentication no' >> /etc/ssh/sshd_config \
# && echo 'useDNS no' >> /etc/ssh/sshd_config \
# && rm -f /etc/ssh/ssh_host_*_key  # generate on first container start, not in image
#COPY dscripts/templates/install/scripts/start_sshd.sh /
#RUN chmod +x /start_sshd.sh
#VOLUME /etc/sshd
#EXPOSE 2022

COPY REPO_STATUS  /opt/etc/REPO_STATUS
