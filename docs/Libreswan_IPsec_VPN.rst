.. _Libreswan_IPsec_VPN:

===================
Libreswan IPsec VPN
===================

.. Contents::

For a *Site-to-site* VPN_ tunnel from a cloud service (for example, Azure_) to the local on-premise network, a Libreswan_ *Virtual private network* (VPN_) router with *Internet Protocol Security* (IPsec_) can be used.

Libreswan_ is a free software implementation of the most widely supported and standardized VPN_ protocol using IPsec_ and the *Internet Key Exchange* (IKE_). 

In Red Hat Enterprise Linux 8 (RHEL_ 8), a virtual private network (VPN_) can be configured using the IPsec_ protocol, which is supported by the Libreswan_ application. 
Some information pages about VPN_ setups:

* `Chapter 3. Configuring a VPN with IPsec <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/securing_networks/configuring-a-vpn-with-ipsec_securing-networks>`_.
* `Run your own VPN with Libreswan <https://www.redhat.com/sysadmin/run-your-own-vpn-libreswan>`_.
* `Using LibreSwan with Azure VPN Gateway <https://reinhardt.dev/posts/azure-vpn-using-libreswan/>`_.
* Setting up a VPN_ router to GCP_ is discussed in the page 
  `A libreswan configuration that works with Google Cloud VPN (Classic) <https://none.is/2019/11/libreswan-and-google-cloud-vpn-classic/>`_.

.. _IPsec: https://en.wikipedia.org/wiki/IPsec
.. _Azure: https://azure.microsoft.com/en-us/
.. _GCP: https://cloud.google.com/
.. _RHEL: https://en.wikipedia.org/wiki/Red_Hat_Enterprise_Linux
.. _VPN: https://en.wikipedia.org/wiki/Virtual_private_network
.. _IKE: https://en.wikipedia.org/wiki/Internet_Key_Exchange
.. _IKEv2: https://en.wikipedia.org/wiki/Internet_Key_Exchange
.. _RFC7296: https://tools.ietf.org/html/rfc7296

Libreswan installation on EL8
=============================

The RHEL_ 8 (as well as EL8_clones_ such as AlmaLinux_ and RockyLinux_) offer an RPM package for Libreswan_ version 4.4.

Install the Libreswan_ package by::

  dnf install libreswan

There are some Libreswan_ examples:

* `Configuration examples <https://libreswan.org/wiki/Configuration_examples>`_ including an `Azure example <https://libreswan.org/wiki/Microsoft_Azure_configuration>`_.

* LibreSwan_: `Route-based VPN using VTI <https://libreswan.org/wiki/Route-based_VPN_using_VTI>`_.

* Oracle Cloud `Access to Other Clouds with Libreswan <https://docs.cloud.oracle.com/en-us/iaas/Content/Network/Concepts/libreswan.htm>`_.

.. _Libreswan: https://libreswan.org/
.. _ESP: https://en.wikipedia.org/wiki/IPsec#Encapsulating_Security_Payload
.. _RFC4303: https://www.ietf.org/rfc/rfc4303.txt
.. _EL8_clones: https://en.wikipedia.org/wiki/Red_Hat_Enterprise_Linux_derivatives
.. _AlmaLinux: https://almalinux.org/
.. _RockyLinux: https://rockylinux.org/

Network firewall setup
======================

If your organization has a firewall device protecting your external (Internet faced) network perimeter, 
it is necessary to configure that firewall to allow 500 and 4500/UDP ports for the IKE_ (defined in RFC7296_), ESP_ (defined in RFC4303_), 
and AH_ (not used) protocols bidirectionally **to** and **from** the remote cloud service::

  IP UDP Port 500 
  IP UDP Port 4500 
  ESP protocol 50

In addition, the Linux firewalld_ must be configured, see `Firewalld setup`_ below.

.. _AH: https://en.wikipedia.org/wiki/IPsec#Authentication_Header

Libreswan tunnel connection
===========================

The following configuration examples have been shown to work (in May 2022) with the Azure_ cloud and a local VPN_ gateway running Red Hat RHEL_ 8.6 (or the EL8 clones of RHEL_ 8).

Configuration files are created in the ``/etc/ipsec.d/`` directory and should be named for each VPN_ tunnel (here ``azure.conf`` and ``azure.secrets``).

