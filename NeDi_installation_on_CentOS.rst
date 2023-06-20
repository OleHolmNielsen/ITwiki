.. _NeDi_installation_on_CentOS:

NeDi installation and upgrading on EL and CentOS Linux
=============================================================

.. Contents::

NeDi_ (*Network Discovery*) is an open source network monitoring tool.
Please see first the general information in the NeDi_.

This page describes how to install NeDi_ on RHEL (and clones such as AlmaLinux, RockyLinux, and CentOS) Linux servers.

On the dedicated server for NeDi_ the NeDi_ file ``nedi-XXX.tgz`` from the `NeDi download <https://www.nedi.ch/download/>`_ page.
Paying customers may download the latest version (currently 2.3) from the NeDi_customer_ page.

See also the general NeDi_installation_ page.

.. _NeDi: https://www.nedi.ch/
.. _NeDi_customer: https://www.nedi.ch/services/customer-area/index.html

NeDi installation on EL8 
===============================

Enable the EPEL_ repository, see the EPEL_ instructions.
Install these packages::

  dnf install gcc httpd mod_ssl php php-mysqlnd mariadb-server mariadb-devel php-snmp php-gd php-process patch net-snmp net-snmp-utils rrdtool rrdtool-perl tcpdump
  dnf install perl-Algorithm-Diff perl-Net-Telnet perl-Net-DNS perl-Socket6 perl-Test-Exception perl-DBD-MySQL perl-Module-Build perl-Net-SNMP
  dnf install perl-CPAN perl-App-cpanminus

Now you can install the required CPAN_ modules::

  cpanm RRD::Simple
  cpanm Time::HiRes::Value

If you are using an Ansible_ server, install this ansible-galaxy collection on the server::

  ansible-galaxy collection install community.general

so that you can install Perl modules like this playbook example::

  - name: Install perl-RRD-Simple package
    community.general.cpanm:
      name: RRD::Simple

The attached Ansible_ task file :download:`main.yml <attachments/nedi-ansible-role.yml>` 
may be used to set up your own playbook for installing NeDi_ with Ansible_.

.. _MariaDB: https://mariadb.org/
.. _EPEL: https://docs.fedoraproject.org/en-US/epel/
.. _CPAN: https://www.cpan.org/
.. _Ansible: https://www.ansible.com/

If you restore a database dump onto a different server running a **newer MySQL or MariaDB version** you **must** read the
section ``Upgrade of MySQL/MariaDB`` below!

NeDi Installation on CentOS/RHEL 7
======================================

Enable the EPEL_ repository, see the EPEL_ instructions.
Install prerequisite packages::

  yum install httpd mod_ssl php php-mysql mariadb-server mariadb-devel php-snmp php-gd php-process patch 
  yum install net-snmpnet-snmp-utils rrdtool rrdtool-perl tcpdump postgresql.x86_64 php-pgsql.x86_64
  yum install perl-Algorithm-Diff perl-Net-Telnet perl-Net-DNS perl-Socket6 perl-Test-Exception perl-DBD-Pg.x86_64 perl-Module-Build
  yum install perl-CPAN perl-App-cpanminus

Then install additional packages from EPEL_::

  yum install perl-Net-SNMP perl-IO-Pty-Easy.noarch

Some packages must be installed manually as CPAN_ modules::

  cpanm RRD::Simple
  cpanm Time::HiRes::Value

.. _RRD-Simple: https://search.cpan.org/~nicolaw/RRD-Simple-1.44/lib/RRD/Simple.pm
.. _Time-HiRes-Value: https://metacpan.org/pod/Time::HiRes::Value
.. _Class-DBI-Pg: https://search.cpan.org/~dmaki/Class-DBI-Pg-0.09/lib/Class/DBI/Pg.pm

NeDi installation on EL9 
===============================

**WARNING:** At the time of writing (June 2023) NeDi version 2.3 does not yet support the MariaDB version 10.5,
which is part of EL9 (RHEL 9 and clones).
You have to use EL8 with MariaDB 10.3 in stead.

The EL9 MariaDB_ database is version 10.5.
See the 10.5 release notes at https://mariadb.com/kb/en/changes-and-improvements-in-mariadb-10-5/
Note this new driver::

  Switch Perl DBI scripts from DBD::mysql to DBD::MariaDB driver (MDEV-19755) 

Install the new driver by::

  cpanm DBD::MariaDB

Patching the Perl NET::SNMP module Message.pm
====================================================

