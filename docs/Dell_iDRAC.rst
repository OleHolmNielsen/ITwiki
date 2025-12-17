.. _Dell_iDRAC:

================
Dell iDRAC       
================

.. Contents::

This page contains information out Dell iDRAC_ (BMC_) controller in servers.

.. _R640_manuals: https://www.dell.com/support/home/us/en/04/product-support/product/poweredge-r640/manuals
.. _R640_downloads: https://www.dell.com/support/home/us/en/04/product-support/product/poweredge-r640/drivers
.. _Support: https://www.dell.com/support/home/us/en/04/product-support/product/poweredge-r640/research
.. _OpenManage: https://www.dell.com/support/article/us/en/04/sln310664/dell-emc-openmanage-systems-management-portfolio-overview?lang=en
.. _Linux_Engineering: https://linux.dell.com/
.. _Linux_repository: https://linux.dell.com/repo/hardware/
.. _iDRAC: https://en.wikipedia.org/wiki/Dell_DRAC
.. _iDRAC9_manuals: https://www.dell.com/support/home/us/en/19/products/software_int/software_ent_systems_mgmt/remote_ent_sys_mgmt/rmte_ent_sys_idrac9
.. _OpenManage_Ansible_Modules: https://github.com/dell/dellemc-openmanage-ansible-modules
.. _UEFI: https://en.wikipedia.org/wiki/UEFI
.. _BIOS: https://en.wikipedia.org/wiki/BIOS
.. _BMC: https://en.wikipedia.org/wiki/Intelligent_Platform_Management_Interface#Baseboard_management_controller

===============================================================================================

iDRAC (BMC) setup
=================

The Dell iDRAC9_ (BMC_) setup is accessed via the *System Setup* menu item *iDRAC Settings*:

* In the *System Summary* page read the NIC **iDRAC MAC Address** from this page for configuring the DHCP server.

* In the *Network* page set the **Enable IPMI over LAN** to **Enabled**.

* In the *User Configuration* page set the *User 2* (**root**) Administrator user name and change the **password**.
  The Dell iDRAC_ **default password** for *root* is **calvin** and you will be asked to change this at the first login.

  **IMPORTANT:** The iDRAC9_ keyboard layout is **US English**!  Do not use characters that differ from the US layout!

* Optional: In the *Thermal* page set Thermal: **Maximum Performance**.

Press *Finish* to save all settings.

.. _iDRAC9: https://www.dell.com/support/article/us/en/04/sln311300/idrac9-home?lang=en

Dell iDRAC Tools 
----------------------

Install the *Dell iDRAC Tools for Linux* by searching the server's
*Downloads* page for the *Systems Management* category.
A tar-ball such as ``Dell-iDRACTools-Web-LX-11.4.0.0-1435_A00.tar.gz`` may be downloaded
and used to install the Linux tools.
The iDRAC tool packages are provided for a number of Linux distributions.

SSH login to iDRAC
------------------

CLI login to the iDRAC uses SSH as the **root** user.

If you wish, you may add your management server's **SSH public key** to the iDRAC root user account::

  racadm sshpkauth -i 2 -k 1 -t "CONTENTS OF SSH PUBLIC KEY"

For further SSH key options::

  racadm help sshpkauth

iDRAC IP and DNS information
----------------------------

Read the IP v4/v6 information::

  racadm get iDRAC.IPv4
  racadm get iDRAC.IPv6

If DHCP is enabled on iDRAC and you want to use the DNS_ server IP provided by the DHCP server::

  racadm set iDRAC.IPv4.DNSFromDHCP 1
  racadm set iDRAC.NIC.DNSDomainFromDHCP 1
  racadm set iDRAC.NIC.DNSDomainNameFromDHCP 1

The iDRAC DNS_ Name **cannot be obtained from DHCP!**
Therefore you must always set the DNS_ name manually::

    racadm set iDRAC.NIC.DNSRacName <iDRACNAME>

Manual DNS_ settings:

