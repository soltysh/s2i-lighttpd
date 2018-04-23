# We are basing our builder image on openshift base-centos7 image
FROM openshift/base-centos7

# Inform users who's the maintainer of this builder image
MAINTAINER Maciej Szulik <maszulik@redhat.com>

# Inform about software versions being used inside the builder
ENV LIGHTTPD_VERSION=1.4.35

# Set labels used in OpenShift to describe the builder images
LABEL io.k8s.description="Platform for serving static HTML files" \
      io.k8s.display-name="Lighttpd 1.4.35" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,html,lighttpd"

# Enable epel repository for lighttpd
RUN yum install -y epel-release

# Import the EPEL GPG-key
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7

# Update the repositories
RUN yum -y update

# Install the required software, namely Lighttpd and
RUN yum install -y lighttpd && \
    # clean yum cache files, as they are not needed and will only make the image bigger in the end
    yum clean all -y

# Copy the S2I scripts to /usr/libexec/s2i which is the location set for scripts
# in openshift/base-centos7 as io.openshift.s2i.scripts-url label
COPY ./s2i/bin/ /usr/libexec/s2i

# Copy the lighttpd configuration file
COPY ./etc/ /opt/app-root/etc

# Drop the root user and make the content of /opt/openshift owned by user 1001
RUN chown -R 1001:1001 /opt/app-root

# Set the default user for the image, the user itself was created in the base image
USER 1001

# Specify the ports the final image will expose
EXPOSE 8080

# Set the default CMD to print the usage of the image, if somebody does docker run
CMD ["/usr/libexec/s2i/usage"]
