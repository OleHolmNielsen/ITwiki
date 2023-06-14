.. _Linux_firewall_configuration:

===============================================
Linux firewall and SSH protection configuration
===============================================

.. Contents:: Contents of this page:
   :depth: 2

The Linux kernel's built-in firewall function (netfilter_ packet filtering framework) is administered by the iptables_ Linux command.

.. _iptables: http://en.wikipedia.org/wiki/Iptables
.. _netfilter: https://en.wikipedia.org/wiki/Netfilter

General information about the concept of a firewall_.

.. _firewall: http://en.wikipedia.org/wiki/Firewall_%28computing%29

The documentation on this page includes:

* IP_sets_ for handling large numbers of subnets.
  This is useful for special treatment of entire countries or large ISPs, for example, by iptables_.
* SSH brute force attacks handled by iptables_.
* SSH failed logins causing blacklisting using sshblack_ and iptables_.

RHEL7/CentOS7 and Fedora firewalld
==================================

A nice introduction is `RHEL7: How to get started with Firewalld <https://www.certdepot.net/rhel7-get-started-firewalld/>`_.

The default firewall service is now firewalld_, which is a front-end service on top of the iptables_ service.
The dynamic firewall daemon firewalld_ provides a dynamically managed firewall with support for network “zones” to assign a level of trust to a network and its associated connections and interfaces. 
See `Introduction to firewalld <https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Security_Guide/sec-Using_Firewalls.html>`_.

.. _firewalld: https://fedoraproject.org/wiki/FirewallD

A graphical configuration tool::

  firewall-config

is used to configure firewalld_, which in turn uses iptables_ tool to communicate with netfilter_ in the kernel which implements packet filtering. 

A command line (CLI) configuration tool::

  firewall-cmd

may also used to configure firewalld_.
To make any new rule permanent, run the command with the ``--permanent`` flag.
See the manual firewall-cmd_ for further information.

The firewalld_ configuration files are in the directory ``/etc/firewalld/zones/`` where XML files contain the firewall rules.

See firewalld_ log messages in::

  /var/log/firewalld

Whitelisting IP addresses with firewalld
----------------------------------------

It is important to be able to whitelist internal IP addresses.
Insert a firewalld_ direct_rule_ so that any incoming source IP packet (src) from a specific IP subnet gets accepted, for example::

  firewall-cmd --direct --add-rule ipv4 filter INPUT_direct 0 -s 192.168.1.0/24 -j ACCEPT

To make the rule **permanent**, run the command with the ``--permanent`` flag.

To open a specific port NNNN::

  firewall-cmd --zone=public --add-port=NNNN/tcp --permanent

Then remember to reload the firewall for changes to take effect::

  firewall-cmd --reload

Here the value 0 is the priority of the rule (smaller numbers have higher priority, so 0 is the highest priority).
Make sure that other direct rules (which might interfere with the whitelist) have a lower priority.

List the rules by::

  firewall-cmd  --permanent --direct --get-all-rules

Iptables IP sets and country blocking
=====================================

IP_sets_ are a framework inside the Linux 2.4.x and 2.6.x kernel which can be used efficiently to create firewall rules for large numbers of IP subnets.

Depending on the type, currently an IP set may store IP addresses, (TCP/UDP) port numbers or IP addresses with MAC addresses in a way, which ensures lightning speed when matching an entry against a set.
The IP_sets_ can be administered by the ipset_ utility. 

.. _IP_sets: http://ipset.netfilter.org/
.. _ipset: http://ipset.netfilter.org/ipset.man.html

Install IP_sets_ by::

  yum install ipset                # RHEL/CentOS 6 and 7

Read the ``man ipset`` manual page.

Country IP blocks
-----------------

There are providers of country IP blocks available for download and eventual inclusion into IP_sets_ block lists:

* `Country IP Blocks <https://www.countryipblocks.net/country_selection.php>`_ (up-to-date service commercially available).
* `Block Visitors by Country <http://www.ip2location.com/free/visitor-blocker>`_.
* IPdeny_ (contains all country zone files)
* `freegeoip.net <http://freegeoip.net>`_ is a public REST API for searching geolocation of IP addresses and host names.

.. _IPdeny: http://www.ipdeny.com/ipblocks

For example,
the IP blocks for China may start with::

  1.0.1.0/24
  1.0.2.0/23
  1.0.8.0/21
  ...

Country **IPv6** blocks may be found at IPdeny_ or https://www.countryipblocks.net/ipv6_cidr.php.

For discussions see:

* `How to block countries with ipdeny IP country blocks, ipset and iptables on EL6 <http://blog.laimbock.com/2013/09/22/how-to-block-countries-with-ipdeny-ip-country-blocks-ipset-and-iptables-on-el6/>`_.
* `Allow only a country with iptables <https://www.centos.org/forums/viewtopic.php?t=9146>`_.

Create a country geoblock ipset
...............................

We use the IPdeny_ *all countries* zone files and create an IP set which we name *geoblock*.
We offer a simple script which automatically creates an ipset_ *geoblock* data file.
Download this :download:`Makefile <attachments/Makefile>` to a new directory.

Edit the *COUNTRYLIST* list variable according to your needs, then run::

  make

to create the *IPSET_DATA* file ``/etc/sysconfig/ipset``.

Tor exit node blocking
----------------------

If you wish to block port-scanning from Tor_ **exit nodes** then you may download the dynamically updated torbulkexitlist_ file.

The torbulkexitlist_ file contains a list of IP-addresses which may be considered as a "country named Tor" and simply added as another zone file like in the above country blocks, for example ``tor.zone``.

.. _Tor: https://en.wikipedia.org/wiki/Tor_(network)
.. _torbulkexitlist: https://check.torproject.org/torbulkexitlist

Using ipsets in firewalld on RHEL/CentOS 7.3 and above
======================================================

According to the `RHEL 7.3 Release Notes <https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html-single/7.3_Release_Notes/index.html>`_, 
firewalld_ has been upgraded from version 0.3.9 to 0.4.3:

* ipset_ support: firewalld_ now supports ipsets used as zone sources, within rich and direct rules. (`BZ#1302802 <https://bugzilla.redhat.com/show_bug.cgi?id=1302802>`_) 

The ipset_ must be configured directly in firewalld_.
Do **not** try to run the Systemd_ service ``ipset`` service together with the firewalld_ 0.4 ``firewalld`` service (as we did previously).
See manual pages for firewalld.ipset_, firewalld.zone_ and firewall-cmd_.

.. _firewalld.ipset: http://www.firewalld.org/documentation/man-pages/firewalld.ipset.html
.. _firewalld.zone: http://www.firewalld.org/documentation/man-pages/firewalld.zone.html
.. _firewall-cmd: http://www.firewalld.org/documentation/man-pages/firewall-cmd.html
.. _Systemd: https://en.wikipedia.org/wiki/Systemd

The procedure for RHEL/CentOS 7.3 is:

* As a prerequisite create the data file ``/etc/sysconfig/ipset`` as shown above.

*  Create a new ipset called ``geoblock``, optionally specifying a larger maximum number of elements in the list::

    firewall-cmd --permanent --new-ipset=geoblock --type=hash:net [ --option=hashsize=65536 --option=maxelem=524288 ]

  See firewall-cmd_ for the ``--option`` flags.

* Add ipset ``geoblock`` to the zone named drop_ ::

    firewall-cmd --permanent --zone=drop --add-source=ipset:geoblock

* Now load ipset_ data::

    firewall-cmd --permanent --ipset=geoblock --add-entries-from-file=/etc/sysconfig/ipset

* Reload the firewalld_ service::

    firewall-cmd --reload

See the manual firewall-cmd_ section *IPSet Options* for a list of ipset_ subcommands.

To list all ipset_ entries::

  firewall-cmd --permanent --ipset=geoblock --get-entries

.. _drop: https://fedoraproject.org/wiki/Firewalld#drop

Using ipsets in firewalld on RHEL/CentOS 8
==========================================

In RHEL/CentOS 8 the ipset_ setup works similarly to the above description for 7.3 (and above).

There is an important problem, however, in CentOS 8.3:

* **Overlapping network ranges in the IPsets causes firewalld failures**.

This is described in Bugzilla_1836571_ *firewalld startup failure: COMMAND_FAILED: 'python-nftables' failed: internal:0:0-0: Error: Could not process rule: File exists* (reported on Fedora FC32).
See error messages in `Comment 12 <https://bugzilla.redhat.com/show_bug.cgi?id=1836571#c12>`_.

The current status (Dec. 2020) is:

1. firewalld needs to use the "auto-merge" feature of sets to a allow element coalescing.

2. The nftables_ "auto-merge" feature was introduced in `release 0.8.2 <https://lwn.net/Articles/746346/>`_.

**Conclusion: Do not (accidentally) use overlapping IPsets in CentOS 8.3.**

.. _Bugzilla_1836571: https://bugzilla.redhat.com/show_bug.cgi?id=1836571
.. _nftables: https://wiki.nftables.org/wiki-nftables/index.php/Main_Page