First create the file ``/etc/ipsec.d/azure.conf``::

  conn azure
    authby=secret
    auto=start
    dpdaction=restart
    dpddelay=30
    dpdtimeout=120
    ike=aes256-sha1;modp1024
    ikelifetime=3600s
    pfs=yes
    esp=aes128-sha1
    salifetime=3600s

Some parameters will then take their *default values* which you **should not modify**, see ``man ipsec.conf``.
Important defaults are:

* **ikev2=insist**
  Please note a RHEL_ 8 modification of the upstream Libreswan_ where RHEL_ 8 uses ``ikev2=<insist|no>`` in stead of ``<yes|no>``, see ``man ipsec.conf``.

* **type=tunnel**

* **encapsulation=auto**
  (forceencaps is obsoleted)

Second, determine the **public IP-address** of your local VPN gateway as well as the public IP of the Azure_ VPN_ gateway.
We use these example-only addresses:

* Local VPN gateway public address: 123.45.67.89
* Azure VPN gateway public address: 20.21.22.23

Add your specific IP-addresses and subnets after the ``conn`` parameter in the above file ``/etc/ipsec.d/azure.conf`` (the values here are just examples!)::

  conn azure
    left=123.45.67.89        # Local VPN gateway public address
    leftsubnet=10.2.0.0/16   # Local subnet
    leftsourceip=10.2.0.1    # Local VPN gateway on the local private subnet
    right=20.21.22.23        # Azure VPN gateway public address
    rightsubnet=10.0.0.0/16  # Azure subnet
    ....

The ``leftsourceip`` is relevant only locally, and the other end need not agree. 
This option is used to make the gateway itself use its internal IP, which is part of the leftsubnet, to communicate to the rightsubnet or right.

Third, generate a really random secret *Pre-Shared Key* (PSK_) string, see the ipsec.secrets_ manual page.

.. _ipsec.secrets: https://libreswan.org/man/ipsec.secrets.5.html

You may use the output from one of these Linux commands
(see `Generate a strong pre-shared key  <https://cloud.google.com/network-connectivity/docs/vpn/how-to/generating-pre-shared-key>`_)::

  openssl rand -base64 24
  head -c 24 /dev/urandom | base64

.. _PSK: https://en.wikipedia.org/wiki/Pre-shared_key

The PSK_ value used must of course also be identically configured in the Azure_ VPN gateway **Shared key** value,
see the `VPN Gateway FAQ <https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-vpn-faq>`_.

Now create the file ``/etc/ipsec.d/azure.secrets`` (the values here are just examples!)::

  123.45.67.89 20.21.22.23 : PSK "mEEVg4KXSl5nFJk3yDZbSj7wTNN5wxFt"

