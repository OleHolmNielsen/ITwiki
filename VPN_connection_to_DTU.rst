.. _VPN_connection_to_DTU:

=============================
VPN connection to DTU network
=============================

.. Contents::

In order to connect to the network inside DTU from a remote location, you may use a VPN_ (*Virtual Private Network*) connection to the DTU network routers.

The user's **primary profile** in DTUbasen_ determines *which* departmental VPN_ subnet_ the user will be logged into.

Any **secondary profiles** in DTUbasen_ will be ignored by the VPN_ server.
DTU students will be logged in to the students' VPN_ subnet_ and cannot use any departmental VPN_ subnet_.

.. _DTUbasen: https://www.dtubasen.dtu.dk
.. _subnet: http://en.wikipedia.org/wiki/Subnetwork
.. _VPN: http://en.wikipedia.org/wiki/Virtual_private_network

VPN_ login will permit you to access DTU's central administrative systems, 
and possibly selected services in your department network, if configured by your department's IT service.
Contact your department IT service for further information.

Usage instructions
==================

The DTU Cisco routers have a service for which you need to install the Cisco AnyConnect_client_ on your remote computer.
See DTU VPN information in the page `VPN Cisco AnyConnect <https://www.inside.dtu.dk/en/medarbejder/it-og-telefoni/wifi-og-fjernadgang/vpn-cisco-anyconnect>`_ in DTU Inside.

.. _AnyConnect_client: http://www.cisco.com/en/US/products/ps8411/tsd_products_support_series_home.html

The simple usage instructions are:

* Go to the web-page https://extra-vpn.ait.dtu.dk.
  You may also use the older VPN server https://vpn.ait.dtu.dk, but it has fewer user licenses.
* Log in with your DTU initials.
* Select the icon *AnyConnect* and press *Start* to install the AnyConnect_client_ software on your PC.

Now you are connected to your department's dedicated VPN_ subnet_ within the Cisco router.
Please note that this is **not** the department internal network, but a special VPN_ subnet_ within the Cisco routers.

Further information about AnyConnect
------------------------------------

The AnyConnect_client_ `product homepage <http://www.cisco.com/en/US/products/ps10884/index.html>`_.

Mac OS X users
==============

Try the automatic installation first:  

* If it continues to ask for your DTU password, quit your browser and start again.
* If the automatic installation fails, it will give you the option of downloading and installing manually.  Download the disk image and install by double-clicking on the package.  It will install to a Cisco subfolder of your normal Applications folder, and the client will **not** be configured.  First time you use it, type the address ``vpn.ait.dtu.dk`` manually.

Then it should work.

Notice: it is possible that with Mac OS 10.15, which only supports 64-bit applications, the Cisco AnyConnect 32-bit application (as of October 2019) cannot run.
See Cisco Bug ID CSCvq32554_ (login required).
This issue may possibly be resolved now (March 2020).

.. _CSCvq32554: https://bst.cloudapps.cisco.com/bugsearch/bug/CSCvq32554/?rfs=iqvred

OpenConnect for Mac
-------------------

Install openconnect_ using Homebrew_.

Then run this command::

  sudo openconnect --no-dtls vpn.ait.dtu.dk

The *--no-dtls* is required see the openconnect_manual_.

.. _openconnect: https://www.infradead.org/openconnect/
.. _Homebrew: https://brew.sh/
.. _openconnect_manual: https://www.infradead.org/openconnect/manual.html

Linux users
===========

Cisco doesn't seem to offer *AnyConnect* software for Linux, so you may try the openconnect_ software package.  
To install this on CentOS/RHEL Linux use the EPEL_ repository::

  yum install epel-release
  yum install openconnect

Using openconnect_ (see `connecting <http://www.infradead.org/openconnect/connecting.html>`_)::

  sudo openconnect https://vpn.ait.dtu.dk

.. _EPEL: https://fedoraproject.org/wiki/EPEL

Using OpenConnect VPN software
------------------------------

Linux users may alternatively try to use the OpenConnect VPN software available from http://www.infradead.org/openconnect/connecting.html.
For Fedora Linux the relevant RPM is *NetworkManager-openconnect*.

Usage instructions: *Installing and Using AnyConnect on Ubuntu Desktop*:

* https://www.cisco.com/c/en/us/support/docs/smb/routers/cisco-rv-series-small-business-routers/Kmgmt-785-AnyConnect-Linux-Ubuntu.html

Linux machines should use the packages vpnc og openconnect.
The command to start a VPN tunnel is::

  sudo openconnect -s /etc/vpnc/vpnc-script vpn.ait.dtu.dk

See this `VPN installation - Linux <http://medarbejdere.au.dk/en/administration/it/it-at-the-main-academic-areas/it-at-science-and-technology/aarhus/network/vpn/vpn-linux/>`_ page.


Department of Physics (FYS) VPN users only
==========================================

For FYS users, the DTU VPN_ allows access also to internal HTTP/HTTPS web servers, Remote Desktop servers, and SSH servers.