NeDi_ the perl-Net-SNMP_ library (*Net::SNMP*, not to be confused with the Net-SNMP_ package), which hasn't been updated since 2010.
There is a problem with the *Message.pm* module which may lead to many fake events in NeDi_

  latency xxx exceeds threshold yyy

If you want to fix this problem, the only way is to manually patch the *Message.pm* module (no updates seem to be coming) to use the Time-HiRes-Value_ module.
You may download the attached file :download:`Message.pm.diff <attachments/Message.pm.diff>`.
This patch was provided by the author of NeDi_.

Patch the ``/usr/share/perl5/vendor_perl/Net/SNMP/Message.pm`` file (as root)::

  cd /usr/share/perl5/vendor_perl/Net/SNMP
  patch < Message.pm.diff

.. _perl-Net-SNMP: https://search.cpan.org/dist/Net-SNMP/
.. _Net-SNMP: https://net-snmp.sourceforge.net/

Install NeDi
====================

Create a ``nedi`` user in group ``apache`` with home directory ``/var/nedi``::

  useradd --gid apache --shell /bin/bash --create-home --home-dir /var/nedi/ --comment "NeDi user" nedi

Create some dynamic subdirectories needed, then unpack the files to the ``nedi`` user's home directory::

  mkdir -p /var/nedi/log 
  cd /var/nedi
  tar xzvf .../nedi-XXX.tgz
  chown -R nedi.apache /var/nedi/*

**Security: Check if this is really needed** Make the /var/nedi/ directory tree group-writable (group ``apache`` meaning the Apache web server)::

  chmod -R g+w /var/nedi/*

**Note:** It is important **not** to make the directories ``/var/nedi`` and ``/var/nedi/.ssh`` group-writable, since this will cause security problems with SSH logins.

Protect configuration files which might reveal important information about your network::

  chmod 660 /var/nedi/nedi.conf /var/nedi/seedlist

Create system links to the NeDi_ files::

  ln -s /var/nedi/nedi.conf /etc/nedi.conf  # NeDi configuration file
  mv /var/www/html /var/www/html.orig       # Move default Apache html files out of the way
  ln -s /var/nedi/html/ /var/www/html       # Link to NeDi html files

The PHP configuration file ``/etc/php.ini`` **must** be edited so that PHP will recognize code between <? and ?> tags as PHP source, so change this parameter::

  short_open_tag = On

For reasons of `security <https://phpsec.org/projects/phpsecinfo/tests/expose_php.html>`_ turn off this option in ``/etc/php.ini``::

  expose_php = Off

SELinux permissive mode
-----------------------

**Security concern:** NeDi_ has been designed to execute many scripts through the Apache web server.
This is going to conflict with the SELinux_ *Enforcing* security mode, and you must consider the security implications of allowing the Apache web server write access to the NeDi_ server's file system.

SELinux_ is configured in ``/etc/selinux/config`` and it should be set to *Permissive* mode::

  SELINUX=permissive

Either reboot the server, or set *Permissive* mode immediately using this command::

  setenforce Permissive

.. _SELinux: https://wiki.centos.org/HowTos/SELinux

See the man-page httpd_selinux_ for information about Apache and SELinux.

.. _httpd_selinux: https://fedoraproject.org/wiki/SELinux/apache

Warning messages from SELinux_ will appear in the system syslog ``/var/log/messages``.

Configuring NeDi for secure SELinux operation
.............................................

**Optional:**
Configuring the correct SELinux_ settings for the whole of NeDi_ (*/var/nedi*) is probably going to be really complicated.
Here are some initial settings to get started.

