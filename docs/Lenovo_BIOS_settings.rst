.. _Lenovo_BIOS_settings:

======================================
Lenovo BIOS settings common to servers
======================================

.. Contents::

This page contains information about BIOS settings common to Lenovo servers.

Booting and BIOS configuration
==============================

* Press ``F1`` during start-up to enter the BIOS and firmware setup menus.
  In the BMC GUI you may also press ``Quick Actions`` and select the *Power Action* ``Boot Server to System Setup``.
* Press ``F10`` for network boot and ``F12`` for a one-time boot menu.

The Lenovo UEFI boot goes through PEI_ and DXE_ phases before booting the OS.

.. _PEI: https://uefi.org/specs/PI/1.8/V1_Services_PEI.html
.. _DXE: https://uefi.org/specs/PI/1.8/V2_Overview.html

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

Minimal configuration of a new server or a new motherboard
-----------------------------------------------------------

At our site the following minimal settings are required for a new server or a new motherboard.  

The (BMC) setup is accessed via the console or BMC web GUI.
Login with the above credentials.
Go to the ``BMC Configuration -> User/LDAP`` menus and modify the login credentials:

* Click on ``Global Settings`` and deselect ``Complex password required`` and set ``Minimum password length`` to 8 (or according to your policies).
  Also change ``Minimum password change interval`` to ``0`` so that you can change the password as needed.

* In the ``User/LDAP`` menu edit the BMC local ``User name`` from ``USERID`` to ``root``.
  Here you may also change the password.

Using OneCLI_ one may configure some desirable XCC parameters::

  onecli config set IMM.IMMInfo_Name `hostname -s`
  onecli config set IMM.HostName1 `hostname -s`b
  onecli config set IMM.MinPasswordLen 8
  onecli config set IMM.DDNS_Enable Disabled

.. _OneCLI: https://support.lenovo.com/us/en/solutions/ht116433-lenovo-xclarity-essentials-onecli-onecli

BMC network settings
----------------------

You may change the ``BMC Configuration`` ``Network`` settings:

* Change the BMC ``Hostname`` to the server's DNS name, or select ``Obtain Hostname from DHCP``.

* Configure ``DHCP control`` to ``DHCP enabled``.
  **Important**: Set the BMC network address selection to ``Obtain IP from DHCP``
  in stead of the default ``First DHCP, then static IP`` so that the BMC does not fall back to a private IP-address!

* Set ``IPv6`` to ``Disabled``.

* When done press ``Apply``.

Modify the ``DNS and DDNS`` settings:

* Change DNS ``Preferred address type`` to ``IPv4``.

* Change DDNS_ to ``Disabled``.

* Disable ``Use DNS to discover Lenovo XClarity Administrator``.
  Note: If your network has a DNS server configured to advertise the address of a *Lenovo XClarity Administrator* (LXCA_) instance.
  Lenovo offers a 90 days trial license for LXCA_.
  The BMC will periodically search each DNS server for SRV records defined as: ``_lxca._tcp``.
  If an LXCA_ instance is found, the BMC will attempt to announce its presence to the selected address of LXCA_ instance.

* When done press ``Apply``.

.. _DDNS: https://en.wikipedia.org/wiki/Dynamic_DNS
.. _LXCA: https://sysmgt.lenovofiles.com/help/index.jsp?topic=%2Fcom.lenovo.lxca.doc%2Flxca_overview.html

In ``Service Enablement and Port Assignment`` enable the ``IPMI over LAN``.
The web GUI says::

  The current security settings require incoming IPMI over LAN connection to use cipher suite ID 17.
  If you are using the IPMItool utility (prior to version 1.8.19), you must specify the option “-C 17” to connect to this management controller.

When using the Linux FreeIPMI_ CLI commands use the `-I CIPHER-SUITE-ID` option, for example::

  ipmipower -I 17 -D LAN_2_0 ....

**NOTE:** Some BMC brands (HPE, SuperMicro) unfortunately only support the default cipher suite ``-I 3`` and will reject connections with ``-I 17``.

.. _FreeIPMI: https://www.gnu.org/software/freeipmi/

BMC Security
--------------

You may change the ``BMC Configuration`` ``Security`` settings:

* If desired set the ``IPMI SEL Log Wrapping`` to ``Enabled``.

Configuration using the console
==================================

The BMC GUI has a ``Remote Console`` menu to open a console in a new browser tab.
Press ``F1`` during start-up to enter the BIOS and firmware setup menus.
In the BMC GUI you may also press ``Quick Actions`` and select the *Power Action* ``Boot Server to System Setup``.

Use the console to configure the ``UEFI setup``.

Go to the menu ``BMC settings`` submenu ``Network settings``:

* Configure ``DHCP control`` to ``DHCP enabled``.
  **Important**: Set the BMC network address selection to ``Obtain IP from DHCP``
  in stead of the default ``First DHCP, then static IP`` so that the BMC does not fall back to a private IP-address!

* Set ``IPv6`` to ``Disabled``.

* When done press ``Save Network Settings``.

Go to the menu ``UEFI Setup``:

* In ``System Settings -> Processors`` select Disable ``SMT Mode`` (Symmetric Multithreading).

* In ``System Settings -> Network -> Network Stack Settings`` you probably want to set ``IPv6 PXE Support`` to Disabled.

* In ``System Settings -> Network -> Network Boot Settings`` you have to ``unconfigure PXE``
  for each individual NIC in the ``MAC address`` submenu that will never be used for network PXE booting:

  - Set ``UEFI PXE Mode`` to Disabled.
  - Set ``Legacy PXE Mode`` to Disabled.

* In ``Boot Manager -> Change Boot Order`` use + and - to change the boot order items to 1) Network, 2) Hard disk.
  Press ``Commit Changes and Exit``.

* In ``Boot Manager -> Set Boot Priority -> Network Priority`` use + and - to move down the priority of IPv6.

* When done press ``Save Settings``.

* When all configuration is finished press ``Exit UEFI Setup``.