Aggregate CIDR addresses
------------------------

To circumvent the CentOS 8 Firewalld_ failures in case of overlapping IP ranges, there exist several tools:

1. Python tool aggregate6_.

   First install prerequisites::

     dnf install gcc platform-python-devel

   Then install by::

     pip3 install aggregate6 --user

   Usage::

     ~/.local/bin/aggregate6 --help

2. Perl script aggregate-cidr-addresses_ which takes a list of CIDR address blocks and combine them without overlaps.
   We have a copy of the :download:`aggregate-cidr-addresses.pl <attachments/aggregate-cidr-addresses.pl>` file, download it to ``/usr/local/bin/``.

   Install prerequisite Perl modules::

     dnf install perl-Net-IP

   Usage::

     cat file1 file2 ... fileN | aggregate-cidr-addresses.pl

.. _aggregate6: https://github.com/job/aggregate6
.. _aggregate-cidr-addresses: https://gist.github.com/denji/17e30bddb9ce9e50294a

Testing the ipset service
-------------------------

Testing the ipset_:

* List all the sets in ipset_::

    ipset save

* Test whether an IP address (here: 111.222.33.44) is in a given IPset *geoblock*::

    ipset test geoblock 111.222.33.44

Flush the ipset_ kernel table for this IPset::

  ipset flush geoblock

This may be required if you delete ipset_ entries - subsequently you should restart the IPset service.

Enabling the ipset service on RHEL/CentOS 7.0, 7.1 and 7.2
==========================================================

RHEL/CentOS 7.0, 7.1 and 7.2 (which use Systemd_) do **not** have a method for starting an ipset_ service. 
This has been fixed in later releases.

A workaround exists for enabling the *ipset service* on RHEL7/CentOS7 using scripts from Fedora:

* Download the Fedora 22 src rpm from http://rpm.pbone.net/index.php3/stat/4/idpl/28726591/dir/fedora_other/com/ipset-6.22-1.fc22.i686.rpm.html
* Install the src rpm and copy the ipset service files to the system::

    mkdir /usr/libexec/ipset /etc/ipset
    rpm -ivh ipset-6.22-1.fc22.src.rpm
    cd ~/rpmbuild/SOURCES/
    cp -p ipset.start-stop /usr/libexec/ipset/ipset.start-stop
    cp -p ipset.service /usr/lib/systemd/system/ipset.service
    chmod 755 /usr/lib/systemd/system/ipset.service /usr/libexec/ipset/ipset.start-stop

See below for how to start the *ipset service*.

Using ipset with firewalld (RHEL7/CentOS7 and Fedora)
-----------------------------------------------------

Insert an firewalld_ direct_rule_ so that any incoming source IP packet (src) gets matched against the set of IP addresses in geoblock::

  firewall-cmd --direct --add-rule ipv4 filter INPUT_direct 1 -m set --match-set geoblock src -j DROP

.. _direct_rule: https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Security_Guide/sec-Using_Firewalls.html#sec-Understanding_the_Direct_Interface

Here the value *1* is the *priority* of the rule (smaller numbers have higher priority, so 0 is the highest priority).

Verify the new rule::

  firewall-cmd --direct --get-all-rules | grep geoblock

If testing is OK, you can make this rule permanent::

  firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT_direct 1  -m set --match-set geoblock src -j DROP

The file ``/etc/firewalld/direct.xml`` will contain this direct_rule_.

Blocking SSH brute force attacks with firewalld (RHEL7/CentOS7 and Fedora)
==========================================================================

See these pages:

* http://itnotesandscribblings.blogspot.com/2014/08/firewalld-adding-services-and-direct.html
* http://serverfault.com/questions/683671/is-there-a-way-to-rate-limit-connection-attempts-with-firewalld

These commands may be tried::

  firewall-cmd --direct --add-rule ipv4 filter INPUT_direct 2 -p tcp --dport 22 -m state --state NEW -m recent --set
  firewall-cmd --direct --add-rule ipv4 filter INPUT_direct 3 -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 30 --hitcount 4 -j REJECT --reject-with tcp-reset

Note: Logging to syslog is missing from this setup.
Apparently firewalld_ is **incapable of logging rejected or accepted packets**, see:

* https://bluehatrecord.wordpress.com/2014/04/17/logging-packet-drops-in-firewalld/
* https://ask.fedoraproject.org/en/question/45014/how-to-log-drops-and-rejects-by-firewalld/

When tested OK, add the ``--permanent`` flag to the above commands.

sshblack -- Automatically BLACKLIST SSH attackers 
=================================================

