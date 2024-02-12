.. _Lenovo_BIOS_settings:

========================================
Lenovo BIOS settings common to servers
========================================

.. Contents::

This page contains information about Lenovo BIOS settings common to servers.

Booting and BIOS configuration
==============================

* Press **F1** during start-up to enter the BIOS and firmware setup menus.
* Press **F10** for network boot and **F12** for a one-time boot menu.

XClarity Provisioning Manager
--------------------------------

Initial BMC login credentials::

  Username: USERID
  Password: PASSW0RD   (Note the zero!)

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

Go to the menu **UEFI Setup**:

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
The web GUI says::

  The current security settings require incoming IPMI over LAN connection to use cipher suite ID 17.
  If you are using the IPMItool utility (prior to version 1.8.19), you must specify the option “-C 17” to connect to this management controller.

With FreeIPMI_ use the `-I CIPHER-SUITE-ID` option, for example::

  ipmipower -I 17 -D LAN_2_0 ....

**NOTE:** Some BMC brands (HPE, SuperMicro) unfortunately only support the default cipher suite ``-I 3`` and will reject connections with ``-I 17``.

In the *User/LDAP* menu change the local *User name* from *USERID* to *root*.

Click on *Global Settings* and deselect *Complex password required* and set *Minimum password length* to 8.

In the *Security* menu item set *IPMI SEL Log Wrapping* to Enabled.

In the *UEFI Setup -> Boot Manager -> Change boot order* menu:

  * Click the **Change the order** item to move PXE boot up above the hard disk boot.

.. _FreeIPMI: https://www.gnu.org/software/freeipmi/
