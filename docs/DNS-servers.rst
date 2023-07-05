.. _DNS-servers:

========================
DNS servers at DTU Fysik
========================

.. Contents::

Domains at DTU Fysik
------------------------

We serve `Domain Name Service (DNS) <http://en.wikipedia.org/wiki/Domain_Name_System>`_ information for our main domain as well as some subsidiary domains:

* fysik.dtu.dk and `reverse-DNS <http://en.wikipedia.org/wiki/Reverse_DNS_lookup>`_

etc.

DNS server configuration
------------------------

The DNS configuration files:

* Named configuration file ``/var/named/chroot/etc/named.conf`` (soft-linked as ``/etc/named.conf``).
* Domain `DNS zone files <http://en.wikipedia.org/wiki/Zone_file>`_ for each domain are located
  in ``/var/named/chroot/var/named/`` (soft-linked as ``/etc/named/``).

  `Reverse-DNS <http://en.wikipedia.org/wiki/Reverse_DNS_lookup>`_ is the lookup of IP-addresses to DNS-names, configured in the files ``*.in-addr.arpa``.

Our authoritative DNS server is::

  <XXX>.fysik.dtu.dk (130.225.86.XX)

Secondary DNS **slave servers**::

  XXX.fysik.dtu.dk
  dns1.dtu.dk
  dns2.dtu.dk

DNS serial number and Time-To-Live (TTL)
----------------------------------------

In each DNS zone file there is a DNS serial number and *Time-To-Live* (TTL) listed at the top, for example::

  $TTL 86400
  @ IN SOA      XXX.fysik.dtu.dk. postmaster.fysik.dtu.dk. (
                2010120900              ; serial number = today's date + 2 bytes
                3600                    ; refresh every hour
                600                     ; retry every 10 minutes
                604800                  ; expire after a week
                86400 )                 ; default of 1 day


DNS server security
-------------------

For reasons of security, our authoritative DNS servers **can not** be used for 
looking up other domains than our own ones (also called `recursive DNS lookups`).
We have DNS caches on our internal networks for this purpose.

The security reasons for this choice are described in D. J. Bernstein's paper
`The importance of separating DNS caches from DNS servers <http://cr.yp.to/djbdns/separation.html>`_.

RedHat DNS server security
--------------------------

RedHat Enterprise Linux uses *SELinux* to create a secure DNS server environment.
In the *man named* man-page you will find the following description:


Red Hat SELinux BIND Security Profile
.....................................

By default, Red Hat ships BIND with the most secure SELinux policy that will not prevent normal BIND operation and will prevent exploitation of all known BIND security vulnerabilities . See the selinux(8)
man page for information about SElinux.

It is not necessary to run named in a chroot environment if the Red Hat SELinux policy for named is enabled. When enabled, this policy is far more secure than a chroot environment.

With this extra security comes some restrictions:
By default, the SELinux policy does not allow named to write any master zone database files. Only the root user may create files in the ``$ROOTDIR/var/named`` zone database file directory 
(the options ``{"directory" }`` option), where ``$ROOTDIR`` is set in ``/etc/sysconfig/named``.
The ``named`` group must be granted read privelege to these files in order for named to be enabled to read them.
Any file created in the zone database file directory is automatically assigned the SELinux file context ``named_zone_t``.

By default, SELinux prevents any role from modifying ``named_zone_t`` files; this means that files in the zone database directory cannot be modified by dynamic DNS (DDNS) updates or zone transfers.
The Red Hat BIND distribution and SELinux policy creates two directories where named is allowed to create and modify files: ``$ROOTDIR/var/named/slaves`` and ``$ROOTDIR/var/named/data``. 
By placing files you want named to modify, such as slave or DDNS updateable zone files and database / statistics dump files in these directories, named will work normally and no further operator action is required. 
Files in these directories are automatically assigned the ``named_cache_t`` file context, which SELinux allows named to write.