The sshblack_ script is a real-time security tool for secure shell (ssh). 
It monitors -nix log files for suspicious activity and reacts appropriately to aggressive attackers by adding them to a "blacklist" 
created using various firewalling tools -- such as iptables_ -- available in most modern versions of Unix and Linux. 
The blacklist is simply a list of source IP addresses that are prohibited from making ssh connections to the protected host. 
Once a predetermined amount of time has passed, the offending IP address is removed from the blacklist.

**NOTICE:** Since modern RHEL (and clones) as well as Fedora
use firewalld_ in stead of iptables_, the sshblack_ version 2.8.1 from the web-site **does not work**.
All ``iptables`` commands in the sshblack_ scripts need to be replaced by similar ``firewall-cmd`` commands.

See also this page `Further Securing OpenSuSE 11.1 Against SSH Script Attacks <https://www.suse.com/communities/conversations/further-securing-opensuse-111-against-ssh-script-attacks/>`_.

.. _sshblack: http://www.pettingers.org/code/sshblack.html

Installing and configuring sshblack
-----------------------------------

Unpack the sshblack_ tar-ball,
a local copy is here: :download:`sshblackv281.tar.gz <attachments/sshblackv281.tar.gz>`.
Consult the sshblack_install_ instructions,
a local copy is here: :download:`sshblack-install.txt <attachments/sshblack-install.txt>`.

.. _sshblack_install: http://www.pettingers.org/media/sshblack-install.txt

Copy the executable files to a standard executable directory::

  cp sshblack.pl bl unbl list unlist /usr/local/sbin/

Configure the ``sshblack.pl`` script, at a minimum define the sshblack_Whitelist_ for your local network by tailoring this line::

  my($LOCALNET) = '^(?:127\.0\.0\.1|192\.168\.0)';

.. _sshblack_Whitelist: http://www.pettingers.org/code/sshblack-whitelist.html

For security reasons the sshblack_ *CACHE* should be in a private directory rather than the world-writable volatile directory ``/var/tmp``, for example::

  my($CACHE) = '/var/lib/sshblack/ssh-blacklist-pending';

**Note:** The same *CACHE* variable must also be defined in the helper scripts ``list`` and ``unlist``.

Create the private directory (RHEL/CentOS conventional location)::

  mkdir -v -p /var/lib/sshblack

Other configurable parameters include::

  my($REASONS) = '(Failed password|Failed none|Invalid user)';
  my($AGEOUT) = 600;
  my($RELEASEDAYS) = 4;
  my($CHECK) = 300;
  my($MAXHITS) = 4;
  my($DOSBAIL) = 200;
  my($CHATTY) = 1;
  my($EMAILME) = 1;
  my($NOTIFY) = 'root';

Some malformed SSH attacks generate log entries like::

  sshd[30179]: Received disconnect from 206.191.151.226: 11: Bye Bye [preauth]

To blacklist such IPs add an additional rule::

  my($REASONS) = '(Failed password|Failed none|Invalid user|Bye Bye \[preauth\])';

See also the sshblack_config_ page for additional advice.

.. _sshblack_config: http://www.pettingers.org/code/sshblack-config.html

sshblack logfiles
-----------------

The sshblack_ logs to this file, so make sure it exists::

  touch /var/log/sshblacklisting

It is a good idea to rotate this logfile on a weekly basis, so create the file ``/etc/logrotate.d/sshblacklisting`` with the contents::

  # Log rotation configuration for SSH blacklisting
  /var/log/sshblacklisting {
	missingok
	notifempty
	weekly
  }

Configuring the sshblack service
---------------------------------

On RHEL (and clones) as well as Fedora Linux you should set up a Systemd_ startup script (and not run the ``sshblack.pl`` command manually).

EL8/EL9/Fedora and sshblack
..................................

A Systemd_ service file :download:`sshblack.service <attachments/sshblack.service>` must be installed::

  cp sshblack.service /etc/systemd/system/
  chmod 755 /etc/systemd/system/sshblack.service
  systemctl enable sshblack.service

CentOS7/RHEL7 and sshblack
................................

An EL7-specific startup script :download:`init-sshblack-el7 <attachments/init-sshblack-el7>`
must be used for RHEL7/CentOS7/Fedora with Systemd_ and firewalld_.
Install a Systemd_ service file :download:`sshblack.service-el7 <attachments/sshblack.service-el7>`.

