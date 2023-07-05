# qBittorrent and OpenVPN
#
# Version 1.0.3
# docker build -t magnus2468/qbittorrent-vpn:1.0.3 .
# docker tag magnus2468/qbittorrent-vpn:1.0.3  cloud.canister.io:5000/magnus2468/qbittorrent-vpn:1.0.3
# docker push cloud.canister.io:5000/magnus2468/qbittorrent-vpn:1.0.3

FROM ubuntu:22.04
LABEL org.opencontainers.image.authors="magnus2468@gmail.com"

VOLUME /downloads
VOLUME /config

ENV DEBIAN_FRONTEND noninteractive

RUN usermod -u 99 nobody

# Update packages and install software
RUN apt-get update \
    && apt-get install -y --no-install-recommends apt-utils openssl \
    && apt-get install -y software-properties-common \
    && add-apt-repository ppa:qbittorrent-team/qbittorrent-stable \
    && apt-get update \
    && apt-get install -y qbittorrent-nox openvpn curl moreutils net-tools dos2unix kmod iptables ipcalc unrar iputils-ping \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add configuration and scripts
ADD openvpn/ /etc/openvpn/
ADD qbittorrent/ /etc/qbittorrent/
ADD scripts/ /etc/scripts/

RUN chmod +x /etc/qbittorrent/*.sh /etc/qbittorrent/*.init /etc/openvpn/*.sh /etc/scripts/*.sh

HEALTHCHECK --interval=1m CMD /etc/scripts/healthcheck.sh
LABEL autoheal=true

# Expose ports and run
EXPOSE 8080
EXPOSE 8999
EXPOSE 8999/udp
CMD ["/bin/bash", "/etc/openvpn/start.sh"]
