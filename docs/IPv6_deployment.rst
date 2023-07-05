.. _IPv6_deployment:

=========================================
IPv6 deployment at the departmental level
=========================================

.. Contents::

Introduction
============

This document presents a strategy for deploying an IPv6_ network alongside a pre-existing IPv4_ departmental network.
While this strategy has been tested only at a departmental network at our university, the hope is that it's applicable to any similar type of local area network.

We try to give a step-by-step procedure from no IPv6_ at all to a fully functional IPv6_ network alongside the preexisting IPv4_ network.

To understand our network topology, we have a flat Ethernet network throughout the department.
Connectivity to the university backbone network and the Internet is provided by the university network services, 
who employ `Cisco routers <http://www.cisco.com/en/US/products/hw/routers/index.html>`_ for the networking infrastructure.

Many technical details of IPv6_ network protocols have been described in the accompanying page :ref:`IPv6_configuration`.
To learn about IPv6 in general you should first consult that page.
In particular, you need to understand the new 128-bit IPv6_addressing_.

.. _IPv6: http://en.wikipedia.org/wiki/Ipv6
.. _IPv4: http://en.wikipedia.org/wiki/Ipv4
.. _IPv6_addressing: http://www.ipv6.com/articles/general/IPv6-Addressing.htm

The IPv6_ deployment steps are presented below and may be summarized as:

* Allocate your IPv6_ address range.
* Design IPv6_ firewall rules.
* Manually configure IPv6_ on two or more hosts for testing.
* In your DNS server configure IPv6_ AAAA records for the testing hosts.
* Define your DHCPv6_ address allocation strategy.
* Configure a DHCPv6_ server on your network.
* Enable Router_Advertisements_.

At this point the IPv6_ deployment has been completed.

.. _DHCPv6: http://en.wikipedia.org/wiki/DHCPv6

.. _Router_Advertisements: https://wiki.fysik.dtu.dk/it/IPv6_configuration#router-advertisements

Documentation of IPv6 deployment
--------------------------------

Some links to useful IPv6 deployment documentation:

* `ARIN IPv6 info center <https://www.arin.net/knowledge/ipv6_info_center.html>`_.

* `ARIN IPv6 Wiki <http://getipv6.info/>`_.

* `Employing IPv6 in the enterprise <https://www.arin.net/participate/meetings/reports/ARIN_XXIX/PDF/monday/deccio_enterprise_ipv6panel.pdf>`_
  (from `ARIN XXIX conference <https://www.arin.net/participate/meetings/reports/ARIN_XXIX/ppm.html>`_).

Documentation for DTU departmental network administrators
---------------------------------------------------------

As a prerequisite to the deployment process described below, in the *IT-forum* group's *fildeling* on Campusnet_ you will find IPv6_ deployment documents written by *Hugo Connery* which provide much more technical detail,
and in particular defining the allocation of IPv6_ addresses and security considerations within a department.
DTU's standard IPv6_ firewall rules will probably be all you need to begin with.

.. _Campusnet: https://www.campusnet.dtu.dk/

Define your IPv6 addressing standard
====================================

You must consult your upstream/central networking people to obtain an IPv6_ "subnet".
Usually a /64 (64 bits out of 128) subnet is allocated to the departmental level, for example::

  2001:0878:0200::/48       (university level)
  2001:0878:0200:xxxx::/64  (department level)

Note that an IPv6_ address consists of exactly 8 *quartets* (i.e., 4 hexadecimal digits) separated by : characters.
The notation **::** signifies one or more quartets containing zeroes (can be used only once in an address).
Read more about IPv6_addressing_.

This document assumes that you have chosen appropriate addresses for any fixed-address host in the form::

  2001:0878:0200:xxxx:yyyy::zzzz

where xxxx, yyyy, and zzzz have given values for any host on your network.
Note how **::** means one or more quartets containing zeroes.

Firewall standards
==================

Your network people must configure firewall rules to protect your IPv6_ network.
At DTU we have defined standard firewall rules as described in the above mentioned Campusnet_ documentation (see the document *DTU IPv6 Addressing Standard*).

The main purpose is to expose only your designated servers (for example, web and mail servers) to the Internet,
whereas PC, printers etc. should be fully shielded against access from the outside Internet.

At this stage in the process firewall rules should be planned for, but **no IPv6 traffic** is permitted yet, so firewall rules are for a later stage.

