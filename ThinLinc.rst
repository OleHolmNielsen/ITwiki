.. _ThinLinc_server:

=======================================
ThinLinc server and client installation
=======================================

ThinLinc_ is a remote desktop server from Cendio_.
Server and Client software is available on the Download_ page.
See also the Documentation_ and Support_ pages.

.. _Cendio: https://www.cendio.com/
.. _ThinLinc: https://www.cendio.com/thinlinc/what-is-thinlinc
.. _Download: https://www.cendio.com/thinlinc/download
.. _Documentation: https://www.cendio.com/thinlinc/docs
.. _Support: https://www.cendio.com/thinlinc/support

.. Contents::

ThinLinc server on RHEL/CentOS 7
================================

Install the server
------------------

Download_ the *ThinLinc Server Bundle* from Cendio_ after registering with them.
Installation of the `server software <https://www.cendio.com/thinlinc/docs/install>`_::

  unzip tl-4.8.0-server.zip
  cd tl-4.8.0-server
  ./install-server

NOTICE: 

* SELinux systems (RHEL/CentOS) require settings of files in ``/opt/thinlinc``, so installation **must** be in that directory (soft-links will break the setup).
* CentOS: A warning will be issued that CentOS 7 is **not supported**.
* To rerun the ThinLinc configuration setup script do::

    /opt/thinlinc/sbin/tl-setup

Many additional RPMs will be installed on the system, and configuration of the firewall and SELinux.

Read the ThinLinc_selinux_ page about installation of ThinLinc on an SELinux-enabled platform.
The SELinux module and other policy changes performed can be examined in ``/opt/thinlinc/share/selinux``. 
Execute the command::

  /opt/thinlinc/share/selinux/install

to reapply ThinLinc's policy changes.

.. _ThinLinc_selinux: https://www.cendio.com/thinlinc/docs/platforms/selinux

If you don't run an *Apache* web-server, some installation warnings will be issued.
A web-server is actually not required for normal operation, for more on that topic see
`Web Integration and HTML5 Browser Client <https://www.cendio.com/resources/docs/tag/clientplatforms_browser_clients.html>`_.

Uninstall server
----------------

If necessary you can uninstall the server packages by::

  yum remove thinlinc*

License installation
--------------------

By default there are 5 user licenses (hard limit is 6).
We can get additional licenses from Bernd Dammann (DTU Compute).

License installation instructions are in https://www.cendio.com/resources/docs/tag/ch04s03.html:

* Transfer each file to your ThinLinc master server and place it in ``/opt/thinlinc/etc/licenses/``. 

* After adding new license files, either restart VSM Server by running::

    /opt/thinlinc/libexec/service vsmserver restart 
 
  or wait until the VSM Server automatically reads in the new licenses, something that happens once every 12 hours. 

Check the licenses by::

  /opt/thinlinc/sbin/tl-show-licenses

See also the log file ``/var/log/thinlinc-user-licenses``.

Configure hostname
------------------

If the server has multiple network interfaces, you may have to configure the primary hostname in ``/opt/thinlinc/etc/conf.d/vsmagent.hconf``, for example::

  agent_hostname=XXX.fysik.dtu.dk

and restart the agent service.

Daemon services
---------------

Several daemon processes are started::

  python-thinlinc /opt/thinlinc/sbin/vsmagent
  python-thinlinc /opt/thinlinc/sbin/tlwebaccess
  /u/opt/thinlinc/libexec/tlstunnel --port 300 --sock /var/run/thinlinc/tlwebaccess-notls.sock --tls-sock /var/run/thinlinc/tlwebaccess-tls.sock --cert /opt/thinlinc/etc/tlwebaccess/server.crt --certkey /opt/thinlinc/etc/tlwebaccess/server.key --logname tlwebaccess --priority NORMAL:-VERS-SSL3.0
  python-thinlinc /opt/thinlinc/sbin/vsmserver

Check the daemons status by::

  systemctl status vsmserver vsmagent tlwebadm tlwebaccess

The daemon logfiles are::

  /var/log/tlwebaccess.log
  /var/log/tlwebadm.log
  /var/log/vsmagent.log
  /var/log/vsmserver.log

and other relevant logfiles are::

  /var/log/thinlinc-install.log
  /var/log/thinlinc-user-licenses
  /var/log/tlsetup.log

Firewall ports
--------------

Network setup is documented in `Preparing the Network for ThinLinc Installation <https://www.cendio.com/resources/docs/tag/network.html>`_.

