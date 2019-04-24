# Copyright 2017 Red Hat
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ------------------------------------------------------------------------
#
# This is a Dockerfile for the jboss-webserver-3/webserver31-tomcat8-openshift:1.4 image.

FROM jboss-webserver-3/webserver31-tomcat8:3.1.6

USER root


# Install required RPMs and ensure that the packages were installed
RUN yum install -y rh-maven35 yum-utils unzip tar rsync rh-mongodb32-mongo-java-driver postgresql-jdbc mysql-connector-java PyYAML \
    && yum clean all && rm -rf /var/cache/yum \
    && rpm -q rh-maven35 yum-utils unzip tar rsync rh-mongodb32-mongo-java-driver postgresql-jdbc mysql-connector-java PyYAML


# Add all artifacts to the /tmp/artifacts
# directory
COPY \
    jolokia-jvm-1.5.0.redhat-1-agent.jar \
    json-smart-1.1.1.jar \
    commons-lang-2.6.0.redhat-4.jar \
    jsonevent-layout-1.7-redhat-1.jar \
    tomcat-8-valves-1.0.3.Final-redhat-1.jar \
    /tmp/artifacts/


# Environment variables
ENV \
    AB_JOLOKIA_AUTH_OPENSHIFT="true" \
    AB_JOLOKIA_HTTPS="true" \
    AB_JOLOKIA_PASSWORD_RANDOM="true" \
    HOME="/home/jboss" \
    JBOSS_CONTAINER_JAVA_JVM_MODULE="/opt/jboss/container/java/jvm" \
    JBOSS_CONTAINER_JAVA_PROXY_MODULE="/opt/jboss/container/java/proxy" \
    JBOSS_CONTAINER_JOLOKIA_MODULE="/opt/jboss/container/jolokia" \
    JBOSS_CONTAINER_JWS_S2I_MODULE="/opt/jboss/container/jws/s2i" \
    JBOSS_CONTAINER_MAVEN_35_MODULE="/opt/jboss/container/maven/35/" \
    JBOSS_CONTAINER_MAVEN_DEFAULT_MODULE="/opt/jboss/container/maven/default/" \
    JBOSS_CONTAINER_MAVEN_S2I_MODULE="/opt/jboss/container/maven/s2i" \
    JBOSS_CONTAINER_S2I_CORE_MODULE="/opt/jboss/container/s2i/core/" \
    JBOSS_CONTAINER_UTIL_LOGGING_MODULE="/opt/jboss/container/util/logging/" \
    JBOSS_IMAGE_NAME="jboss-webserver-3/webserver31-tomcat8-openshift" \
    JBOSS_IMAGE_VERSION="1.4" \
    JOLOKIA_VERSION="1.5.0" \
    MAVEN_VERSION="3.5" \
    S2I_SOURCE_DEPLOYMENTS_FILTER="*.war" \
    STI_BUILDER="jee" 

# Labels
LABEL \
      com.redhat.component="jboss-webserver-3-webserver31-tomcat8-openshift-container"  \
      description="Red Hat JBoss Web Server 3.1 - Tomcat 8 OpenShift container image"  \
      io.cekit.version="2.2.4"  \
      io.fabric8.s2i.version.jolokia="1.5.0-redhat-1"  \
      io.fabric8.s2i.version.maven="3.5"  \
      io.k8s.description="Platform for building and running web applications on JBoss Web Server 3.1 - Tomcat v8"  \
      io.k8s.display-name="JBoss Web Server 3.1"  \
      io.openshift.expose-services="8080:http"  \
      io.openshift.s2i.destination="/tmp"  \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i"  \
      io.openshift.tags="builder,java,tomcat8"  \
      name="jboss-webserver-3/webserver31-tomcat8-openshift"  \
      org.concrt.version="2.2.4"  \
      org.jboss.container.deployments-dir="/deployments"  \
      summary="Red Hat JBoss Web Server 3.1 - Tomcat 8 OpenShift container image"  \
      version="1.4" 

# Exposed ports
EXPOSE 8778 8443
# Add scripts used to configure the image
COPY modules /tmp/scripts

# Custom scripts
USER root
RUN [ "bash", "-x", "/tmp/scripts/jboss.container.java.proxy.bash/configure.sh" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/jboss.container.java.proxy.bash/backward_compatibility.sh" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/jboss.container.java.jvm.bash/configure.sh" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/jboss.container.java.jvm.bash/backward_compatibility.sh" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/dynamic-resources/install.sh" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/jboss.container.maven.35.bash/configure.sh" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/jboss.container.util.logging.bash/configure.sh" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/jboss.container.util.logging.bash/backward_compatibility.sh" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/jboss.container.maven.default.bash/configure.sh" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/jboss.container.maven.default.bash/backward_compatibility.sh" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/java-alternatives/run.sh" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/jboss.container.s2i.core.bash/configure.sh" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/jboss.container.maven.s2i.bash/configure.sh" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/jboss.container.jws.s2i.bash/configure.sh" ]

USER 185
RUN [ "bash", "-x", "/tmp/scripts/os-jws8-conffiles/run" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/os-jws-deployments/run" ]

USER 185
RUN [ "bash", "-x", "/tmp/scripts/os-jws-deployments/run_as_jboss" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/jboss.container.jolokia.bash/configure.sh" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/jboss.container.jolokia.bash/backward_compatibility.sh" ]

USER 185
RUN [ "bash", "-x", "/tmp/scripts/os-jws-jolokia/run" ]

USER 185
RUN [ "bash", "-x", "/tmp/scripts/os-jws-db-drivers/run" ]

USER 185
RUN [ "bash", "-x", "/tmp/scripts/os-jws-logging/run" ]

USER 185
RUN [ "bash", "-x", "/tmp/scripts/os-jws-launch/run" ]

USER 185
RUN [ "bash", "-x", "/tmp/scripts/os-jws-https/run" ]

USER 185
RUN [ "bash", "-x", "/tmp/scripts/os-jws-secure-mgmt-console/run" ]

USER 185
RUN [ "bash", "-x", "/tmp/scripts/os-jws-rm-root/run" ]

USER 185
RUN [ "bash", "-x", "/tmp/scripts/os-jws-rm-defaults/run" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/os-jws-chmod/run" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/jboss.container.user/configure.sh" ]

USER root
RUN rm -rf /tmp/scripts
USER root
RUN rm -rf /tmp/artifacts

USER 185

# Specify the working directory
WORKDIR /home/jboss


CMD ["/opt/webserver/bin/launch.sh"]
