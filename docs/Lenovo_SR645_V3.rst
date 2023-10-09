.. _Lenovo_SR645_V3:

========================
Lenovo SR645 V3 server
========================

.. Contents::

This page contains information about Lenovo SR645_V3_ servers deployed in our cluster.
The Lenovo ThinkSystem SR645_V3_ is a 2-socket 1U server that features the AMD EPYC 9004 "Genoa" family of processors. 

.. _SR645_V3: https://lenovopress.lenovo.com/lp1607-thinksystem-sr645-v3-server

Documentation and software
==========================

Lenovo provides SR645_V3_ information and downloads:

* `ThinkSystem SR645 Setup Guide <https://pubs.lenovo.com/sr645/sr645_setup_guide.pdf>`_.
* `Lenovo XClarity Essentials OneCLI <https://support.lenovo.com/us/en/solutions/ht116433-lenovo-xclarity-essentials-onecli-onecli>`_.
* Firmware_updates_
  and `Best practices <https://lenovopress.lenovo.com/lp0656-lenovo-thinksystem-firmware-and-driver-update-best-practices>`_.
  The Firmware_download_ page.
* `Lenovo EveryScale (formerly Lenovo Scalable Infrastructure or LeSI) <https://lenovopress.lenovo.com/lp0900-lenovo-everyscale-lesi>`_ for HPC.

.. _Firmware_updates: https://pubs.lenovo.com/sr645/maintenance_manual_firmware_updates
.. _Firmware_download: https://datacentersupport.lenovo.com/us/en/products/servers/thinksystem/sr645/7d2x/downloads/driver-list/

Booting and BIOS configuration
==============================

Press **F1** during start-up to enter the BIOS and firmware setup menus.
Press **F10** for network boot and **F12** for a one-time boot menu.

XClarity Provisioning Manager
--------------------------------

Initial BMC credentials::

  Username: USERID
  Password: PASSW0RD   (Note the zero)

Note: If you have several SSH authentication key files (``$HOME/.ssh/id_*``) they will be tried in turn, 
and since the BMC accepts a maximum of 5 login attempts, SSH logins may fail with the error::

  Received disconnect from 10.x.x.x port 22:2: Too many authentication failures

Workaround: Specify only 1 of the keys to the SSH command, for example::

  ssh -i $HOME/.ssh/id_rsa <BMC_hostname>

Minimal configuration of a new server or motherboard
----------------------------------------------------

At our site the following minimal settings are required for a new server or a new motherboard.  

The (BMC) setup is accessed via the console or BMC web GUI.
Login with the above credentials.

Changing BMC password: The rules are documented where????  See also password settings below.

**Important**: Set the BMC network address selection to **Obtain IP from DHCP** in stead of the default **First DHCP,
then static IP** so that the BMC does not fall back to a private IP-address!

Now we assume the use of the BMC web GUI.

There is a *Remote Console* menu to open a console in a new browser tab.

In the *Home* menu enter the hostname in *System Information and Settings*.

Change the BMC **Hostname** to the DNS name, or select *Obtain Hostname from DHCP*.
Set IPv6 to Disabled.

In *DNS and DDNS* set Preferred address type: IPv4 and DDNS to Disabled.

Disable *Use DNS to discover Lenovo XClarity Administrator*.

In *Service Enablement and Port Assignment* enable the *IPMI over LAN*.

In the *User/LDAP* menu change the local *User name* from *USERID* to *root*.

Click on *Global Settings* and deselect *Complex password required* and set *Minimum password length* to 8.

In the *Security* menu item set *IPMI SEL Log Wrapping* to Enabled.

In the *Boot Sequence* menu:

  * Click the **Boot Sequence** item to move PXE boot up above the hard disk boot.

Disable ``SMT mode`` (Symmetric Multithreading) in the BIOS setup menu under *UEFI Settings->System setup*.

Firmware upgrades
=================

In the BMC GUI's ``Firmware Update`` window you may install update files.
Go to the Firmware_download_ page and type in the system serial number to search for updates.
Print the serial number by::

  dmidecode -s system-serial-number

You may want to enable these non-default settings:

* **Auto Promote Primary BMC to Backup**

