.. _RHEL_services:

==================================
Services on RHEL and clones
==================================

.. Contents::

Configuring services
============================

Hostname setting
----------------

Fedora stores the system hostname in the file ``/etc/hostname``.
You may change the hostname by::

  hostnamectl set-hostname <NAME>

Boot kernel selection
---------------------

The installed kernels are listed as menu items in the file ``/etc/grub2.cfg``.

On EL8 the ``grubby`` command may be used, for example::

  grubby --default-kernel
  grubby --default-index
  grubby --set-default "/boot/vmlinuz-4.18.0-193.1.2.el8_2.x86_64" 

Kernel items in this list may be set as the default boot kernel, for example::

   grub2-set-default 1

where the number refers to the menu item list.
By default item 0 is the latest installed default boot kernel.
The boot items can be listed by::

  awk -F\' /^menuentry/{print\$2} /etc/grub2.cfg

See `CentOS / RHEL 7 : Change default kernel (boot with old kernel) <https://www.thegeekdiary.com/centos-rhel-7-change-default-kernel-boot-with-old-kernel/>`_.

Managing system services with Systemd
-------------------------------------

RHEL system services are managed with Systemd_.
See `Chapter 6. Managing Services with systemd <https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/chap-Managing_Services_with_systemd.html>`_.

.. _Systemd: http://en.wikipedia.org/wiki/Systemd

To list system services::

  systemctl list-unit-files

Sometimes a service may crash repeatedly and needs to be restarted.
A good workaround is described in
`How to automatically restart Linux services with Systemd <https://freshman.tech/snippets/linux/auto-restart-systemd-service/>`_.
See also `Set up self-healing services with systemd <https://www.redhat.com/sysadmin/systemd-automate-recovery>`_.
For example, copy the service file::

  cp /usr/lib/systemd/system/snmpd.service /etc/systemd/system/

and add to the copied file's ``Service`` section::

  [Service]
  ...
  Restart=on-failure
  RestartSec=1s

Then reload services::

  systemctl daemon-reload

Limit on number of open files
-----------------------------

Thunderbird, Firefox and other tools can use large numbers of open files.
Therefore one may have to configure limits for a username in ``/etc/security/limits.conf``::

  <username>  hard nofile 65536
  <username>  soft nofile  32768

The user has to log out and in again before the new limits become active.


GNOME tools
===============

Tools to customize your GNOME_ desktop include:

* GNOME_Shell_ provides basic functions like launching applications, switching between windows and is also a widget engine. 
  To list all available extensions::

    yum list gnome-shell*

  Search for extensions: https://extensions.gnome.org/

* `Experience with setting up CentOS 7 (GNOME 3 etc.,) <https://www.centos.org/forums/viewtopic.php?t=47796>`_.
* GNOME_Tweak_Tool_ (now known as *Tweaks*)::

    yum install gnome-tweak-tool
    gnome-tweak-tool&

.. _GNOME: https://wiki.gnome.org/
.. _GNOME_Shell: https://en.wikipedia.org/wiki/GNOME_Shell
.. _GNOME_Tweak_Tool: https://wiki.gnome.org/Apps/Tweaks


Storage tools
===============

To manage system disks, LVM and filesystems there are new tools in stead of the old *system-config-lvm* tool.
Documentation is in the
`LVM Administrator Guide <https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Logical_Volume_Manager_Administration/index.html>`_.

There is currently only a very simple disk management tool::

  /usr/bin/gnome-disks

**Note:** This tool seems to be most frozen when used through an SSH connection! It works correctly on the graphical X11 system console.

There is no LVM GUI tool like *system-config-lvm*, so command-line tools must be used.

Windows disk tools (NTFS and ExFAT)
=============================================

To enable mounting of Windows NTFS_ disks install this package::

  yum install ntfs-3g

To enable mounting of Windows ExFAT_ disks install these packages:: 

  yum install exfat-utils-1.2.7-1.el7.nux.x86_64 fuse-exfat-1.2.7-1.el7.nux.x86_64

available (only) from http://li.nux.ro/download/nux/dextop/el7/x86_64/

