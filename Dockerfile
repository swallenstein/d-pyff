FROM centos:centos7
MAINTAINER Rainer Hörbe <r2h2@hoerbe.at>

RUN yum -y install epel-release curl ip lsof net-tools \
 && yum -y install usbutils gcc gcc-c++ redhat-lsb-core opensc pcsc-lite \
 && yum -y install python-pip python-devel libxslt-devel \
 && yum clean all \
 && pip install --upgrade pip \
 && pip install six
#use easy_install solves install bug
# InsecurePlatformWarning can be ignored - this system does not use TLS
RUN easy_install --upgrade six \
 && pip install importlib
#using iso8601 0.1.9 because of str/int compare bug in pyff
RUN pip install iso8601==0.1.9 \
 && pip install pyff \
 && pip install pykcs11==1.3.0  # using pykcs11 1.3.0 because of missing wrapper in v 1.3.1

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

COPY sample_data /opt/sample_data
COPY init_sample.sh start*.sh /
RUN chmod +x /start*.sh \
 && chmod -R 755 /opt

