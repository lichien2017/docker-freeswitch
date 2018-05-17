FROM debian:jessie-slim
LABEL maintainer "Praekelt.org <sre@praekelt.org>"

# Add Freeswitch 1.6 repo
RUN echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main" \
        > /etc/apt/sources.list.d/freeswitch.list \
    && apt-key adv --keyserver pool.sks-keyservers.net --recv-key 20B06EE621AB150D40F6079FD76EDC7725E010CF

ENV FREESWITCH_VERSION 1.6.20~37~987c9b9-1~jessie+1

# Install Freeswitch (use regular apt-get install to avoid weird dependency problems)
RUN apt-get update \
    && apt-get -qy install \
        freeswitch-meta-vanilla=$FREESWITCH_VERSION \
        freeswitch-mod-flite=$FREESWITCH_VERSION \
        freeswitch-mod-shout=$FREESWITCH_VERSION \
    && rm -rf /var/lib/apt/lists/*

# Copy basic configuration files
RUN cp -a /usr/share/freeswitch/conf/vanilla/. /etc/freeswitch/
COPY config/ /etc/freeswitch/

# Disable the example gateway
RUN set -ex; \
    cd /etc/freeswitch; \
    mv directory/default/example.com.xml directory/default/example.com.xml.noload; \
    mv sip_profiles/external-ipv6.xml sip_profiles/external-ipv6.xml.noload; \
    mv sip_profiles/internal-ipv6.xml sip_profiles/internal-ipv6.xml.noload

# Don't expose any ports - use host networking

# Set up the entrypoint
COPY entrypoint.sh /usr/local/bin/freeswitch-entrypoint.sh
ENTRYPOINT ["freeswitch-entrypoint.sh"]
CMD ["-c", "-u", "freeswitch", "-g", "freeswitch"]