You can also build this from the `exfat Git source <https://github.com/relan/exfat>`_, see https://access.redhat.com/solutions/70050

.. _NTFS: https://en.wikipedia.org/wiki/NTFS
.. _ExFAT: https://en.wikipedia.org/wiki/ExFAT

SSH and SElinux
===============

The SSH daemon doesn't permit publickey authentication, you will be asked for a password.
You must fix the SELinux on the files in $HOME/.ssh/,
see this thread on `RHEL6 SSH key <http://www.mail-archive.com/linux-390@vm.marist.edu/msg58510.html>`_.
The fix is::

  restorecon -R -v $HOME/.ssh

where the file ``authorized_keys`` is located.

Also, each NFS client must permit user home directories on NFS by::

  setsebool -P use_nfs_home_dirs 1

Networking services
========================

Networking documentation is in the Networking_Guide_.

.. _Networking_Guide: https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Networking_Guide/index.html

Ethernet device naming has changed, see CentOS7_FAQ_ question 2.
Documentation is in `Consistent Network Device Naming <http://fedoraproject.org/wiki/Features/ConsistentNetworkDeviceNaming>`_ and 
`Consistent Network Device Naming in Linux <http://linux.dell.com/biosdevname/>`_.

.. _CentOS7_FAQ: http://wiki.centos.org/FAQ/CentOS7

iftop network monitoring
------------------------------

A very useful tool is iftop_: display bandwidth usage on an interface.
First enable the EPEL_ repository, then install it::

  yum install iftop

Source code is at https://code.blinkace.com/pdw/iftop.

.. _iftop: http://www.ex-parrot.com/pdw/iftop/
.. _EPEL: https://fedoraproject.org/wiki/EPEL

Network interface configuration with NetworkManager
---------------------------------------------------------

Configuration of interfaces uses the NetworkManager_ tool::

  nmtui

For other tools see the Networking_Guide_.

Controlling the ``/etc/resolv.conf`` configuration is discussed in https://wiki.archlinux.org/index.php/resolv.conf.

.. _NetworkManager: https://en.wikipedia.org/wiki/NetworkManager

IPv6 configuration
-----------------------

See https://wiki.centos.org/FAQ/CentOS7.

Many services in CentOS 7 **fail** if IPv6 gets disabled, as in ``/etc/sysctl.conf``::

  # DO NOT DO THIS: Disable IPv6
  # net.ipv6.conf.all.disable_ipv6 = 1
  # net.ipv6.conf.default.disable_ipv6 = 1

We have had problems in CentOS 7.2 and 7.3 for these services: autofs, Ethernet bonding.

VLAN 802.1Q trunk configuration
-------------------------------

For certain servers it may be desirable to connect directly to different VLAN_ subnets. 
This requires connecting to a switch port which has the desired VLANs configured in the switch.
See the RHEL 7 802_1Q_VLAN_Tagging_ documentation and:

* `Configuring 802.1q VLAN in CentOS 7 <https://sites.google.com/site/ghidit/reviews/centos-7-1-a-not-so-seamless-upgrade/configuring-802-1q-vlan-in-centos-7>`_.

.. _802_1Q_VLAN_Tagging: https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Networking_Guide/ch-Configure_802_1Q_VLAN_Tagging.html
.. _VLAN: http://en.wikipedia.org/wiki/Virtual_LAN

To configure a VLAN_ network interface for, for example, VLAN ID 2 with parent interface enp5s0f1 and IP 10.54.2.xx using ``nmtui`` do:

* Select an available interface and select *Add*.
* In *New connectio* select *VLAN* and then *Create*.
* Configure device settings::

    Profile name VLAN2
    Device enp5s0f1.2
    Parent enp5s0f1
    VLAN id 2
    IPv4 CONFIGURATION <Manual>
    Addresses 10.54.2.xx/23    (configure the correct xx for IPv4 address; netmask is /23)
    Gateway 10.54.2.1
    [X] Never use this network for default route    # Check this if default route is on another interface
    [X] Require IPv4 addressing for this connection
    IPv6 CONFIGURATION <Ignore> 
    [X] Automatically connect
    [X] Available to all users