The PSK_ value should be enclosed in quotes (**"**) as shown.

The value **%any** signifies an IP-address to be filled in (by automatic keying) during negotiation, see the ipsec.secrets_ manual page::

  %any %any : PSK "mEEVg4KXSl5nFJk3yDZbSj7wTNN5wxFt"

Make sure the file is only readable by root::

  chmod 0600 /etc/ipsec.d/azure.secrets

Now you may enable, start and check the **ipsec** service::

  systemctl enable ipsec --now
  systemctl status ipsec

Verify and view the IPsec_ connections status by::

  ipsec verify
  ipsec status

If there are errors from the status command you should examine the ``/var/log/secure`` logfile.
You can also try this command::

  ipsec pluto --config /etc/ipsec.conf --nofork

If the encryption methods are mismatched, look for lines like this one::

  no local proposal matches remote proposals
  1:IKE:ENCR=AES_CBC_256;INTEG=HMAC_SHA1_96;PRF=HMAC_SHA1;DH=MODP1024
  2:IKE:ENCR=AES_CBC_256;INTEG=HMAC_SHA2_256_128;PRF=HMAC_SHA2_256;DH=MODP1024
  3:IKE:ENCR=AES_CBC_128;INTEG=HMAC_SHA1_96;PRF=HMAC_SHA1;DH=MODP1024
  4:IKE:ENCR=AES_CBC_128;INTEG=HMAC_SHA2_256_128;PRF=HMAC_SHA2_256;DH=MODP1024
  5:IKE:ENCR=3DES;INTEG=HMAC_SHA1_96;PRF=HMAC_SHA1;DH=MODP1024
  6:IKE:ENCR=3DES;INTEG=HMAC_SHA2_256_128;PRF=HMAC_SHA2_256;DH=MODP1024

In this case replace the above ``ike=`` line by one of the options, for example::

  ike=AES_CBC_256;MODP1024

and restart the ``ipsec`` service.

Firewalld setup
===============

The IPsec_ VPN_ gateway server must have its internal firewall configured.

Configure firewalld_ to permit routing of VPN_ tunnel IPsec_ traffic::

  firewall-cmd --add-service="ipsec"

Add the local IP subnet (10.2.0.0/16 in the present example) to firewalld_trusted_zone_::

  firewall-cmd --zone=trusted --add-source=10.2.0.0/16

Make these changes permanent::

  firewall-cmd --runtime-to-permanent

List the contents of the firewalld_trusted_zone_::

  firewall-cmd --zone=trusted --list-all

.. _firewalld_trusted_zone: https://firewalld.org/documentation/man-pages/firewalld.zones.html
.. _firewalld: https://en.wikipedia.org/wiki/Firewalld

Configure IPsec gateway to route VPN traffic
============================================

When the IPsec_ VPN_ router is working correctly, the next step is to configure IP packet forwarding.
Append this line to ``/etc/sysctl.conf``::

  net.ipv4.ip_forward=1

Disable IPv6::

  net.ipv6.conf.default.disable_ipv6=1

The *Reverse Path Forwarding filtering subsystem* related to IP spoofing protection must be turned off on both gateways for IPSEC to work properly, see:

* https://access.redhat.com/solutions/53031::

    The most simple way to disable the strict check is to set the sysctl net.ipv4.conf.all.rp_filter=2 (loose) as this will override the interface-specific settings.
    Setting net.ipv4.conf.all.rp_filter=0 (disabled) does not override interface-specific settings so is not recommended.

  (See also this `LibreSwan FAQ <https://libreswan.org/wiki/FAQ#Why_is_it_recommended_to_disable_rp_filter_in_.2Fproc.2Fsys.2Fnet_.3F>`_)

Add this in ``/etc/sysctl.conf``::

  net.ipv4.conf.all.rp_filter=2

Now reload sysctl::

  sysctl -p

Route IP traffic via the VPN tunnel
-----------------------------------

For those hosts on the on-premise network that need to send IP traffic to the cloud nodes through the VPN_ tunnel gateway,
you have to add a route command, for example::

  ip route add 10.0.0.0/16 via 10.2.0.1

where 10.2.0.1 is the VPN_ gateway's local IP address and 10.0.0.0/16 is the IP subnet in the cloud service.
This configuration will disappear when the host is rebooted.

To make manual routes persistent across reboots on EL8 hosts, you could add the above command to the ``/etc/rc.local`` script.
Remember to make it executable::

  chmod +x /etc/rc.local

Another method is to determine the interface which the host uses to send traffic to the gateway (10.2.0.1 in the above example).
Assume the interface name is *eno49*.

Configure the routing file for the ``/etc/sysconfig/network-scripts/route-eno49`` interface::

  ADDRESS0=10.0.0.0
  NETMASK0=255.255.0.0
  GATEWAY0=10.2.0.1

Then update the NetworkManager_::

  nmcli device reapply eno49

and check the routes with::

  netstat -r

Perhaps it may be necessary to reboot the server.

See:

* `How To Persist ip Rule And Route Whenever Server Rebooted? <https://unix.stackexchange.com/questions/365380/how-to-persist-ip-rule-and-route-whenever-server-rebooted>`_.
* `4.4. Configuring Static Routes with ip commands <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/networking_guide/sec-configuring_static_routes_with_ip_commands>`_.
* `4.5. Configuring Static Routes in ifcfg files <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/networking_guide/sec-configuring_static_routes_in_ifcfg_files#bh-Static_Routes_Using_the_IP_Command_Arguments_Format>`_.

.. _NetworkManager: https://en.wikipedia.org/wiki/NetworkManager

ipsec commands
==============

Optional information about some IPsec_ commands:

Libreswan_ provides the ipsec_command_, see::

  ipsec --help

.. _ipsec_command: https://linux.die.net/man/8/ipsec

Libreswan_ uses a local database to keep track of authentication keys and identity certificates, so initialize the key database on each computer::

  ipsec initnss

Check the current CKAID keys::

  ipsec showhostkey --list

If no keys exist, generate a CKAID key for each machine (see ``man ipsec_showhostkey``)::

  ipsec newhostkey 
  ipsec showhostkey --list