Manual IPv6 address testing
===========================

You want to familiarize yourself with configuring manually IPv6_ on (at least) two hosts on your network.
See :ref:`IPv6_configuration` for some examples on how to configure IPv6_ on various types of operating systems.

You should select computers which do not provide any kind of services, for example, some PCs.
Select addresses such as 2001:0878:0200:xxxx:yyyy::zzzz with different values for zzzz for each host.

First make sure that your testing hosts have IPv6_ enabled in the OS:
They should already have Link_Local_ addresses (network fe80::/10, see IPv6_addressing_) which are non-routable, i.e., confined to your local network.
Check the status of the network interfaces::

  ifconfig -a    (Linux)
  ipconfig /all  (Windows)

For any pairs of hosts, try to ping from one IPv6_ address to the other::

  hostA> ping 2001:0878:0200:xxxx:yyyy::zzzz  (hostB)

On Linux you must use the ``ping6`` command in stead.
Make sure the host firewall permits IPv6_ communication.

Domain Name Service (DNS) setup
===============================

Next step is to define IPv6_ addresses in your authoritative DNS server.
At DTU this may either be a DNS server controlled by the department, or a central DNS server (in which case you must contact the DTU networking people).
The DNS server software must not be too ancient, otherwise IPv6_ may be poorly implemented.

If you have two hosts, hostA and hostB, with manual IPv6_ configuration, add IPv6_ *AAAA records* (pronounced *quad A*) in DNS for the testing hosts alongside with the current IPv4_ *A records*.

For example, the host ns1.fysik.dtu.dk has been configured with these A and AAAA DNS records::

  ns1 IN A    130.225.86.6
      IN AAAA 2001:878:200:2010::6


Test your DNS setup by pinging the **DNS host names**::

  hostA> ping hostB 

On Linux use ``ping6``.

Reverse-DNS IPv6 setup
----------------------

To configure IPv6_ Reverse_DNS_lookup_ (certainly you want this for your servers), your DNS server must be configured for this.
This is a bit more involved than the simple forward DNS lookups.

.. _Reverse_DNS_lookup: http://en.wikipedia.org/wiki/Reverse_DNS_lookup

Whereas IPv4_ uses the special DNS domain *in-addr.arpa.* for reverse DNS, IPv6_ uses the special domain *ip6.arpa*.
As with IPv4_, you also need to contact your upstream (university) network administrator to delegate authority of your reverse-DNS domain to your DNS server.

For example, reverse DNS for the network 2001:878:200:2010::/64 must be delegated to this DNS domain::

  0.1.0.2.0.0.2.0.8.7.8.0.1.0.0.2.ip6.arpa.

where the order of the hexadecimal characters has been reversed and . characters separate the hexadecimal digits (read this from right to left).

Sample configurations for the ISC BIND DNS server is shown in http://www.zytrax.com/books/dns/ch3/#ipv6

Your DNS server must serve reverse DNS lookups for your *ip6.arpa* subdomain.
An example reverse DNS record for the domain 0.1.0.2.0.0.2.0.8.7.8.0.1.0.0.2.ip6.arpa. may be configured in an ISC BIND DNS server like::

  ; Server machines 2001:878:200:2010:0:0:0:x
  $ORIGIN 0.0.0.0.0.0.0.0.0.0.0.0.0.1.0.2.0.0.2.0.8.7.8.0.1.0.0.2.ip6.arpa.
  6.0.0.0 PTR     ns1.fysik.dtu.dk.

Strategies for DHCPv6 address allocations
=========================================

At this stage strategic choices must be made about client authorization and address selection according to your organization's IT security policies.

The Router_Advertisement_flags_ determine how hosts on your local network will configure their IPv6_ addresses:

* RA flag M=off: Clients are **unmanaged** and will form IPv6_ addresses automatically on their own.

* RA flag M=on: Clients are **managed** and must request their IPv6_ addresses from the local DHCPv6_ server.

The **managed** strategy may be required by your organization's IT security policy because it enables the following features:

* Only authorized clients will receive a routable IPv6_ address.
* Unknown clients may be configured to use a local, unroutable IPv6_ address space.
* Trackability of clients doing network traffic violating your IT security policy. 

The **unmanaged** strategy will prohibit the above IT security related points.
This may be acceptable in a public area network, for example.