* Save and exit the ``nmtui``.
* It may perhaps be necessary to start the interface manually::

    ifup enp5s0f1.2

ifconfig command
----------------

By default RHEL7 doesn't install the *ifconfig* command.
See this Red Hat article: https://access.redhat.com/solutions/700593:

* The ifconfig command is deprecated and the ip command is now favored to provide similar functionality
* The ifconfig command is provided by the net-tools package.

If the command is needed, it can be accessed by installing the net-tools package::

    # yum install net-tools

Example ip commands::

  # ip addr show
  # ip link show
  # ip addr add 10.10.0.123 dev eth1
  # ip link set eth1 up
  # ip link set eth1 down
  # ip route show

ARP cache for large networks
------------------------------

If the number of network devices (cluster nodes plus switches etc.) approaches or exceeds 512, 
you must consider the Linux kernel's limited dynamic ARP-cache size. 
Please read the man-page *man 7 arp* about the kernel's ARP-cache.

The best solution to this ARP-cache trashing problem is to increase the kernel's ARP-cache garbage collection (gc) 
parameters by adding these lines to ``/etc/sysctl.conf``::

  # Don't allow the arp table to become bigger than this
  net.ipv4.neigh.default.gc_thresh3 = 4096
  # Tell the gc when to become aggressive with arp table cleaning.
  # Adjust this based on size of the LAN.
  net.ipv4.neigh.default.gc_thresh2 = 2048
  # Adjust where the gc will leave arp table alone
  net.ipv4.neigh.default.gc_thresh1 = 1024
  # Adjust to arp table gc to clean-up more often
  net.ipv4.neigh.default.gc_interval = 3600
  # ARP cache entry timeout
  net.ipv4.neigh.default.gc_stale_time = 3600

Then run ``/sbin/sysctl -p`` to reread this configuration file.

Firewall configuration
====================================

The default firewall service is firewalld_ and **not** the well-known *iptables* service.
The dynamic firewall daemon firewalld_ provides a dynamically managed firewall with support for network “zones” to assign a level of trust to a network and its associated connections and interfaces. 
See `Introduction to firewalld <https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Security_Guide/sec-Using_Firewalls.html>`_.

.. _firewalld: https://fedoraproject.org/wiki/FirewallD

Install firewalld_ by::

  yum install firewalld firewall-config

A graphical configuration tool::

  firewall-config

is used to configure firewalld_, which in turn uses *iptables* tool to communicate with *Netfilter* in the kernel which implements packet filtering. 

The firewall configuration files are in the directory ``/etc/firewalld/zones/`` where XML files contain the firewall rules.

To query all rules in zones::

  firewall-cmd --list-all           # Only default zone
  firewall-cmd --list-all-zones     # All zones

IP_set firewall rules
-------------------------

IP_sets_ are a framework inside the Linux 2.4.x and 2.6.x kernel which can be used efficiently to create firewall rules for large numbers of IP subnets.
We document configuration of this in :ref:`Linux_firewall_configuration`.

.. _IP_sets: http://ipset.netfilter.org/

DNS servers
================

See the documentation on :ref:`DNS-servers`.

Note that ``bind-chroot`` is no longer recommended, see ``man named``::

  By default, Red Hat ships BIND with the most secure SELinux policy that will not prevent normal BIND operation and will prevent exploitation of all known BIND security vulnerabilities.
  See the selinux(8) man page for information about SElinux.

  It is not necessary to run named in a chroot environment if the Red Hat SELinux policy for named is enabled. When enabled, this policy is far more secure than a chroot environment.
  Users are recommended to enable SELinux and remove the bind-chroot package.

Install the BIND DNS server packages::

  yum install bind-utils bind-libs bind
  systemctl enable named 

Copy the configuration file ``/etc/named.conf`` from another server (see below hints about configuration) and make sure it's correctly owned and protected::

  chmod 640 /etc/named.conf
  chgrp named /etc/named.conf

