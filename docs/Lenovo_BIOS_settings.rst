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
* Press ``F10`` for PXE_ network boot.
* Press ``F12`` for a one-time boot menu with all available selections.

Note: The Lenovo UEFI_ boot goes through PEI_ and DXE_ phases before booting the OS.

.. _UEFI: https://en.wikipedia.org/wiki/UEFI
.. _PEI: https://uefi.org/specs/PI/1.8/V1_Services_PEI.html
.. _DXE: https://uefi.org/specs/PI/1.8/V2_Overview.html
.. _PXE: https://en.wikipedia.org/wiki/Preboot_Execution_Environment

XClarity Provisioning Manager
==================================

Initial BMC login credentials are::

  Username: USERID
  Password: PASSW0RD   (Note the zero!)

Notes:

* At the first login the user ``USERID`` is **required to change the password**.
  By default the password must be at least 10 characters long and have some complexity.

* If using SSH login and you have several SSH_ authentication key files (``$HOME/.ssh/id_*``) they will be tried in turn, 
  and since the BMC accepts a maximum of 5 failed login attempts, SSH_ logins may fail with the error::

    Received disconnect from 10.x.x.x port 22:2: Too many authentication failures

  Workaround: Specify only one selected key to the SSH_ command, for example::

    ssh -i $HOME/.ssh/id_rsa <BMC_hostname>

.. _SSH: https://en.wikipedia.org/wiki/Secure_Shell

Minimal configuration of the BMC of a new server or replaced motherboard
=============================================================================

At our site the following minimal settings are required to configure a new server
or a replacement motherboard in an existing server.  

The BMC setup is accessed via the physical console or BMC web GUI.
Login with the above credentials.

BMC user configuration
------------------------

Go to the ``BMC Configuration -> User/LDAP`` menus and modify the login credentials as follows.

Click on ``Global Settings``:
 
1. Deselect ``Force to change password on first access`` 
2. Deselect ``Complex password required`` 
3. Set ``Minimum password length`` to ``8`` (or according to your site security policies).
4. Change ``Minimum password change interval`` to ``0`` so that you can change the password as needed.

In the ``User/LDAP`` menu it is preferable to change the BMC local ``User name``
from the factory default value of ``USERID`` to ``root``.
Unfortunately, it is **no longer possible** to change a BMC user name while that user is logged in!

Therefore a complicated procedure is required for the user name change:

* Click on ``+ Create`` to create a new **temporary user**, say, ``root3``.
  Enter a password for the ``root3`` user and click **Apply**.
  Note: The ``root3`` user will have an ``ID=3`` value as shown by the Linux command
  (if the OS is up and running)::

    ipmitool user list 2

* Logout user ``USERID`` from the BMC GUI, and login again as the ``root3`` user.

* Go to the ``User/LDAP`` menu and change the original user name ``USERID`` into ``root``.
  In ``User accessible interface`` use the pull-down menu to add also ``IPMI over Lan``.
  After this you are requested to enter a new password for the renamed ``root`` user.
  Then click ``Apply``.

* Logout user ``root3`` of the BMC GUI, and login again as the ``root`` user.

* Recommended for security: In the ``User/LDAP`` menu delete the temporary ``root3`` user.

.. _OneCLI: https://support.lenovo.com/us/en/solutions/ht116433-lenovo-xclarity-essentials-onecli-onecli

BMC network settings
----------------------

You may change the ``BMC Configuration->Network`` settings:

* Change the ``Network Interface Port`` (if available) to ``Dedicated`` (default may be LOM).
  Note that the ports' MAC_address_ are different for the different Ethernet ports!

* Select ``Obtain Hostname from DHCP``.
  Alternatively, change the ``Host Name`` field to the BMC's DNS name. 

* In the ``Ethernet Configuration`` field ``Method`` menu change the setting to ``DHCP enabled``
  in stead of the default ``First DHCP, then static IP``
  so that the BMC does not fall back to an unreachable private IP-address!

* Set ``IPv6`` to ``Disabled``.

* When done press ``Apply``.

Modify the ``DNS and DDNS`` settings:

* Change DNS ``Preferred address type`` to ``IPv4``.

* Change DDNS_ to ``Disabled``.

* Disable ``Use DNS to discover Lenovo XClarity Administrator``.
  Note: If your network has a DNS server configured to advertise the address of a *Lenovo XClarity Administrator* (LXCA_) instance.
  Lenovo offers a **90 days trial license** for LXCA_.
  The BMC will periodically search each DNS server for SRV records defined as: ``_lxca._tcp`` in your DNS domain.
  If an LXCA_ instance is found, the BMC will attempt to announce its presence to the selected address of LXCA_ instance.

* When done press ``Apply``.

.. _MAC_address: http://en.wikipedia.org/wiki/MAC_address
.. _DDNS: https://en.wikipedia.org/wiki/Dynamic_DNS
.. _LXCA: https://sysmgt.lenovofiles.com/help/index.jsp?topic=%2Fcom.lenovo.lxca.doc%2Flxca_overview.html

IPMI over Lan
...................

In ``Service Enablement and Port Assignment`` enable the ``IPMI over LAN``.
The web GUI says::

  The current security settings require incoming IPMI over LAN connection to use cipher suite ID 17.
  If you are using the IPMItool utility (prior to version 1.8.19), you must specify the option “-C 17” to connect to this management controller.

When using the Linux FreeIPMI_ CLI commands use the `-I CIPHER-SUITE-ID` option, for example::

  ipmipower -I 17 -D LAN_2_0 ....

**NOTE:** Some BMC brands (HPE, SuperMicro) unfortunately only support the default cipher suite ``-I 3`` and will reject connections with ``-I 17``.

Optional: If your server is actually up and running a Linux OS,
you can also use OneCLI_ to configure BMC network parameters,
see the :ref:`XClarity_Essentials_OneCLI` page.

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