You can enable the ``named_t`` domain to write and create ``named_zone_t`` files by use of the SELinux tunable boolean variable ``named_write_master_zones``, using the *setsebool(8)* command or the 
``system-config-security`` GUI. 
If you do this, you must also set the ``ENABLE_ZONE_WRITE`` variable in ``/etc/sysconfig/named`` to 1 / yes to set the ownership of files in the ``$ROOTDIR/var/named`` directory to ``named:named`` in order
for named to be allowed to write them.

Hiding DNS server version
-------------------------

DK-CERT recommends that the DNS server version should be hidden.
One may look up the version of a DNS server by this command::

  nslookup -q=txt -class=CHAOS version.bind. XXX.fysik.dtu.dk.

To change the default version information add these lines to the *options* section in /etc/named.conf::

  // Hide your BIND version:
  version "[SECURED]";

See also http://www.tech-recipes.com/rx/201/hide-your-bind-version/

Firewall rules
--------------

If the DNS server runs the iptables firewall (recommended), then add these lines to ``/etc/sysconfig/iptables``::

  # DNS server (port 53 TCP+UDP)
  -A RH-Firewall-1-INPUT -p tcp -m state --state NEW -m tcp --dport 53 -j ACCEPT
  -A RH-Firewall-1-INPUT -p udp -m state --state NEW -m udp --dport 53 -j ACCEPT

and restart iptables.

DNS slave server fonfiguration
------------------------------

For reasons of security the *named* daemon is **not permitted** to write to the master zone files in ``/var/named/chroot/var/named``.
This presents a problem for DNS slave servers, which must be able to write to disk the DNS zone files for which it is a slave server.

The solution to the DNS slave server problem is documented in the file ``/etc/sysconfig/named``::

  # ENABLE_ZONE_WRITE=yes  --  If SELinux is disabled, then allow named to write
  #                            its zone files and create files in its $ROOTDIR/var/named
  #                            directory, necessary for DDNS and slave zone transfers.
  #                            Slave zones should reside in the $ROOTDIR/var/named/slaves
  #                            directory, in which case you would not need to enable zone
  #                            writes. If SELinux is enabled, you must use only the
  #                            'named_write_master_zones' variable to enable zone writes.

So the conclusion is that **Slave zones should reside in the $ROOTDIR/var/named/slaves directory**.
This must be configured in ``/etc/named.conf``, for example::

  zone "132.2.10.in-addr.arpa" {
        type slave;
        masters { 130.225.86.25; };
        file "slaves/132.2.10.in-addr.arpa";

Changing DNS Time-To-Live (TTL) information for services
----------------------------------------------------------------------

When we migrate an important service from one machine to another (for example, migrating a web-service from *web2* to *web3*),
then the DNS information cached across the Internet must be updated as well, but this can take up to 1 day or longer before it has been propagated everywhere.

The solution to this problem is to **decrease the TTL** (*Time To Live*) DNS information for the service in question,
for example to 1 hour (or less) in stead of our default 24 hours. 
This is done in our primary DNS server in the file ``/etc/named/fysik.dtu.dk``.

The DNS time-to-live should be set to a short period prior to migration, for example 1 hour::

  svn 3600 IN CNAME XXX.fysik.dtu.dk.

When the migration has been completed and tested successfully (wait a few days!),
then you should remove the short TTL value of 3600.

DNS caches
------------------------

The DNS caches on our internal networks, which cannot be reached by external machines for DNS lookups, should be used by all DNS clients 
(desktop machines as well as servers) at FYS.

This is configured in ``/etc/resolv.conf`` (Linux/UNIX static IP configuration), and in ``/etc/dhcpd.conf`` (Windows/Linux DHCP clients).

The DTU Fysik DNS cache servers are::

  XXX

For Niflheim the cache servers are::

  XXX

To make a server a DNS cache server, install this RPM package::

  yum install caching-nameserver


DNS root servers
----------------

The ``/etc/named.conf`` file on caching DNS servers refers to the `DNS root servers <http://en.wikipedia.org/wiki/Root_nameserver>`_ which are static servers for the *Domain Name System's* root zone. 
Download the up-to-date root server file from ftp://ftp.internic.net/domain/named.root

On RHEL/CentOS the RPM package *caching-nameserver* contains this file as ``/var/named/chroot/var/named/named.ca``.