Install SELinux packages and documentation::

  yum install selinux-policy-doc libselinux-python libsemanage-python

Configuring DNS master server
--------------------------------

The BIND configuration file is ``/etc/named.conf``.

The authoritative DNS zone files are located in this directory ``/var/named``.

Configuring DNS caching server
--------------------------------

For setup of **DNS cache server** see http://www.fatmin.com/2011/10/rhel6-how-to-setup-a-caching-only-dns-server.html.
An example file is in ``intra4:/etc/named.conf``.

**IMPORTANT:** In order for the DNS caching server to work correctly, it **must** be configured in the *DTU router filters*.
The caching server's IP-address must be defined as in this example::

  permit udp any eq domain host 130.225.87.35 gt 1023	! DNS cache return

Configuring DNS slave server
--------------------------------

Apparently the configuration includes::

  cd /var/named/
  cp -p /usr/share/doc/bind-9.*/sample/var/named/named.* .
  mkdir slaves dynamic data
  chown named.named slaves dynamic data
  chmod 770 slaves dynamic data

Running the DNS server
--------------------------------

Configure the firewall to allow access to the DNS server::

  firewall-cmd --permanent --add-port=53/udp
  firewall-cmd --permanent --add-port=53/tcp
  firewall-cmd --reload

SElinux config for DNS server (see *man named_selinux* from the *selinux-policy-doc* RPM)::

  setsebool -P named_write_master_zones 1

Start the DNS server by::

  systemctl enable named
  systemctl start named
  
NFS server configuration
=============================

See the RHEL7 documentation `8.7. NFS Server Configuration <https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Storage_Administration_Guide/nfs-serverconfig.html>`_.
This includes a section *8.7.3. Running NFS Behind a Firewall*.

See also `Quick NFS Server configuration on Redhat 7 Linux System  <http://linuxconfig.org/quick-nfs-server-configuration-on-redhat-7-linux>`_
and `Setting Up NFS Server And Client On CentOS 7 <http://www.unixmen.com/setting-nfs-server-client-centos-7/>`_ and
`About NFS (Shared File System Administration) <https://docs.oracle.com/cd/E52668_01/E54669/html/ol7-about-nfs.html>`_.

First install these RPMs::

  yum install nfs-utils quota

Add this to ``/etc/sysconfig/nfs``::

  RPCMOUNTDOPTS="-p 892"
  LOCKD_TCPPORT=32803
  LOCKD_UDPPORT=32769

This scripts is sourced by ``/usr/lib/systemd/scripts/nfs-utils_env.sh``.

Also, for heavily loaded NFS servers with large memory and many CPU cores you should increase this variable from the default value of 8 to perhaps 16, 32 or::

  RPCNFSDCOUNT=64

Some services (undocumented) must be enabled at reboot and started::

  systemctl enable rpcbind
  systemctl enable nfs-server
  systemctl enable nfs-lock
  systemctl enable nfs-idmap
  systemctl enable rpc-rquotad.service
  systemctl start rpcbind
  systemctl start nfs-server
  systemctl start nfs-lock
  systemctl start nfs-idmap
  systemctl start rpc-rquotad.service

The NFS remote quota service **rpc-rquotad.service** (alias: nfs-rquotad.service) was added by Red Hat as late as March 2016, see the bug fix update https://rhn.redhat.com/errata/RHBA-2016-0557.html.
There is a new configuration file ``/etc/sysconfig/rpc-rquotad`` in which you must define a fixed port 875::

  RPCRQUOTADOPTS="-p 875"

Then restart the *nfs* service::

  systemctl restart nfs-server 

Check that the required services are running::

  # systemctl -l | grep nfs
  proc-fs-nfsd.mount                       loaded active mounted   NFSD configuration filesystem
  var-lib-nfs-rpc_pipefs.mount             loaded active mounted   RPC Pipe File System
  nfs-config.service                       loaded active exited    Preprocess NFS configuration
  nfs-idmapd.service                       loaded active running   NFSv4 ID-name mapping service
  nfs-mountd.service                       loaded active running   NFS Mount Daemon
  nfs-server.service                       loaded active exited    NFS server and services
  nfs-client.target                        loaded active active    NFS client services

