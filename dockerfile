FROM ubuntu:18.04
MAINTAINER HYEONJUKIM
WORKDIR /usr/local

RUN apt-get update -y &&    apt-get -y install openjdk-8-jdk wget git
RUN useradd -r -m -U -d /opt/tomcat -s /bin/false tomcat
RUN wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.56/bin/apache-tomcat-9.0.56.tar.gz -P /tmp
RUN tar xf /tmp/apache-tomcat-9*.tar.gz -C /opt/tomcat
RUN ln -s /opt/tomcat/apache-tomcat-9.0.56 /opt/tomcat/latest
RUN chown -RH tomcat: /opt/tomcat/latest
RUN sh -c 'chmod +x /opt/tomcat/latest/bin/*.sh'
COPY tomcat.service /etc/systemd/system/tomcat.service
RUN wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.26.tar.gz
RUN tar zxf mysql-connector-java-8.0.26.tar.gz
RUN cp -a mysql-connector-java-8.0.26/mysql-connector-java-8.0.26.jar /opt/tomcat/latest/lib

RUN sed -i 's/<\/tomcat-users>//' /opt/tomcat/latest/conf/tomcat-users.xml
RUN echo '\n<role rolename="admin-gui"/> \n<role rolename="manager-gui"/> \n<user username="admin" password="admin_password" roles="admin-gui,manager-gui"/> \n<role rolename="manager-script"/> \n<role rolename="manager-gui"/> \n<role rolename="manager-jmx"/> \n<role rolename="manager-status"/> \n<user username="tomcat" password="tomcat" roles="manager-gui,manager-script,manager-status,manager-jmx"/> \n</tomcat-users> \n' >> /opt/tomcat/latest/conf/tomcat-users.xml
RUN sed -i 's/<Valve/<!--<Valve/'  /opt/tomcat/latest/webapps/manager/META-INF/context.xml &&sed -i 's/<Manager/--><Manager/'  /opt/tomcat/latest/webapps/manager/META-INF/context.xml &&sed -i 's/<Valve/<!--<Valve/'  /opt/tomcat/latest/webapps/host-manager/META-INF/context.xml &&sed -i 's/<Manager/--><Manager/'  /opt/tomcat/latest/webapps/host-manager/META-INF/context.xml
WORKDIR /opt/tomcat/latest/bin/
RUN ./catalina.sh start
WORKDIR /home/ubuntu/
RUN git clone https://github.com/SteveKimbespin/petclinic_btc.git

WORKDIR ./petclinic_btc
RUN sed -i 's/\[Change Me\]/docker-mysql.cjmpkuf8ixvg.ap-northeast-2.rds.amazonaws.com/' pom.xml
EXPOSE 8080

ENTRYPOINT ["/opt/tomcat/latest/bin/catalina.sh", "run"]