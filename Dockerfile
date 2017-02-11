#------------------------------------------------------------------------------
# Set the base image for subsequent instructions:
#------------------------------------------------------------------------------

FROM alpine:3.5
MAINTAINER Marc Villacorta Morera <marc.villacorta@gmail.com>

#------------------------------------------------------------------------------
# Install:
#------------------------------------------------------------------------------

RUN apk --no-cache add -U -t dev git bash openjdk8 \
    && apk add -U openjdk8-jre \
    && cd /tmp && git clone https://github.com/mesos/kafka && cd kafka \
    && git fetch origin pull/281/head:pr-281 && git checkout pr-281 \
    && ./gradlew jar && ./gradlew downloadKafka \
    && mkdir /kafka && mv kafka* /kafka \
    && rm -rf /tmp/* /root/.gradle && apk del --purge dev \
    && rm -rf /usr/lib/ruby/gems/*/cache/* /var/cache/apk/*

#------------------------------------------------------------------------------
# Populate root file system:
#------------------------------------------------------------------------------

ADD rootfs /

#------------------------------------------------------------------------------
# Expose ports and entrypoint:
#------------------------------------------------------------------------------

WORKDIR /kafka
ENTRYPOINT ["/bin/sh"]