RHEL 8 notes
------------------

See `Chapter 3. Exporting NFS shares <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/deploying_different_types_of_servers/exporting-nfs-shares_deploying-different-types-of-servers>`_.

Install also this package::

  dnf install quota-rpc

NFS server configuration is now in ``/etc/nfs.conf``, an INI-like configuration file.
Ports are defined in this file.

If IPv6 is disabled, you may get an error **rpc.rquotad: Failed to create udp6 service**,
see https://unix.stackexchange.com/questions/454231/rpc-bind-errors-when-disabling-ipv6
The fix is to comment out lines with *udp6* and *tcp6* in ``/etc/netconfig`` and reboot the system.

NFS server firewall rules
-----------------------------------

Add the following firewall rules::

  firewall-cmd --permanent --add-port=111/tcp
  firewall-cmd --permanent --add-port=875/tcp
  firewall-cmd --permanent --add-port=892/tcp
  firewall-cmd --permanent --add-port=2049/tcp
  firewall-cmd --permanent --add-port=20048/tcp
  firewall-cmd --permanent --add-port=32803/tcp

  firewall-cmd --permanent --add-port=111/udp
  firewall-cmd --permanent --add-port=875/udp
  firewall-cmd --permanent --add-port=892/udp
  firewall-cmd --permanent --add-port=2049/udp
  firewall-cmd --permanent --add-port=20048/udp
  firewall-cmd --permanent --add-port=32769/udp

  firewall-cmd --reload

NFSv3 requires the *rpcbind* service,
see `NFS and rpcbind <https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Storage_Administration_Guide/s2-nfs-methodology-portmap.html>`_.
Use this command to list ports used::

  rpcinfo -p

The services listed **must** be permitted by the firewall rules.

We have seen some cases of heavy NFS client traffic load where the client syslog shows error messages::

  kernel: lockd: server XXX not responding, still trying
  kernel: xs_tcp_setup_socket: connect returned unhandled error -107

It turned out that this was related to the firewalld_ service, despite the correct rules shown above.
Maybe this is a performance issue in firewalld_?
The way to test this is to shut down firewalld_ temporarily and see if the problem has been solved::

  systemctl stop firewalld

It seems that the problem is solved by explicitly whitelisting the IP subnets used by the NFS clients, for example for the 10.2 subnet::

  firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT_direct 0 -s 10.2.0.0/16 -j ACCEPT
  firewall-cmd --reload


Chrony NTP time service
===================================

See `Chapter 15. Configuring NTP Using the chrony Suite <https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/ch-Configuring_NTP_Using_the_chrony_Suite.html>`_.

Install the RPM::

  yum install chrony

Define NTP servers in ``/etc/chrony.conf``::

  server ntp.ait.dtu.dk iburst

Alternative NTP servers::

  # Use public servers from the pool.ntp.org project.
  # Please consider joining the pool (http://www.pool.ntp.org/join.html).
  server 0.centos.pool.ntp.org iburst
  server 1.centos.pool.ntp.org iburst
  server 2.centos.pool.ntp.org iburst
  server 3.centos.pool.ntp.org iburst

Then start the service::

  systemctl start chronyd
  systemctl enable chronyd

TFTP file server
===================================

The TFTP_ file server may be used for :ref:`PXE-booting` client devices.
See some advice about installing a TFTP server:

* http://www.bo-yang.net/2015/08/31/centos7-install-tftp-server

**Note:** Multi-homed TFTP servers will likely have problems serving UDP-based requests from clients, for example, by TFTP.
See:

* https://www.humboldt.co.uk/a-working-tftp-server-for-multi-homed-linux-systems/

Install the TFTP server and client package by::

  yum install tftp-server tftp

.. _TFTP: http://en.wikipedia.org/wiki/Tftp

In CentOS/RHEL 7 the TFTP_ service is controlled by Systemd_.
If you want to modify the TFTP_ service, first copy the file to the directory for customized services::

  cp -Z /usr/lib/systemd/system/tftp.service /etc/systemd/system/tftp.service

