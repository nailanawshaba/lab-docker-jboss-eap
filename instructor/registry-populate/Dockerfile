FROM rhel7.1
MAINTAINER Pete Muir <pmuir@redhat.com>

USER root

RUN yum --enablerepo=rhel-7-server-extras-rpms -y install docker; yum clean all
ADD populate.sh .
VOLUME /var/run/docker.sock
VOLUME /lab
CMD ["./populate.sh"]

