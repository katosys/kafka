#------------------------------------------------------------------------------
# Set the base image for subsequent instructions:
#------------------------------------------------------------------------------

FROM anapsix/alpine-java:8_jdk
MAINTAINER Marc Villacorta Morera <marc.villacorta@gmail.com>

#------------------------------------------------------------------------------
# Install:
#------------------------------------------------------------------------------

RUN apk --no-cache add -U -t dev git bash \
    && cd /tmp && git clone https://github.com/mesos/kafka && cd kafka \
    && git fetch origin pull/281/head:pr-281 && git checkout pr-281 \
    && ./gradlew -x test jar && ./gradlew downloadKafka \
    && mkdir /kafka && mv kafka* /kafka \
    && rm -rf /tmp/* /root/.gradle && apk del --purge dev \
    && rm -rf /usr/lib/ruby/gems/*/cache/* /var/cache/apk/*

ADD rootfs /

#------------------------------------------------------------------------------
# Setup glibc:
#------------------------------------------------------------------------------

RUN ln -s /usr/glibc-compat/etc/ld.so.conf /etc/ \
    && echo /opt/lib >> /etc/ld.so.conf \
    && sed -i '/^RTLDLIST=/c\RTLDLIST=/usr/glibc-compat/lib/ld-linux-x86-64.so.2' \
    /usr/glibc-compat/bin/ldd

#------------------------------------------------------------------------------
# Expose ports and entrypoint:
#------------------------------------------------------------------------------

WORKDIR /kafka
ENTRYPOINT ["/init"]