Only the copied file may be modified, see the systemd_unit_files_ page.

.. _systemd_unit_files: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/sect-managing_services_with_systemd-unit_files

Enable the TFTP_ service at boot time and start it now::

  systemctl start tftp
  systemctl enable tftp
  
Sendmail configuration
===================================

Sendmail client
---------------------

The central mailhub must be defined in ``/etc/mail/sendmail.mc`` by changing the ``SMART_HOST`` line, for example::

  define(`SMART_HOST', `mail.fysik.dtu.dk')dnl
  dnl # Relay also unqualified addresses /OHN
  define(`LOCAL_RELAY', `mail.fysik.dtu.dk')dnl

Also the last line in ``/etc/aliases`` must be changed to relay root's mail::

  root:	root@mail.fysik.dtu.dk

Then restart the ``sendmail`` service::

  systemctl restart sendmail.service

Sendmail server
---------------------

The local mail server configuration is defined in our :ref:`Ansible_configuration` setup.
The required configuration files in ``/etc/mail/`` include:

1. local-host-names: Add hostname aliases for this server

2. Add routing rules to the mailertable::

     .nifl.fysik.dtu.dk      local:
     nifl.fysik.dtu.dk       local:
     listserv.fysik.dtu.dk   smtp:[listserv.fysik.dtu.dk] 
     mail.fysik.dtu.dk       smtp:[mail.fysik.dtu.dk] 
     dtu.dk                  smtp:[smtp.ait.dtu.dk] 
     fysik.dtu.dk            smtp:[smtp.ait.dtu.dk] 
     mek.dtu.dk              smtp:[smtp.ait.dtu.dk] 
     adm.dtu.dk              smtp:[smtp.ait.dtu.dk] 
     win.dtu.dk              smtp:[smtp.ait.dtu.dk] 
     student.dtu.dk          smtp:[smtp.ait.dtu.dk]

3. Comment out the line in sendmail.mc blocking all remote connections::

     DAEMON_OPTIONS(`Port=smtp,Addr=127.0.0.1, Name=MTA')dnl

4. Possibly define a mail relay as for *Sendmail client* above.

5. Make a crontab job restarting sendmail on a daily basis::

     * 8 * * * systemctl restart sendmail

Proper routing of various E-mail address patterns should be verified, for example::

  sendmail -bv root@mail.fysik.dtu.dk
  sendmail -bv root@nifl.fysik.dtu.dk
  sendmail -bv root@a001.nifl.fysik.dtu.dk
  sendmail -bv root.fysik.dtu.dk

Sendmail TLS errors
---------------------

See the article `Securing Applications with TLS in RHEL <https://access.redhat.com/articles/1462183>`_.

With CentOS 8 Sendmail we have problems sending to *smtp.ait.dtu.dk* and get errors in ``/var/log/maillog``::

  ruleset=tls_server, arg1=SOFTWARE, relay=smtp.ait.dtu.dk, reject=403 4.7.0 TLS handshake failed. 

See some articles about the TLS problem:

* https://unix.stackexchange.com/questions/144989/how-to-turn-off-starttls-for-internal-relaying-of-emails
* https://forums.businesshelp.comcast.com/t5/Microsoft-Services-Apps/Sendmail-Error-stat-Deferred-403-4-7-0-TLS-handshake-failed/td-p/24008
* The file ``/usr/share/doc/sendmail/README.cf`` (install the *sendmail-doc* RPM)

Add this to the ``/etc/mail/access`` config file to disable TLS::

  Try_TLS:servername NO

and restart sendmail.

Logwatch configuration
==========================

Make sure that *logwatch* has been installed::

  yum install logwatch

For centralized daily logwatch add to the config file ``/etc/logwatch/conf/logwatch.conf``::

  # Default person to mail reports to.  Can be a local account or a complete email address.
  MailTo = logwatch@mail.fysik.dtu.dk

File name locate configuration
====================================

The updatedb_ creates or updates a database used by locate_ for finding files.

On EL8 systems the updatedb_ is no longer run from crontab by default, see 
`The mlocate package on RHEL8 installs a systemd timer in place of scheduling updatedb via cron  <https://access.redhat.com/solutions/4792641>`_.
Enable updatedb_ by::

  systemctl enable --now mlocate-updatedb.timer

For a list of timers do::

  systemctl list-timers

.. _updatedb: https://linux.die.net/man/8/updatedb
.. _locate: https://linux.die.net/man/1/locate

Printer setup
====================================

Printers can be set up manually from the GUI::

  system-config-printer

One may also use the lpadmin_ command line tool see `How to setup printers from the command line using lpadmin in RHEL <https://access.redhat.com/solutions/21432>`_.
For example, to add a JetDirect printer on port 9100::

  lpadmin -p {{ destination }} -v {{ printer }} -m {{ driver }} -E

where:

* destination: logical name such as HP-LaserJet-p4015-b307-225
* printer: ``socket:<IP-address>:9100``   **Must** use printer IP-address in socket name. Port 9100 is for HP JetDirect
* driver: a driver PPD file such as drv:///hp/hpijs.drv/hp-laserjet_p4015dn-hpijs.ppd
* braces {{ }} are used with :ref:`Ansible_configuration`.

List all printers on system::

  lpstat -a

To search the PPD database for a specific printer model::

  lpinfo -m | grep -i laserjet

Display the default printer::

  lpstat -d

Set the system default printer::

  lpadmin -d <printer_name>

To delete a printer::

  lpadmin -x {{ destination }}

.. _lpadmin: https://www.cups.org/doc/man-lpadmin.html

List available printer drivers (grep for your model)::

  lpinfo -m 

Display available printer options by::

  lpoptions -p {{ destination }} -l

To change printer options::

  lpadmin -p {{ destination }} {{ options }}

where standard CUPS options are described in https://www.cups.org/doc/options.html#OPTIONS.
Example options (when available)::

  -o OptionDuplex=True -o sides=two-sided-long-edge -o media=A4

MySQL (MariaDB) configuration
====================================

If you need the MySQL (MariaDB) database server, install the RPMs::

  yum install mariadb-server mariadb-devel

Then start the service::

  systemctl start mariadb
  systemctl enable mariadb
  systemctl status mariadb

Select a database password and run::

  mysql_secure_installation

If the database must be accessed from remote hosts (on port 3306), then make a firewall rule::

  firewall-cmd --zone=public --add-port=3306/tcp --permanent

Disabling the Login Screen User List
===========================================

From https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Desktop_Migration_and_Administration_Guide/customizing-login-screen.html.
You can disable the user list shown on the login screen by setting the org.gnome.login-screen.disable-user-list GSettings key.
When the user list is disabled, users need to type their user name and password at the prompt to log in.

* Procedure 10.12. Setting the org.gnome.login-screen.disable-user-list Key

    Create a gdm database for machine-wide settings in ``/etc/dconf/db/gdm.d/01-login-screen`` (or some number higher than 00)::

      [org/gnome/login-screen]
      # Do not show the user list
      disable-user-list=true

    Update the system databases by updating the dconf utility::

      dconf update

CentOS 7.1 has a bug in the user list (can't scroll up/down), see https://bugzilla.redhat.com/show_bug.cgi?id=1184802.

Non-graphical run-level
===========================================

Servers don't need a graphical (GUI) login screen.
In CentOS 6 the graphical/non-graphical run-level was controlled by ``/etc/inittab``.
In Red Hat Enterprise Linux 7, the concept of runlevels has been replaced with Systemd_ targets. 
See `8.3. Working with systemd Targets 
<https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/sect-Managing_Services_with_systemd-Targets.html#sect-Managing_Services_with_systemd-Targets-Change_Default>`_.

With Systemd_ its done like this::

  systemctl get-default
  systemctl set-default multi-user.target    # Non-graphical
  systemctl set-default graphical.target     # Graphical (GUI mode)
  reboot

The defaults are:

* If current setting is graphical.target then Linux will boot in GUI Mode.
* If current setting is multi-user.target then Linux will boot in NON-GUI Mode.

Serial ports
================

Communication via the serial port may use the Minicom_ tool::

  yum install minicom

Usage::

  minicom -D /dev/ttyS0

.. _Minicom: https://en.wikipedia.org/wiki/Minicom

Serial ports will be */dev/ttyS0* etc.
The superuser must give users access to the port::

  chmod 666 /dev/ttyS0

To make this setting persistent across reboots, create a file ``/etc/udev/rules.d/60-serial.rules`` with::

  KERNEL=="ttyS0", MODE="0666"

See https://bbs.archlinux.org/viewtopic.php?id=85167

Wake-On-LAN (WOL)
================-

The Wake-On-LAN (WOL) function is provided by the command::

  ether-wake

installed by the *net-tools* RPM package.

Git version control system
===============================

To install G:ref:`it` see `Getting Started - Installing Git <https://git-scm.com/book/en/v2/Getting-Started-Installing-Git>`_::

  yum install git-all

.. _Git: https://en.wikipedia.org/wiki/Git

Samba Windows interoperability suite
==============================================

Newer versions: Get :ref:`Samba_service` source code from the website.
Please note that Fedora FC28 contains Samba 4.8.1.

For building :ref:`Samba_service` see:

* https://github.com/nkadel/samba-4.8.x-srpm

.. _Samba: https://www.samba.org/

Samba 4.8 build prerequisites::

  yum install gnutls-devel libacl-devel openldap-devel pam-devel avahi-devel cups-devel dbus-devel e2fsprogs-devel libaio-devel libarchive-devel libcap-devel libcmocka-devel libtirpc-devel popt-devel python2-dns python2-iso8601 python-subunit quota-devel readline-devel xfsprogs-devel pkgconfig glusterfs-api-devel glusterfs-devel bind gnutls-devel krb5-server python2-crypto libtalloc-devel python2-talloc-devel libtevent-devel python2-tevent libtdb-devel python2-tdb libldb-devel python2-ldb-devel

The :ref:`Samba_service` configuration file smb.conf_ in ``/etc/samba/`` contains information about :ref:`Samba_service` and SElinux_ configuration which must be consulted.
In order to permit users to mount :ref:`Samba_service` shares execute the following command on the server::

  setsebool -P samba_enable_home_dirs on
  setsebool -P samba_export_all_rw on

On a Samba server open the ports in the firewall::

  firewall-cmd --permanent --zone=public --add-port=139/tcp
  firewall-cmd --permanent --zone=public --add-port=445/tcp
  firewall-cmd --reload

.. _smb.conf: https://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html
.. _SELinux: http://selinuxproject.org/page/Main_Page


Apple Time Machine support
--------------------------------

Samba **version 4.8.1** is requited for Apple Time Machine support, see https://bugzilla.samba.org/show_bug.cgi?id=12380.
This currently means that the latest Fedora FC28 is required.
There are no 4.8.1 RPMs for CentOS 7.

To enable this edit ``smb.conf`` to add in the *[global]* section::

  ## FYS: Enable Apple Time Machine support (see man 8 vfs_fruit)
  fruit:aapl = yes
  fruit:time machine = yes
  fruit:advertise_fullsync = true

A Samba share for *Time Machine* may be defined in smb.conf::

  [TimeMachine]
  path = /data
  comment = Time Machine Backup Disk
  browsable = yes
  writable = yes
  create mode = 0600
  directory mode = 0700
  kernel oplocks = no
  kernel share modes = no
  posix locking = no
  vfs objects = catia fruit streams_xattr​

See also:

* https://macosx.com/threads/smb-samba-for-time-machine-backup.324958/

sudo root access
========================

Thanks to sudo, you can run some or every command as root.
See:

* https://wiki.centos.org/TipsAndTricks/BecomingRoot 

You must use the command::

  visudo 

to edit the ``/etc/sudoers`` file!

To allow a specific user *ALL* root access, append this line at the end of the file::

  <my-username> ALL=(ALL)       ALL

