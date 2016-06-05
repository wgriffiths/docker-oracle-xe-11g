FROM ubuntu:16.04


ENV DEBIAN_FRONTEND=noninteractive

ADD assets /assets

RUN cat /assets/oracle-xe_11.2.0-1.0_amd64.deba* > /assets/oracle-xe_11.2.0-1.0_amd64.deb

RUN echo $(grep $(hostname) /etc/hosts | cut -f1) oracle-host

# Install Oracle
RUN apt-get update
RUN apt-get install -y libaio1 net-tools bc
RUN ln -s /usr/bin/awk /bin/awk
RUN mkdir /var/lock/subsys
RUN mv /assets/chkconfig /sbin/chkconfig
RUN chmod 755 /sbin/chkconfig
RUN dpkg --install /assets/oracle-xe_11.2.0-1.0_amd64.deb
RUN mv /assets/init.ora /u01/app/oracle/product/11.2.0/xe/config/scripts
RUN mv /assets/initXETemp.ora /u01/app/oracle/product/11.2.0/xe/config/scripts
RUN printf 8080\\n1521\\noracle\\noracle\\ny\\n | /etc/init.d/oracle-xe configure

ENV LISTENERS_ORA=/u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora


RUN sed -i "s/%hostname%/oracle-host/g" "${LISTENERS_ORA}""
RUN sed -i "s/%port%/1521/g" "${LISTENERS_ORA}"

ENV ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
ENV PATH=$ORACLE_HOME/bin:$PATH
ENV ORACLE_SID=XE

RUN service oracle-xe start

RUN echo "alter system disable restricted session;" | sqlplus -s SYSTEM/oracle

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD /assets/startup.sh