Set SELinux_ security context for normal files in the *nedi* user's home directory (do not set on the ``.ssh/`` folder)::

  setsebool -P httpd_enable_homedirs 1
  chcon -R -t httpd_sys_content_t /var/nedi/*

For NeDi_ operation you must allow Apache to write to some directories.
Make sure these directories have correct ownership and permissions::

  # chown nedi.apache /var/nedi/html/map /var/nedi/sysobj
  # chmod g+w /var/nedi/html/map /var/nedi/sysobj
  # ls -lad /var/nedi/html/map /var/nedi/sysobj
  drwxrwxr-x. 2 nedi apache  4096 Jan  6 15:11 /var/nedi/html/map
  drwxrwxr-x. 2 nedi apache 36864 Jan  6 15:11 /var/nedi/sysobj

and then configure SELinux_ to permit read-write access for Apache::

  chcon -R -t httpd_sys_rw_content_t /var/nedi/html/map
  chcon -R -t httpd_sys_rw_content_t /var/nedi/sysobj/

NeDi database services
==============================

Mariadb database service
-----------------------------------

Start the MariaDB_ service::

  systemctl start mariadb
  systemctl enable mariadb
  systemctl status mariadb

Secure the database (root password etc.) by running::

  /usr/bin/mysql_secure_installation

Initialize NeDi database
------------------------

See the NeDi_installation_ page about database initialization.
If this is an **initial installation** of NeDi_,
initialize a **completely blank** Nedi_ database by::

  cd /var/nedi/
  ./nedi.pl -i

For the *mysql admin user/pass* use *root* and the database password selected above.

For **upgrading** NeDi_ starting with NeDi_ 1.4, you can use *-i nodrop* for updating an existing DB structure without the need for DB admin credentials. 
Alternatively *-i updatedb* will do just that without any loss of data.

For version 1.4.300 or 1.5.038 or 1.6.100::

  ./nedi.pl -i updatedb

The MySQL *root* account will be required for this operation.

NeDi syslog and moni daemons
----------------------------

NeDi_ requires two running daemon processes:

* ``syslog.pl`` syslog daemon which stores events directly in the database.
* ``moni.pl`` monitoring daemon for polling uptime and checking connectivity of services.

First download the service scripts from here:

* :download:`nedi-monitor.service <attachments/nedi-monitor.service>`
* :download:`nedi-syslog.service <attachments/nedi-syslog.service>`

Add the Systemd_ services::

  systemctl enable nedi-monitor.service
  systemctl enable nedi-syslog.service
  systemctl start nedi-monitor.service
  systemctl start nedi-syslog.service
  systemctl status nedi-monitor.service
  systemctl status nedi-syslog.service

On **EL7 systems** you must first install these scripts:

* :download:`nedi-monitor <attachments/nedi-monitor>`
* :download:`nedi-syslog <attachments/nedi-syslog>`
* Copy files::
    chmod 755 nedi-monitor nedi-syslog 
    cp nedi-monitor nedi-syslog /usr/libexec/
    cp nedi-monitor.service nedi-syslog.service /etc/systemd/system/
  
Documentation is in the systemd.service_ manual page.

.. _Systemd: https://en.wikipedia.org/wiki/Systemd
.. _systemd.service: https://www.man7.org/linux/man-pages/man5/systemd.service.5.html

Apache web service
=======================

We will use the Apache_ web server provided by the *httpd* RPM package.

.. _Apache: https://httpd.apache.org/

An SSL-encrypted NeDi_ web-page must be configured because critical information such as login passwords are used.
For an introduction see `Setting up an SSL secured Webserver with CentOS <https://wiki.centos.org/HowTos/Https>`_.
The unencrypted HTTP service on port 80 should be redirected to the SSL-encrypted port 443 (see https://wiki.apache.org/httpd/RedirectSSL) as shown in the example below.

You may either use a self-signed SSL certificate, or use a commercial SSL certificate valid for your web server according to your site's security policies.
The SSL certificate files must be copied to the ``/etc/pki/tls/{certs,private}/`` directories (see above CentOS instructions).

In the Apache_ configuration directory ``/etc/httpd/conf.d/`` create the file ``03nedi.conf`` and change DNS domain names (here *example.com*) as required::

  NameVirtualHost *:80
  <VirtualHost *:80>
    AddDefaultCharset Off
    ServerAdmin webmaster@example.com
    ServerName nedi.example.com
    RewriteEngine On
    RewriteCond %{REQUEST_METHOD} ^TRACE
    RewriteRule .* - [F]
    Redirect / https://nedi.example.com/
  </VirtualHost>

  NameVirtualHost *:443
  <VirtualHost _default_:443>
    AddDefaultCharset Off
    ServerAdmin webmaster@example.com
    ServerName nedi.example.com
    DocumentRoot /var/www/html/
    # Security: Cross-Site Tracing issues: https://www.apacheweek.com/issues/03-01-24
    RewriteEngine On
    RewriteCond %{REQUEST_METHOD} ^TRACE
    RewriteRule .* - [F]
    # Security: https://developer.mozilla.org/en-US/docs/Web/HTTP/X-Frame-Options
    Header always append X-Frame-Options SAMEORIGIN
    DirectoryIndex index.php
    Options -Indexes
    SSLEngine On
    SSLCertificateFile /etc/pki/tls/certs/ca.crt            # Example only
    SSLCertificateKeyFile /etc/pki/tls/private/ca.key       # Example only
    # Disable obsolete SSLv2/3 and TLS v1.0 protocols:
    SSLProtocol all -SSLv2 -SSLv3 -TLSv1
    # See https://mozilla.github.io/server-side-tls/ssl-config-generator/
    SSLCipherSuite "ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA"
    SSLHonorCipherOrder on
    Header always add Strict-Transport-Security "max-age=15768000"
  </VirtualHost>

Test the Apache configuration by::

  apachectl configtest

Apache and SSL security
-----------------------

Advice about SSL security in Apache_:

* https://wiki.mozilla.org/Security/Server_Side_TLS#Apache

The SSLCipherSuite_ (*Cipher Suite available for negotiation in SSL handshake*) configuration is really complicated.
Strong recommendations are in:

* Server_Side_TLS_
* tls-ssl-cipher-hardening_

.. _Server_Side_TLS: https://wiki.mozilla.org/Security/Server_Side_TLS
.. _tls-ssl-cipher-hardening: https://www.acunetix.com/blog/articles/tls-ssl-cipher-hardening/

In fact, one may generate an appropriate Apache_ SSL configuration including SSLCipherSuite_ in the page:

* https://mozilla.github.io/server-side-tls/ssl-config-generator/

.. _SSLCipherSuite: https://httpd.apache.org/docs/2.2/mod/mod_ssl.html#sslciphersuite

There seems to be a bug in the CentOS/RHEL 7 *httpd* package file ``/etc/httpd/conf.modules.d/00-lua.conf`` giving a syslog error message::

  httpd: Syntax error on line 56 of /etc/httpd/conf/httpd.conf: Syntax error on line 1 of /etc/httpd/conf.modules.d/00-lua.conf: Cannot load modules/mod_lua.so into server: /etc/httpd/modules/mod_lua.so: undefined symbol: apr_bcrypt_encode

On EL7 comment out (insert #) the line 1 in ``/etc/httpd/conf.modules.d/00-lua.conf``.

Start the web service
-----------------------

When the Apache configuration test is OK, start the *httpd* service::

  systemctl enable httpd
  systemctl start httpd
  systemctl status httpd

A nice introduction is `RHEL7: How to get started with Firewalld <https://www.certdepot.net/rhel7-get-started-firewalld/>`_.

Configure firewalld_ rules for HTTP/HTTPS (ports 80,443) by adding::

  firewall-cmd --zone=public --add-port=80/tcp --permanent
  firewall-cmd --zone=public --add-port=443/tcp --permanent
  firewall-cmd --reload

.. _firewalld: https://fedoraproject.org/wiki/FirewallD

NeDi Crontab jobs
=========================

For automatic device discovery use *cron* jobs.
Add some *crontab* commands for user *nedi* using the command::

  crontab -e -u nedi

to add these hourly jobs::

  0 0 * * * /var/nedi/nedi.pl -p -B2 > /var/nedi/log/nedi-backup.lastrun 2>&1
  0 1-23 * * * /var/nedi/nedi.pl -p > /var/nedi/log/nedi.lastrun 2>&1

Upgrading NeDi software
============================

From time to time a new version of NeDi_ may become available (see *Installation* above for downloads),
and you may want to install the update.

The upgrading process must be run as the **root user**. 

Stop all NeDi_ services::

  systemctl stop httpd 
  systemctl stop nedi-monitor 
  systemctl stop nedi-syslog 

and comment out the discovery scripts in crontab::

  crontab -e -u nedi

Now make a **database backup** as shown in the section below, just for safety.

The ``/var/nedi`` directory contains a lot of NeDi_ state information (RRD graphs, switch configurations, etc.) which you want to preserve across the update.
So first make a **backup** of the old version ``/var/nedi``::

  tar czf $HOME/nedi-old-version-backup.tar.gz /var/nedi

Also make backup copies of **all changed configuration files** to some backup directory, for example::

  cd /var/nedi
  cp -p nedi.conf seedlist nedi.pl trap.pl ... <backup-directory>

Here we back up also the Perl (.pl) files (for example, trap.pl) in case you have made any changes manually.

Then overwrite ``/var/nedi`` by the new version (here 1.6.100)::

  cd /var/nedi
  tar xzvf <downloaddir>/nedi-1.6.100.tgz

If there are any patch-files, unpack the latest file as well (for example)::

  tar xzvf <downloaddir>/nedi-1.6p2.tgz

The patch files are cumulative, so only the latest one will be used.

Now make a backup of the new files and copy your old configuration files::

  cp nedi.conf nedi.conf.new
  cp seedlist seedlist.new
  cp -p $HOME/nedi.conf nedi.conf.OLD
  cp $HOME/seedlist seedlist

Now you have to **edit** (do not copy) ``nedi.conf`` because changes always appear in new versions!
You have to go through ``nedi.conf.OLD`` and copy any local changes into the new ``nedi.conf`` file.
The meld_ command is extremely useful for comparing files, install it by::

  yum install meld

.. _meld: https://meldmerge.org

Set correct user and group ownership::

  chown -R nedi.apache /var/nedi/*
  chmod -R g+w /var/nedi/*

**Note:** It is important **not** to make the directories /var/nedi and /var/nedi/.ssh group-writable, since this will cause security problems with SSH logins.

Notice: The web interface user *admin* now has the default password *admin*.
Change the *admin* password as described in our NeDi_ page.

For major releases only, the **MySQL database structures may need updating**.
This is **not required** for patch-releases!
See the *MySQL service* section above before doing::

  ./nedi.pl -i updatedb

.. _NeDi_installation: https://www.nedi.ch/installation/

When the upgrading has completed successfully, restart all NeDi_ services (as *root* user)::

  systemctl start httpd 
  systemctl start nedi-monitor 
  systemctl start nedi-syslog 

and re-enable the discovery scripts in crontab::

  crontab -e -u nedi

Backup and restore of NeDi server
-------------------------------------------------------------

In order to backup the entire NeDi_ server to a different location (for disaster recovery or migration), the following files must be backed up:

1. The directory tree ``/var/nedi``.

2. Make a MySQL_ database mysqldump_ using this script ``/root/mysqlbackup`` (insert the correct MySQL_ password)::

     #!/bin/sh
     # MySQL Backup Script for All Databases
     HOST=localhost
     BACKUPFILE=/root/mysql_dump
     USER=root
     PWD='**********'
     DUMP_ARGS="--opt --flush-logs --quote-names"
     DATABASES="--all-databases"
     /usr/bin/mysqldump --host=$HOST --user=$USER --password=$PWD $DUMP_ARGS --result-file=$BACKUPFILE $DATABASES

   Write permission to $BACKUPFILE is required.

Make regular database dumps, for example by a *crontab* job::

  # MySQL database backup
  30 7 * * * /root/mysqlbackup

.. _mysqldump: https://dev.mysql.com/doc/refman/5.1/en/mysqldump.html

Note: Using the GUI page *System-Snapshot* one may perform a *Database Snapshot* - this is just a special database inside the MySQL_ server, **not a backup**.
The page *System-Export* also allows export of database contents.

.. _MySQL: https://en.wikipedia.org/wiki/MySQL

Restore of a NeDi backup
------------------------

Step 1: The directory tree ``/var/nedi`` must be restored in stead of the vanilla distribution files, and the above `installation <NeDi#nedi-installation>`_ instructions must be followed.

Step 2: NeDi_s MySQL_ database contents must be loaded from the backup.
To restore a MySQL_ database see for example
`How do I restore a MySQL .dump file? <https://stackoverflow.com/questions/105776/how-do-i-restore-a-mysql-dump-file>`_.
As user *root* input the above created backup file::

  mysql -u root -p < /root/mysql_backup

The MySQL_ *password* will be asked for.

If you for some reason need to drop the existing MySQL_ database, the NeDi_ command is::

  cd /var/nedi/
  ./nedi.pl -i

Upgrade of MySQL/MariaDB
------------------------

NOTE: At the time of writing (June 2023) NeDi version 2.3 does not yet support the MariaDB version 10.5,
which is part of EL9 (RHEL 9 and clones).
You have to use EL8 with MariaDB 10.3.

If you restore a database dump onto a different server running a **newer MySQL or MariaDB version**
there are some extra steps:

* Consult the Upgrading_MariaDB_ page with detailed instructions for upgrading between MariaDB_ versions or from MySQL_.

You should run the mysql_upgrade_ command whenever **major (or even minor) version upgrades** are made , or when migrating from MySQL_ to MariaDB_::

  mysql_upgrade -p

It may be necessary to force an upgrade if you have restored a database dump made on an earlier version of MariaDB_,
say, when migrating from CentOS7/RHEL7 to CentOS8/RHEL8::

  mysql_upgrade -p --force

It may be necessary to restart the *mysqld* service or reboot the server after this upgrade (??).

When migrating a database from CentOS/RHEL 7 (EL7) to RHEL 8 (and EL8 clones) you should read
`Upgrading from MariaDB 5.5 to MariaDB 10.0 <https://mariadb.com/kb/en/upgrading-from-mariadb-55-to-mariadb-100/>`_
since there are some incompatible changes between 5.5 and 10.

.. _mysql_upgrade: https://mariadb.com/kb/en/library/mysql_upgrade/
.. _Upgrading_MariaDB: https://mariadb.com/kb/en/upgrading/
