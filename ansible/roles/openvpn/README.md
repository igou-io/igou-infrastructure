OpenVPN Servers and Clients
===========================

For a list of VPN servers and clients, install OpenVPN and Easy-RSA
packages and generate server and client configurations for OpenVPN
tunnels.  Bring the VPN connections up.

In this role, we follow a model in which all clients initiate tunnel
connections to all servers, building what could be a mesh of
point-to-point VPN connections.

Requirements
------------

For access to OpenVPN and Easy-RSA packages, this role will install
the EPEL repo, if it is not already present.

The hosts in the play must be able to communicate with one another
via TCP/IP or UDP/IP.


Role Variables
--------------

`openvpn_servers`: List of inventory hostnames of the OpenVPN servers.

`openvpn_clients`: List of hostnames of clients.

`openvpn_tunnel_cidr`: OpenVPN tunnel network subnet.  The OpenVPN servers
  will create sub-subnets from this range.  The OpenVPN servers each take
  the first IP address of their allocated subnet.
  The default value is `10.8.0.0/24`

`openvpn_server_proto`: Establish the connection using TCP or UDP.
  The default value is `tcp`

`openvpn_server_port`: The TCP or UDP port for communication with the
  OpenVPN server.
  The default value is `1194`

`openvpn_intra_if`: If the internal network to propagate is not the default
  gateway, it can be defined using its network interface name instead.

Dependencies
------------

None.

Example Playbook
----------------

The following playbook creates VPN tunnels between a server and
some client hosts.

    ---
    # This playbook synchronises timekeeping and establishes an OpenVPN
    # tunnel between a VPN server and a number of clients.

    - hosts:
        - openvpn-servers
        - openvpn-clients
      become: yes
      roles:
        - role: stackhpc.openvpn
          openvpn_servers: "{{ groups['openvpn-servers'] }}"
          openvpn_clients: "{{ groups['openvpn-clients'] }}"
          openvpn_server_proto: "udp"

    ...

Author Information
------------------

- Stig Telfer (<stig@stackhpc.com>)
- Bharat Kunwar (<bharat@stackhpc.com>)