Now add the service and create the private sshblack_ directory::

  mkdir /usr/libexec/sshblack
  cp init-sshblack-el7 /usr/libexec/sshblack/init-sshblack
  cp sshblack.service-el7 /etc/systemd/system/sshblack.service
  chmod 755 /usr/libexec/sshblack/init-sshblack /etc/systemd/system/sshblack.service
  systemctl enable sshblack.service

Configure a firewalld chain
................................

Create a *SSHBLACK* iptables_ chain::

  firewall-cmd --permanent --direct --add-chain ipv4 filter BLACKLIST

Then make all new connections to port 22 (SSH) jump to the *BLACKLIST* chain::

  firewall-cmd --direct --add-rule ipv4 filter INPUT_direct 7 -p tcp --dport 22 -m state --state NEW  -j BLACKLIST

It is possible to drop packets from specific IP-addresses and subnets using *rich rules* like::

  firewall-cmd --permanent --add-rich-rule="rule family='ipv4' source address='192.168.0.11' drop"

but we don't use this yet.

Starting the sshblack service
----------------------------------

The sshblack_ daemon must be started::

  systemctl start sshblack.service

There are some useful sshblack_notes_ explaining some additional useful commands:

* list -- manually adds an IP address to the blacklist and modifies the $CACHE file accordingly
* unlist -- manually remove an IP address from the blacklist and the $CACHE file
* bl -- a manual blacklisting tool (one liner that modifies the iptables_ configuration only)
* unbl -- a manual UNblacklisting tool (one liner that modifies the iptables_ configuration only)
* iptables-setup -- a few shell commands to set up the iptables_ chains if you don't want to do it manually.

.. _sshblack_notes: http://www.pettingers.org/code/sshblack-notes.html

If you want a list of blacklisted IP-addresses, display the BLACKLIST chain::

  iptables -S BLACKLIST

Checkpoint and restart of sshblack
----------------------------------

The ``sshblack.pl`` script doesn't have any checkpoint/restart feature, so preservation of *BLACKLIST* state across restarts must be done manually.
See the `Checkpoint and Restart discussion <https://www.suse.com/communities/conversations/further-securing-opensuse-111-against-ssh-script-attacks/#5>`_.

The script :download:`sshblack-save-state <attachments/sshblack-save-state>` should be downloaded to ``/usr/local/sbin/``
and a new crontab rule should be added to run it every 5 minutes::

  # Save the iptables chain BLACKLIST DROP lines for restarting sshblack
  */5 * * * * /usr/local/sbin/sshblack-save-state

This will create a restart script ``/var/lib/sshblack/restart.sh`` which will be executed by the above init-script ``init-sshblack`` at system boot time.

This command prints iptables_ commands to recreate the BLACKLIST from the *sshblack* CACHE in case it is lost by a restart of iptables_::

  awk -F, '{if ($3 > 4) printf("/sbin/iptables -I BLACKLIST -s %s -j DROP\n", $1)}' < /var/lib/sshblack/ssh-blacklist-pending

Firewall and NFS
================

Open up the NFS client's firewall to *all* traffic from the specific NFS-server(s).
In general this is accomplished by this command::

  iptables -A <rule-name> -s <NFS-server-hostname> -j ACCEPT

This may be accomplished permanently by adding this line by manually appending this rule to ``/etc/sysconfig/iptables``::

  ...
  -A RH-Firewall-1-INPUT -s <NFS-server-IP> -j ACCEPT    # RHEL 5
  -A INPUT -s <NFS-server-IP> -j ACCEPT                  # RHEL 6


Summary of RHEL7/CentOS7 and Fedora firewalld settings
======================================================

Summarizing the direct_rule_ commands in the above will result in permanent firewalld_ settings in the file ``/etc/firewalld/direct.xml``::

  <?xml version="1.0" encoding="utf-8"?>
  <direct>
    <chain table="filter" ipv="ipv4" chain="BLACKLIST"/>
    <rule priority="0" table="filter" ipv="ipv4" chain="INPUT_direct">-s 192.168.1.0/24 -j ACCEPT</rule>
    <rule priority="1" table="filter" ipv="ipv4" chain="INPUT_direct">-m set --match-set geoblock src -j DROP</rule>
    <rule priority="2" table="filter" ipv="ipv4" chain="INPUT_direct">-p tcp --dport 22 -m state --state NEW -m recent --set</rule>
    <rule priority="3" table="filter" ipv="ipv4" chain="INPUT_direct">-p tcp --dport 22 -m state --state NEW -m recent --update --seconds 30 --hitcount 4 -j REJECT --reject-with tcp-reset</rule>
  </direct>

Here we have adjusted the *priority* values so that the most important rules have the highest priority (smaller numbers have higher priority, so 0 is the highest priority).