* Set iDRAC DNS_ Domain_name_::

    racadm set iDRAC.NIC.DNSDomainName <DOMAIN.NAME>

* Set iDRAC DNS_ Server::

    racadm config -g cfgLanNetworking -o cfgDNSServer1 x.x.x.x
    racadm config -g cfgLanNetworking -o cfgDNSServer2 y.y.y.y

* Set the server's DNS_ hostname by::

    racadm  set System.ServerOS.HostName <Server-DNS-name>

.. _DNS: https://en.wikipedia.org/wiki/Domain_Name_System
.. _Domain_name: https://en.wikipedia.org/wiki/Domain_name

iDRAC web-server security Host Header enforcement
-------------------------------------------------

Starting with **iDRAC firmware 5.10**, by default, iDRAC9 will check the HTTP / HTTPS Host Header and compare to the *DNSRacName* and *DNSDomainName* iDRAC parameters.
When the values do not match, the iDRAC will refuse the HTTP / HTTPS connection. 
This is a security issue recorded in `CVE-2021-21510 <https://nvd.nist.gov/vuln/detail/CVE-2021-21510>`_ with the description::

  Dell iDRAC8 versions prior to 2.75.100.75 contain a host header injection vulnerability. A remote unauthenticated attacker may potentially exploit this vulnerability by injecting arbitrary ‘Host’ header values to poison a web-cache or trigger redirections

This means that you **cannot** use the iDRAC's DNS_ name to access its web-server!
However, you can still connect to the IP-address in stead of the DNS_ name.

Please read the Dell *Knowledge Base article 000193619* 
`HTTP/HTTPS FQDN Connection Failures On iDRAC9 firmware version 5.10.00.00 <https://www.dell.com/support/kbdoc/en-us/000193619/http-https-fqdn-connection-failures-on-idrac9-firmware-version-5-10-00-00?lwp=rt>`_.

In iDRAC9 5.10.00.00, this *Host Header* enforcement can be disabled with the following RACADM command::

  racadm set idrac.webserver.HostHeaderCheck 0

The iDRAC must be rebooted in order to activate the new settings, for example, from the Linux CLI::

  ipmitool bmc reset cold

The **HostHeaderCheck** variable does not exist in firmware 5.00 and earlier!

See the web-server settings with::

  racadm get idrac.webserver

View Lifecycle errors
---------------------

The Lifecycle log can be read by::

  racadm lclog view 

To select specific events, see help details using::

  racadm help lclog view

For example, select events of type Warning since a specific timestamp and show the last 5 events::

  racadm lclog view -r "2021-09-01 00:00:00" -s Warning -n 5 

View system sensors and power status
------------------------------------

Display system sensors including power, temperature and health::

  racadm getsensorinfo


View inlet temperature
----------------------

View the server's Inlet temperature history::

  racadm inlettemphistory get


SMTP alerts from iDRAC
----------------------

First you must configure the DNS_ name of the iDRAC. 
Then see the guide
`PowerEdge: How to Configure iDRAC Email Alerts <https://www.dell.com/support/article/us/en/04/sln309388/dell-idrac-how-to-configure-the-email-notifications-for-system-alerts-on-idrac-7-8-and-9?lang=en>`_.

Use the iDRAC web GUI:

* In *iDRAC Settings->Connectivity->Network->Common Settings* configure the iDRAC's hostname and DNS_ Domain_name_.

* In *iDRAC Settings->Settings->SMTP (Email) Server Settings* configure your ``SMTP (Email) Server IP Address or FQDN / DNS Name``.

* Configure alerts in *Configuration->System Settings->Alert Configuration->Alerts->SMTP (Email) Configuration* sub-menu and set up the alert recipient in ``Destination Email Address``.

TSR reports from iDRAC
----------------------

TSR system reports for *Dell Support* cases are normally generated using the iDRAC web interface.

It is also possible to generate TSR reports using the racadm_ techsupreport_ subcommand::

  racadm techsupreport collect

Check the progress of the report generation with::

  racadm jobqueue view

