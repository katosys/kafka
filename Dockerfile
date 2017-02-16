#------------------------------------------------------------------------------
# Set the base image for subsequent instructions:
#------------------------------------------------------------------------------

FROM alpine:3.5
MAINTAINER Marc Villacorta Morera <marc.villacorta@gmail.com>

#------------------------------------------------------------------------------
# Install glibc:
#------------------------------------------------------------------------------

ENV GLIBC_VERSION="2.25-r0" \
    RSA_URL="https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master" \
    APK_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download"

RUN apk add -U --no-cache -t dev ca-certificates libressl \
    && wget -q ${APK_URL}/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
    && wget -q ${APK_URL}/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk \
    && wget -q ${APK_URL}/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk \
    && wget -qO /etc/apk/keys/sgerrand.rsa.pub ${RSA_URL}/sgerrand.rsa.pub \
    && apk add --no-cache *.apk && rm /etc/apk/keys/sgerrand.rsa.pub *.apk

RUN ln -s /usr/glibc-compat/etc/ld.so.conf /etc/ \
    && echo '/opt/lib' >> /etc/ld.so.conf \
    && echo 'export LANG=en_US.UTF-8' > /etc/profile.d/locale.sh \
    && /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 \
    && sed -i '/^RTLDLIST=/c\RTLDLIST=/usr/glibc-compat/lib/ld-linux-x86-64.so.2' \
    /usr/glibc-compat/bin/ldd && apk del glibc-i18n

#------------------------------------------------------------------------------
# Install Oracle JDK 8:
#------------------------------------------------------------------------------

ENV JAVA_HOME="/opt/jdk" \
    PATH="${PATH}:/opt/jdk/bin" \
    JAVA_URL="http://download.oracle.com/otn-pub/java/jdk"

RUN apk add -U --no-cache -t dev curl && mkdir /opt \
    && curl -sLH 'Cookie: oraclelicense=accept-securebackup-cookie' \
    ${JAVA_URL}/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.tar.gz \
    | tar zx -C /opt && mv /opt/jdk1.8.0_121 ${JAVA_HOME} \
    && sed -i s/#networkaddress.cache.ttl=-1/networkaddress.cache.ttl=10/ \
    ${JAVA_HOME}/jre/lib/security/java.security && chown -R root:root ${JAVA_HOME}

#------------------------------------------------------------------------------
# Install Mesos Kafka:
#------------------------------------------------------------------------------

RUN apk --no-cache add -U -t dev git && apk add --no-cache bash ncurses \
    && cd /tmp && git clone https://github.com/mesos/kafka && cd kafka \
    && git fetch origin pull/281/head:pr-281 && git checkout pr-281 \
    && ./gradlew -x test jar && ./gradlew downloadKafka \
    && mkdir /kafka && mv kafka* /kafka && rm -rf /tmp/* /root/.gradle

COPY rootfs /

#------------------------------------------------------------------------------
# Strip JDK into JRE:
#------------------------------------------------------------------------------

RUN find /opt/jdk -maxdepth 1 -mindepth 1 | grep -v jre | xargs rm -rf \
    && cd /opt/jdk && ln -s ./jre/bin ./bin && cd /opt/jdk/jre && rm -rf \
    plugin bin/javaws bin/jjs bin/orbd bin/pack200 bin/policytool bin/rmid \
    bin/rmiregistry bin/servertool bin/tnameserv bin/unpack200 lib/javaws.jar \
    lib/deploy* lib/desktop lib/*javafx* lib/*jfx* lib/amd64/libdecora_sse.so \
    lib/amd64/libprism_*.so lib/amd64/libfxplugins.so lib/amd64/libglass.so \
    lib/amd64/libgstreamer-lite.so lib/amd64/libjavafx*.so lib/amd64/libjfx*.so \
    lib/ext/jfxrt.jar lib/ext/nashorn.jar lib/oblique-fonts lib/plugin.jar

#------------------------------------------------------------------------------
# Pre-squash cleanup:
#------------------------------------------------------------------------------

RUN apk del --purge dev && rm -rf /var/cache/apk/* /tmp/*

#------------------------------------------------------------------------------
# Expose ports and entrypoint:
#------------------------------------------------------------------------------

WORKDIR /kafka
ENTRYPOINT ["/init"]