.. _Router_Advertisement_flags: https://wiki.fysik.dtu.dk/it/IPv6_configuration#router-advertisement-flags

For further information read the dhcpv6-service_ page.

Setting up a DHCPv6 server
==========================

It is **mandatory** that your network has a DHCPv6_ server on your local network.
At a minimum the DHCPv6 service has the following function:

* Inform DHCPv6 clients about the addresses of their local recursive DNS_resolvers_.

Optionally, a number of other data may be offered by the DHCPv6_ server, for example:

* Your own DNS domain name.
* DNS domain search list.

For further information read the dhcpv6-service_ page.

.. _dhcpv6-service: https://wiki.fysik.dtu.dk/it/IPv6_configuration#dhcpv6-service

.. _DNS_resolvers: http://en.wikipedia.org/wiki/Domain_Name_System#DNS_resolvers


Testing the DHCPv6 service
--------------------------

Even in the absence of Router_Advertisements_, you can start the dhcpv6-service_ and test it.
The DHCPv6_ server will be listening on port 547 and offer DHCPv6_ address leases to all IPv6_-enabled clients.
You should monitor the server's log to see if things are working correctly.

Client machines IPv6_ address setup should be monitored at this stage to make sure the correct IPv6_ addresses have been assigned from the DHCPv6_ server.
Any additional automatically formed IPv6_ addresses (besides the required fe80:: Link_Local_ network) outside the scope of the DHCPv6_ server should be investigated,
as it may point to incorrect configuration.

See the above section *Manual IPv6 address testing*.
Further information is in the OS-specific subsections in :ref:`IPv6_configuration` for various operating systems (Windows, Linux) which we have tested.

.. _Link_Local: http://en.wikipedia.org/wiki/Link-local_address

Enabling IPv6: Router Advertisements
====================================

Hosts on your network will not configure routable IPv6_ addresses until Router_Advertisements_ (RA) are being sent on the Link_Local_ (see IPv6_addressing_) IPv6_ local network.

The following steps are required:

1. **Router firewall rules** must be enabled at this stage!
   From an external network, try to access any internal IPv6_ hosts to make sure your firewall is working correctly!

2. **Open your router for IPv6 traffic** flowing between your local network and the Internet.

3. Now comes the **final turning point** where IPv6 will be activated on all IPv6-enabled hosts on your network:

   * You must be very careful that all of the above prerequisites have been successfully configured and tested before proceeding!

4. Router_Advertisements_ must be configured differently depending on your DHCPv6_ addressing standard:

   * Auto-configured **unmanaged** IPv6_ addresses: The RA prefix length **must** be included in the RAs.
   * DHCPv6_ **managed** addresses: The RA prefix length **must not** be included in the RAs or,
     alternatively, the Router_Advertisement_flags_ field "A" (*Address Configuration Flag*) must be set to *off*.

Testing IPv6
------------

Test IPv6_ connectivity from inside your network to external IPv6_ hosts.
For example::

  ping www.google.com

On Linux use ``ping6``.

**At this stage IPv6 is fully functional in your network**.

Using DNS to define servers and hosts accessible by IPv6
========================================================

No internal servers or hosts are offering IPv6_ services at this stage because you haven't yet configured their IPv6_ addresses in DNS 
(except possibly for the above mentioned testing hosts)!

The continued IPv6_ deployment strategy is now:

* Configure IPv6_ manually or through DHCPv6_ on the servers and other hosts which you want to provide services via IPv6_.

* Check the IPv6_ firewall rules in the hosts offering services (for example, a web-server must permit access to ports 80 and 443).

* Test access to the host's services through its IPv6_ address (for example, 2001:878:200:2010::6).

* When the service is working correctly, add an AAAA DNS record to the pre-existing IPv4_ A record.
  Do not forget to add also reverse DNS records as described above!

At this point client machines will become aware of the server's IPv6_ address by means of its AAAA DNS record.
Most operating systems will preferentially use IPv6_, and only if this fails attempt communication by IPv4_ (after some timeout period).

Of course, clients may not yet be configured to use IPv6_ at this stage.
Therefore you must continue to provide services to both IPv4_ and IPv6_ clients!

You can now use DNS AAAA records to control client usage of IPv6_ in a normal mode of operations,
just as you have done in the past using IPv4_.