After some minutes export the completed  TSR report to a local ZIP file::

  racadm techsupreport export -f <filename>.zip

.. _racadm: https://www.dell.com/support/manuals/us/en/04/idrac9-lifecycle-controller-v3.0-series/idrac_3.00.00.00_racadm/introduction
.. _techsupreport: https://www.dell.com/support/manuals/us/en/04/idrac9-lifecycle-controller-v3.0-series/idrac_3.00.00.00_racadm/techsupreport?guid=guid-168e5beb-9a71-4d37-af2a-04b73ec11a99&lang=en-us


iDRAC server power management
-----------------------------

The server power can be managed from the iDRAC web interface under the *Dashbord* pull-down menu *Graceful shutdown*.

The iDRAC9_ CLI can also be used to manage server power.
Use SSH to login to the CLI, and the *Help* menu states this::

  /admin1-> racadm help serveraction
  serveraction -- perform system power management operations
  Usage:
  racadm serveraction <action>
  <action>:  server power management operation to perform.  Must be one of:
             graceshutdown   : perform a graceful shutdown of server
             powerdown       : power server off
             powerup         : power server on
             powercycle      : perform server power cycle
             hardreset       : force hard server power reset
             powerstatus     : display current power status of server
             nmi             : Genarate Non-Masking Interrupt to halt system operation 

To hard power cycle the server::

  racadm serveraction hardreset 

LCD front panel display
-----------------------

In the web interface, go to *Configurations > System Settings > Hardware Settings > Front Panel configuration*.

In the CLI::

  racadm help System.LCD.Configuration

For example, set Front LCD to the OS hostname::

  racadm set System.LCD.Configuration 16


iDRAC or LifeCycle Controller errors
------------------------------------

If the iDRAC controller seems frozen, or if the LifeCycle Controller (LCC) has errors, one should try to perform a *deep power drain*.

We have seen the R640 LCC going into a **Recovery Mode** preventing the setting of BIOS_ parameters using racadm_, and an error message on the console::

  Couldn't locate device handle for MAS001.. System rebooting 

This error was resolved by a deep power drain of the server.

Deep power drain procedure
..........................

* Pull both power cables from the server
* Hold down the power button for 30 seconds
* Plug the power cables back in 
* Wait for 30-60 seconds before powering the server on. This will drain the residing power from the capacitors and waiting 30-60 seconds before powering on will allow the iDRAC to complete post.
* Connect via the idrac and follow the boot process via the virtual or physical console. 

iDRAC Easy Restore
------------------

See the iDRAC9_ User's Guide:

After you replace the motherboard on your server, Easy Restore allows you to automatically restore the following data:

• System Service Tag
• Asset Tag
• Licenses data
• UEFI_ Diagnostics application
• System configuration settings—BIOS, iDRAC, and NIC

Easy Restore uses the Easy Restore flash memory to back up the data. When you replace the motherboard and power on the system, the
BIOS_ queries the iDRAC and prompts you to restore the backed-up data. The first BIOS_ screen prompts you to restore the Service Tag,
licenses, and UEFI_ diagnostic application. The second BIOS_ screen prompts you to restore system configuration settings. If you choose not
to restore data on the first BIOS_ screen and if you do not set the Service Tag by another method, the first BIOS_ screen is displayed again.
The second BIOS_ screen is displayed only once.

Resetting the iDRAC
-------------------

The Integrated Dell Remote Access Controller (iDRAC) is responsible for system profile settings and out-of-band management. 
Sometimes, iDRAC may become unresponsive due to various reasons. 
Symptoms of unresponsive iDRAC include the following:

* Racadm command returns "ERROR: Unable to perform requested operation"
* No ssh/telnet access to the iDRAC (the attempted connection times out)
* No iDRAC browser access
* Pinging the iDRAC IP Address fails

The iDRAC can be reset using the System Identification button:

* https://www.dell.com/support/kbdoc/da-dk/000126703/how-to-reset-the-internal-dell-remote-access-controller-idrac-on-a-poweredge-server?lang=en