Several firewall ports are opened by the ThinLinc Server installation, 
see the service files ``/etc/firewalld/services/tl*`` which are referred to in ``/etc/firewalld/zones/public.xml``.
The page `TCP Ports Used by ThinLinc <https://www.cendio.com/resources/docs/tag/tcp-ports.html>`_ 
and `A.2.  On Machine Running VSM Agent <https://www.cendio.com/resources/docs/tag/apas02.html>`_
say that the following TCP ports must be opened in the firewall of the ThinLinc VSM server:

* 22: SSH Daemon
* 300: ThinLinc HTML5 Browser Client
* 904: VSM Agent
* 1010: ThinLinc Administration Interface (tlwebadm)
* 9000: VSM server

If users are supposed to be able to connect using a web browser, using the ThinLinc *HTML5 Browser Client*, they must be able to connect to port 300 on both the VSM server and on all VSM agents. 

To list the current firewall configuration run::

  iptables-save

Only port 22 required
.....................

All that's required for a ThinLinc Client to connect to a Server is an open port 22 (SSH).
The other additional ports mentioned above **are not required** for simple client access via SSH (by default port 22). 

If port 22 is all you need, you may remove the other ThinLinc firewalld services.
List active services by::

  firewall-cmd --list-services

To remove the ThinLinc services permanently do::

  firewall-cmd --permanent --remove-service={tlagent,tlmaster,tlwebaccess,tlwebadm}

Adding desktops
---------------

If your server has a minimal CentOS/RHEL installation without a GNOME_ or other desktop, the ThinLinc client login won't have any available desktops.

* Install GNOME_ (NOTICE: puts a heavy load on the server) by::

    yum groups install "GNOME Desktop" 

* Install Xfce_ Desktop Environment (lightweight desktop).
  For CentOS first add the EPEL_ repository::

    yum install epel-release

  then install Xfce_::

    yum groups install "Xfce"

On CentOS 6 use *yum groupinstall* in stead of *yum groups install*.

See also `How to install Desktop Environments on CentOS 7? <http://unix.stackexchange.com/questions/181503/how-to-install-desktop-environments-on-centos-7>`_.

.. _Xfce: http://www.xfce.org/
.. _EPEL: https://fedoraproject.org/wiki/EPEL

ThinLinc server parameters
--------------------------

Sometimes the ThinLinc server parameters need reconfiguration, and configuration files are in ``/opt/thinlinc/etc/conf.d/``.
See the manual section `14.2. Server Configuration Parameters <https://www.cendio.com/resources/docs/tag/ch14s02.html>`_.

Multiple network interfaces
...........................

If the server has multiple network interfaces, it may be necessary to specify which hostname clients connect to in the file ``vsmagent.hconf``::

  # Public hostname; the hostname that clients are redirected to. If not
  # defined, the agent will use the computer's IP address.
  agent_hostname=server.example.com

This is documented in `3.3.  Preparing the Network for ThinLinc Installation  <https://www.cendio.com/resources/docs/tag/network.html>`_ 
section *3.3.4.3. Configuring the VSM Agents*

Error condition on RHEL/CentOS 7
--------------------------------

Even though the ThinLinc server apparently has installed correctly, clients are unable to connect to it but give an error message::

  ThinLinc login failed (No agent server was available)

In the ``/var/log/messages`` syslog you may see a message like::

  python: SELinux is preventing /u/opt/thinlinc/libexec/tl-session from using the transition access on a process.
  *****  Plugin catchall (100. confidence) suggests   **************************
  If you believe that tl-session should be allowed transition access on processes labeled unconfined_t by default.
  Then you should report this as a bug.
  You can generate a local policy module to allow this access.
  Do allow this access for now by executing:
  grep tl-session /var/log/audit/audit.log | audit2allow -M mypol; semodule -i mypol.pp

You should make sure that ThinLinc has been installed in the default /opt/thinlinc directory (soft-links not permitted).

If you want to check if SELinux is causing troubles, you can temporarily turn SELinux off and on by::

  setenforce 0   # Turn SELinux off
  setenforce 1   # Turn SELinux on

ThinLinc client installation
============================

Client software is available on the Download_ page for many operating systems.

CentOS 7 client
---------------

The 64-bit Linux RPM should be installed::

  yum install https://www.cendio.com/downloads/clients/thinlinc-client-4.XXX.x86_64.rpm

(replace the XXX version number by the current version).

Start the ThinLinc client by::

  tlclient

ThinLinc client problems
------------------------

NOTICE: When starting up ThinLinc with the GNOME_ desktop, a warning pops up::

  Authentication Required
  Authentication is required to create a color managed device

and the client host's superuser password is required for Authentication.
However, you may also just type **Cancel**.

.. _GNOME: https://www.gnome.org/

This problem seems to be a `GNOME bug <https://bugzilla.gnome.org/show_bug.cgi?id=751775>`_.
