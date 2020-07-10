IT-Wiki at DTU Fysik
====================

.. Contents::

Information to users of the DTU Fysik computer systems
======================================================

The sections below describe DTU IT services of interest to most users at DTU:

* `Network at DTU Fysik`_.
* `DTU Wireless <http://www.wireless.dtu.dk/en.html>`_ networks:

  * `DTU <http://portalen.dtu.dk/DTU_Generelt/AIT/Services/Infrastruktur/Tr%C3%A5dl%C3%B8st%20netv%C3%A6rk.aspx>`_ WiFi network for DTU users only
    (including `DTU guest accounts <http://auth.wireless.dtu.dk/account.html>`_).

  * Eduroam_ available to anyone with an Eduroam_ account (including DTU users):

    * Please see the `Eduroam G-bar wiki page <http://gbar.dtu.dk/index.php/faq/4-eduroam>`_ 
      or the `eduroam Configuration Assistant Tool <https://cat.eduroam.org/>`_
      for assistance with different operating systems (Windows, MacOS, Android, iPhone etc.).

* `VPN connection to DTU`_ network.
* The `DTU Portalen <http://portalen.dtu.dk/>`_ intranet.
* The central mail-server's DTU_spam_filter_.
* When you leave your employment at DTU, please read about IT_when_leaving_DTU_.
* The DTU_Remote_Windows_ desktop and applications (Citrix) service for DTU users.

.. _Eduroam: https://www.eduroam.org/


E-mail client setup at DTU
--------------------------

**DTU webmail service:**
For web browser access to your mail at the central DTU Exchange server, please use the webmail service at https://mail.win.dtu.dk.

For **configuring E-mail client software on your PC** we offer the following advice:

* AIT/DTU `Office 365 Configuration Instructions <https://www.inside.dtu.dk/Medarbejder/IT-og-telefoni/IT-systemer-og-vaerktoejer/Email/FAQ/Mail/Office_365_-_Exchange_Online?fs=1>`_ (DTU login required).
* How to set up Exchange_IMAP_Email_ (IMAP clients such as Thunderbird_) for the central DTU Exchange mail server.
* ExQuilla_ plugin (commercial) for Thunderbird_ using EWS_ (*Exchange Web Services*) for direct access to the Exchange server. 

.. _Thunderbird: https://www.mozilla.org/en-US/thunderbird/
   .. _ExQuilla: https://exquilla.zendesk.com/home
      .. _EWS: https://en.wikipedia.org/wiki/Microsoft_Exchange_Server#Clients

Calendar client setup at DTU
----------------------------

For **configuring calendar client software on your PC** we offer the following advice:

* Microsoft `Outlook <http://en.wikipedia.org/wiki/Microsoft_Outlook>`_ users have built-in calendar functions.
* Microsoft `Outlook Web Access <http://en.wikipedia.org/wiki/Outlook_Web_App>`_ (OWA): You simply log in to the `DTU Outlook Web Access server <https://mail.win.dtu.dk/>`_ using a web browser.
* *Apple Mail* users: Please see the Mac_Mail_client_ for the DTU Exchange server.
* Thunderbird_calendar_ client setup at DTU.
* Evolution_calendar_ client setup at DTU.
* Google_calendar_ client setup.

Pages of interest to Linux users at DTU Fysik
---------------------------------------------

* Linux_backup_ of Ubuntu and other Linuxes
* Linux_Tips_and_Tricks_
* Fedora_Linux_Tips_and_Tricks_
* `X11 on Windows <https://wiki.fysik.dtu.dk/niflheim/X11_on_Windows>`_.

Niflheim Linux cluster administration
=====================================

We have some general information about Linux cluster management for system administrators on the Niflheim_ page.
Users of the Niflheim Linux cluster should consult `The Niflheim WIKI <https://wiki.fysik.dtu.dk/niflheim>`_.

Tivoli Storage Manager
======================

We have some general information for system administrators about Tivoli Storage Manager software for system administrators:

* Tivoli Storage Manager TSM-server_ operation.

* Set up a new TSM server by TSM-server-initialization_ and TSM-server-configuration_.

* Using 2_independent_TSM_servers_ for replicated backups as an extra safety measure.

* Installation and configuration of TSM_client_ software.

Miscellaneous stuff for IT sysadmins
====================================

Here we collect tips and tricks that are relevant only to IT system administrators:

* NeDi_ (*Network Discovery*) open source network monitoring system. Instructions for NeDi_installation_on_CentOS_.

* Linux_firewall_configuration_ (protection against SSH attacks, country blacklists).

* OpenSSH_configuration_ of SSH server.

* Sendmail_configuration_ of SMTP server.

* NFSwatch_ monitoring of an NFS server.

* Dovecot_configuration_ of IMAP server.

* Web server SSL_best_practices_.

* IPv6_configuration_: Collection of information about IPv6_ and DHCPv6_.

* IPv6_deployment_: IPv6_ deployment process at the departmental level.

* ThinLinc_ server and client installation.

* HP_Proliant_firmware_upgrade_ issues.

* HP IMC_ (*Intelligent Management Center*) network monitoring system.

* Apple_TV_ configuration for meeting rooms.

* Huawei_server_ setup.

* Dell_C6420_ and Dell_R640_ server setup.

* Docker_containers_.

* Singularity_ containers.

* Ansible_configuration_.

* `Intel OmniPath network fabric <https://wiki.fysik.dtu.dk/niflheim/OmniPath>`_

* Intel_AMT_ (*Intel® Active Management Technology* with Intel vPro technology) 

* Setting up a Ceph_storage_ platform.

* Install CentOS 7 via PXE_and_UEFI_.

.. _IPv6: http://en.wikipedia.org/wiki/Ipv6
   .. _DHCPv6: http://en.wikipedia.org/wiki/DHCPv6
      .. _Singularity: https://wiki.fysik.dtu.dk/niflheim/Singularity_installation
