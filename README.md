
# qBittorrent with WebUI and OpenVPN/Wireguard

Docker container which runs the latest headless qBittorrent client with WebUI while connecting to OpenVPN or Wireguard with iptables killswitch to prevent IP leakage when the tunnel goes down.

## Docker Features

* Base: Ubuntu 24.10
* qBittorrent: 5.0.1
* lib_torrent: 2.0.10
* qt 6.6
* Selectively enable or disable OpenVPN/Wireguard support
* IP tables kill switch to prevent IP leaking when VPN connection fails
* Specify name servers to add to container
* Configure UID, GID, and UMASK for config files and downloads by qBittorrent
* WebUI\CSRFProtection set to false by default for Unraid users

# Run container from Docker registry

The container is available from the Docker registry and this is the simplest way to get it.
To run the container use this command:

```
$ docker run --privileged  -d \
              -v /your/config/path/:/config \
              -v /your/downloads/path/:/downloads \
              -e "VPN_ENABLED=yes" \
              -e "VPN_TYPE=openvpn" \
              -e "LAN_NETWORK=192.168.1.0/24" \
              -e "NAME_SERVERS=8.8.8.8,8.8.4.4" \
              -p 8080:8080 \
              -p 8999:8999 \
              -p 8999:8999/udp \
              magnus2468/qbittorrent-vpn
```

# Variables, Volumes, and Ports

## Environment Variables

| Variable | Required | Function | Example |
|----------|----------|----------|----------|
|`VPN_ENABLED`| Yes | Enable VPN? (yes/no) Default:yes|`VPN_ENABLED=yes`|
|`VPN_TYPE`| No | Which vpn type to use? (openvpn/wireguard) Default:openvpn|`VPN_ENABLED=openvpn`|
|`VPN_USERNAME`| No | If username and password provided, configures ovpn file automatically (only used for openvpn) |`VPN_USERNAME=ad8f64c02a2de`|
|`VPN_PASSWORD`| No | If username and password provided, configures ovpn file automatically (only used for openvpn) |`VPN_PASSWORD=ac98df79ed7fb`|
|`LAN_NETWORK`| Yes | Local Network with CIDR notation |`LAN_NETWORK=192.168.1.0/24`|
|`NAME_SERVERS`| No | Comma delimited name servers |`NAME_SERVERS=8.8.8.8,8.8.4.4`|
|`PUID`| No | UID applied to config files and downloads |`PUID=99`|
|`PGID`| No | GID applied to config files and downloads |`PGID=100`|
|`UMASK`| No | GID applied to config files and downloads |`UMASK=002`|
|`WEBUI_PORT`| No | Applies WebUI port to qBittorrents config at boot (Must change exposed ports to match)  |`WEBUI_PORT=8080`|
|`INCOMING_PORT`| No | Applies Incoming port to qBittorrents config at boot (Must change exposed ports to match) |`INCOMING_PORT=8999`|

## Volumes

| Volume | Required | Function | Example |
|----------|----------|----------|----------|
| `config` | Yes | qBittorrent and OpenVPN config files | `/your/config/path/:/config`|
| `downloads` | No | Default download path for torrents | `/your/downloads/path/:/downloads`|

## Ports

| Port | Proto | Required | Function | Example |
|----------|----------|----------|----------|----------|
| `8080` | TCP | Yes | qBittorrent WebUI | `8080:8080`|
| `8999` | TCP | Yes | qBittorrent listening port | `8999:8999`|
| `8999` | UDP | Yes | qBittorrent listening port | `8999:8999/udp`|

# Access the WebUI

Access <http://IPADDRESS:PORT> from a browser on the same network.

## Default Credentials

| Credential | Default Value |
|----------|----------|
|`WebUI Username`| admin |
|`WebUI Password`| adminadmin |

## Origin header & Target origin mismatch

WebUI\CSRFProtection must be set to false in qBittorrent.conf if using an unconfigured reverse proxy or forward request within a browser. This is the default setting unless changed. This file can be found in the dockers config directory in /qBittorrent/config

## WebUI: Invalid Host header, port mismatch

qBittorrent throws a [WebUI: Invalid Host header, port mismatch](https://github.com/qbittorrent/qBittorrent/issues/7641#issuecomment-339370794) error if you use port forwarding with bridge networking due to security features to prevent DNS rebinding attacks. If you need to run qBittorrent on different ports, instead edit the WEBUI_PORT_ENV and/or INCOMING_PORT_ENV variables AND the exposed ports to change the native ports qBittorrent uses.

# How to configure VPN

## OpenVPN

* Enable openvpn by configuring `VPN_ENABLED` to `yes` and `VPN_TYPE` to `openvpn`.
* Copy over the desired .ovpn file into `/config/openvpn/`. If multiple .ovpn files exists, the first file will be used.
* Configure username and password through `VPN_USERNAME` and `VPN_PASSWORD` or alternativly using the `auth-user-pass` option in the ovpn file.

## Wireguard

* Enable openvpn by configuring `VPN_ENABLED` to `yes` and `VPN_TYPE` to `wireguard`.
* Copy over the desired .conf file into `/config/wireguard/`. If multiple .config files exists, the first file will be used.

## PUID/PGID

User ID (PUID) and Group ID (PGID) can be found by issuing the following command for the user you want to run the container as:

```
id <username>
```
