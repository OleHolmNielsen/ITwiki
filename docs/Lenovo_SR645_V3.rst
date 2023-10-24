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
* `Lenovo XClarity Administrator Product Guide <https://lenovopress.lenovo.com/tips1200-lenovo-xclarity-administrator>`_.
* Lenovo XClarity Essentials OneCLI_ and OneCLI_User_Guide_.
* `Lenovo XClarity Provisioning Manager <https://sysmgt.lenovofiles.com/help/index.jsp?topic=%2Flxpm_frontend%2Flxpm_product_page.html&cp=7>`_.
* Firmware_updates_
  and `Best practices <https://lenovopress.lenovo.com/lp0656-lenovo-thinksystem-firmware-and-driver-update-best-practices>`_.
  The Firmware_download_ page.
* `Lenovo EveryScale (formerly Lenovo Scalable Infrastructure or LeSI) <https://lenovopress.lenovo.com/lp0900-lenovo-everyscale-lesi>`_ for HPC.

.. _OneCLI: https://support.lenovo.com/us/en/solutions/ht116433-lenovo-xclarity-essentials-onecli-onecli
.. _OneCLI_User_Guide: https://pubs.lenovo.com/lxce-onecli/onecli_bk.pdf
.. _Firmware_updates: https://pubs.lenovo.com/sr645/maintenance_manual_firmware_updates
.. _Firmware_download: https://datacentersupport.lenovo.com/us/en/products/servers/thinksystem/sr645v3/7d9c/downloads/driver-list/

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

Configuration using the console
.........................................

The BMC GUI has a *Remote Console* menu to open a console in a new browser tab.
Press **F1** during start-up to enter the BIOS and firmware setup menus.
Use the console to configure the **UEFI setup**.

Go to the menu **BMC settings** submenu **Network settings**:

* Configure **DHCP control** to **DHCP enabled**.
  **Important**: Set the BMC network address selection to **Obtain IP from DHCP**
  in stead of the default **First DHCP, then static IP** so that the BMC does not fall back to a private IP-address!

* Set **IPv6** to **Disabled**.

* When done press **Save Network Settings**.

Go to the menu **UEFI Settings**:

* In **System Settings -> Processors** select Disable ``SMT Mode`` (Symmetric Multithreading).

* In **System Settings -> Network -> Network Stack Settings** you probably want to set **IPv6 PXE Support** to Disabled.

* In **System Settings -> Network -> Network Boot Settings** you have to **unconfigure PXE**
  for each individual NIC that will never be used for network PXE booting:

  - Set **UEFI PXE Mode** to Disabled.
  - Set **Legacy PXE Mode** to Disabled.

* In **Boot Manager -> Change Boot Order** use + and - to change the boot order items to 1) Network, 2) Hard disk.
  Press **Commit Changes and Exit**.

* In **Boot Manager -> Set Boot Priority -> Network Priority** use + and - to move down the priority of IPv6.

* When done press **Save Settings**.

* When all configuration is finished press **Exit UEFI Setup**.

Configuration using the BMC web GUI
.........................................

In the *Home* menu enter the hostname in *System Information and Settings*.

Change the BMC **Hostname** to the DNS name, or select *Obtain Hostname from DHCP*.
Set IPv6 to Disabled.

In *DNS and DDNS* set Preferred address type: IPv4 and DDNS to Disabled.

Disable *Use DNS to discover Lenovo XClarity Administrator*.

In *Service Enablement and Port Assignment* enable the *IPMI over LAN*.

In the *User/LDAP* menu change the local *User name* from *USERID* to *root*.

Click on *Global Settings* and deselect *Complex password required* and set *Minimum password length* to 8.

In the *Security* menu item set *IPMI SEL Log Wrapping* to Enabled.

In the *UEFI Setup -> Boot Manager -> Change boot order* menu:

  * Click the **Change the order** item to move PXE boot up above the hard disk boot.

XClarity Essentials OneCLI
==============================

Lenovo XClarity Essentials OneCLI_ is a collection of command line applications that facilitate
Lenovo server management by providing functions, such as system configuration, system inventory,
firmware and device driver updates.

Download the ``lnvgy_utl_lxcer_onecli01z-4.2.0_linux_x86-64`` RPM file from the download page and install it.
This will create a soft-link ``/usr/bin/onecli`` to the OneCLI_ command.

Some useful OneCLI_ commands are::

  onecli config show
  onecli config show system_prod_data

Saving and restoring system configuration::

  onecli config save --file <savetofilename> [--group <groupname>] [--excbackupctl] [<options>] # Save the current settings
  onecli config replicate --file <filename> [<options>] # Replicate the settings to the other system
  onecli config restore --file <filename> [<options>]   # Restore a saved setting value to the current system

System health commands::

  onecli misc syshealth
  onecli misc syshealth --device system
  onecli misc syshealth --device processor
  onecli misc syshealth --device dimm
  onecli misc syshealth --device power

Firmware upgrades
=================

In the BMC GUI's ``Firmware Update`` window you may install update files.
Go to the Firmware_download_ page and type in the system serial number to search for updates.
Print the serial number by::

  dmidecode -s system-serial-number

You may want to enable these non-default settings:

* **Auto Promote Primary BMC to Backup**

