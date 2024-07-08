.. _Dell_R640:

================
Dell R640 server
================

.. Contents::

This page contains information out Dell PowerEdge R640_ could servers which we have deployed in our cluster.

.. _R640: https://www.dell.com/en-us/work/shop/povw/poweredge-r640

Documentation and software
==========================

Dell Support_ provides R640_ information:

* R640_manuals_.
* R640_downloads_.
* iDRAC9_manuals_.
* Dell OpenManage_.
* Dell Linux_Engineering_ site.
* Dell Linux_repository_.
* Dell EMC OpenManage_Ansible_Modules_.

.. _R640_manuals: https://www.dell.com/support/home/us/en/04/product-support/product/poweredge-r640/manuals
.. _R640_downloads: https://www.dell.com/support/home/us/en/04/product-support/product/poweredge-r640/drivers
.. _Support: https://www.dell.com/support/home/us/en/04/product-support/product/poweredge-r640/research
.. _OpenManage: https://www.dell.com/support/article/us/en/04/sln310664/dell-emc-openmanage-systems-management-portfolio-overview?lang=en
.. _Linux_Engineering: https://linux.dell.com/
.. _Linux_repository: https://linux.dell.com/repo/hardware/
.. _iDRAC: https://en.wikipedia.org/wiki/Dell_DRAC
.. _iDRAC9_manuals: https://www.dell.com/support/home/us/en/19/products/software_int/software_ent_systems_mgmt/remote_ent_sys_mgmt/rmte_ent_sys_idrac9
.. _OpenManage_Ansible_Modules: https://github.com/dell/dellemc-openmanage-ansible-modules

Monitoring CPU and power
========================

The turbostat_ command reports  processor  topology,  frequency, idle power-state statistics, temperature and power on X86 processors.
Examples of usage are::

  turbostat --Summary --quiet
  turbostat --show CoreTmp,PkgTmp,PkgWatt,Bzy_MHz

.. _turbostat: https://www.linux.org/docs/man8/turbostat.html

Dell OpenManage
===============

Download the OpenManage_ software ISO image from the R640_downloads_ page in the *Systems Management* download category.

Download the *Dell EMC OpenManage Deployment Toolkit (Linux)* DTK ISO file and mount it on ``/mnt``.

Dell EMC System Update (DSU)
----------------------------

Dell EMC System Update (DSU_) is a script optimized update deployment tool for applying *Dell Update Packages* (DUP) to Dell EMC PowerEdge servers. 
See the `DSU manuals <https://www.dell.com/support/home/us/en/04/product-support/product/system-update-v1.6.0/manuals>`_.

The DSU_ may also be configured as a Yum repository, see the DSU_ page.  
The commands are::

  curl -O https://linux.dell.com/repo/hardware/dsu/bootstrap.cgi
  bash bootstrap.cgi

Alternatively, download the ``Systems-Management_Application_*`` file and execute it.

This will create the Yum repository file::

  /etc/yum.repos.d/dell-system-update.repo

Install RPM packages including iDRAC_ tools::

  yum install dell-system-update srvadmin-idracadm7 

Using DSU_ to preview Dell upgrades::

  /usr/sbin/dsu -n -p

To apply Dell upgrades::

    /usr/sbin/dsu -u

.. _DSU: http://linux.dell.com/repo/hardware/dsu/

Systems Management Managed Node Core and CLI
--------------------------------------------

Install the package::

  yum install srvadmin-omacore

Disk reports::

  omreport storage vdisk                      # List of Virtual Disks in the System
  omreport storage pdisk controller=1         # List of Physical Disks on Controller 1
  omreport storage pdisk controller=1 vdisk=0 # List of Physical Disks belonging to Virtual Disk0

racadm command
--------------

Make a soft link for the ``racadm`` command::

  ln -s /opt/dell/srvadmin/bin/idracadm7 /usr/local/bin/racadm

Read the `Integrated Dell Remote Access Controller 9 RACADM CLI Guide <https://www.dell.com/support/manuals/en-us/oth-t140/idrac9_5.xx_racadm_pub>`_.

There is a useful `racadm cheat sheet <https://www.gooksu.com/2015/04/racadm-quick-dirty-cheatsheet/>`_.

Get Health LED status::

  racadm getled

Make the LED blink::

  racadm setled -l 1

Stop the LED from blinking::

  racadm setled -l 0

Get system and version information::

  Service Tag: racadm getsvctag
  System info: racadm getsysinfo -s
  Versions:    racadm getversion
  BIOS:        racadm getversion -b
  CPLD:        racadm getversion -c
  iDRAC:       racadm getversion -f idrac

Get system logs::

  SEL Event Log: racadm getsel
  Lifecycle Log: racadm lclog view

Get hardware inventory information::

  racadm hwinventory

Clone system configuration with racadm
......................................

The ``racadm`` command can be used to get and set the system configuration using::

  --clone Gets the configuration .xml files without system-related details such as service tag. The .xml file received does not have any virtual disk creation option.

For example::

  racadm get --clone -t xml -f config.xml

In the ``config.xml`` you may possibly want to delete the line setting the iDRAC password so that your current password is preserved::

  <Attribute Name="Users.2#Password">Calvin#SCP#CloneReplace1</Attribute>

To use the config.xml on another server and **reboot automatically by default**::

  racadm set -t xml -f config.xml

To postpone the reboot::

  racadm set -t xml -f config.xml -b NoReboot

Add the ``--preview`` to just check the operation.

You can also reconfigure just a single setting component with the ``-c`` flag, for example::

  racadm set -t xml -f config.xml -c NIC.Integrated.1-1-1 -b NoReboot

To configure the UEFI boot order::

  racadm set bios.biosbootsettings.UefiBootSeq NIC.PxeDevice.1-1,Disk.SATAEmbedded.A-1

or configure this setting in the `config.xml` file::

  <Attribute Name="UefiBootSeq">NIC.PxeDevice.1-1, Disk.SATAEmbedded.A-1</Attribute>

The server will need to be rebooted, see the ``racadm set -b NoReboot|Graceful|Forced`` options in::

  racadm help set

The ``racadm set`` operation launches an iDRAC job which must complete before you reboot the server.
See the job status by::

  racadm jobqueue view -i JID_xxxxxx

Setting system parameters
-------------------------

Set the E-mail alerts destination::

  racadm set iDRAC.EmailAlert.Address.1 <some-email-address>

View the BIOS boot mode::

  racadm get BIOS.BiosBootSettings

To set the boot mode to UEFI at the next reboot::

  racadm set BIOS.BiosBootSettings.BootMode Uefi
  racadm jobqueue create BIOS.Setup.1-1

Note: It seems that additional UEFI parameters also need to be set (TBD)::

  UefiBootSeq NIC.PxeDevice.1-1,Disk.SATAEmbedded.A-1
  HddPlaceholder Enabled

To enable **IPMI over LAN**::

  racadm set iDRAC.IPMILan.Enable 1

The server needs to be rebooted in order for the new setting to take effect.

Get a list of settings::

  racadm get BIOS

To read some current values::

  racadm get iDRAC.IPMILan
  racadm get BIOS.ProcSettings
  racadm get BIOS.SysProfileSettings
  racadm get BIOS.SysProfileSettings.WorkloadProfile

See the manual `Configuring IPMI over LAN using RACADM <https://www.dell.com/support/manuals/da-dk/oth-r750/idrac9_4.00.00.00_ug_new/configuring-ipmi-over-lan-using-racadm?guid=guid-e84fe7b0-1d24-470d-a09a-2e2d009bc0bb&lang=en-us>`_.

To enable **WakeOnLan** first check the installed NICs (network adapters), for example::

  racadm get NIC.NICConfig
  NIC.NICConfig.1 [Key=NIC.Embedded.1-1-1#NICConfig]
  NIC.NICConfig.2 [Key=NIC.Embedded.2-1-1#NICConfig]

View the NIC settings::

  racadm get NIC.NICConfig.1

Set the WakeOnLan::

  racadm set NIC.NICConfig.1.WakeOnLan Enabled

Then you must create a job for this NIC::

  racadm jobqueue create NIC.Embedded.1-1-1

A new setting will only take effect after a system reboot.


PERC H330 RAID controller
=========================

The R640_ comes with a PERC H330_ RAID controller.

By default the installed disks are unallocated, and you have to configure their usage.

Press **F2** during start-up to enter the setup menus.
Go to the *Device Settings* menu.

Configure the H330_ via the menu item *Device Settings* and select the RAID controller item:

* In the RAID controller *Main Menu* select the *Configuration Management* item.

* Change the disk setup into **Convert to Non-RAID**.

* In the *Controller Management* menu item *Select Boot Device* define the non-RAID disk as the boot device.

Press *Finish* to save all settings.

.. _H330: https://www.dell.com/en-us/shop/dell-perc-h330-raid-controller/apd/405-aadw/storage-drives-media

raidcfg tool
------------

The OpenManage_ tool raidcfg_ can be installed from the above mentioned *Dell EMC OpenManage Deployment Toolkit (Linux)* folder ``/mnt/RPMs/rhel7/x86_64/``::

  yum install raidcfg*rpm

See `raidcfg quick reference <https://www.dell.com/support/manuals/us/en/04/poweredge-r640/dtk_cli-v6/quick-reference-to-raidcfg-commands?guid=guid-9b466297-bc89-49f5-99a9-ab29ea937d41&lang=en-us>`_.

To list installed RAID controllers::

  /opt/dell/toolkit/bin/raidcfg controller

.. _raidcfg: https://www.dell.com/support/manuals/us/en/04/poweredge-r640/dtk_cli-v6/raidcfg?guid=guid-94012b57-ca54-44c3-9319-e472d0598ff4&lang=en-us

perccli tool
------------

The perccli_ tool for Linux is downloaded from the PowerEdge server's *SAS RAID* downloads

Install the RPM (the version may differ)::

  tar xzf perccli_linux_NF8G9_A07_7.529.00.tar.gz
  cd perccli_7.5-007.0529_linux/
  yum install perccli-007.0529.0000.0000-1.noarch.rpm 
  ln -s /opt/MegaRAID/perccli/perccli64 /usr/local/bin/perccli

See the *Reference Guide* at https://topics-cdn.dell.com/pdf/dell-sas-hba-12gbps_reference-guide_en-us.pdf

Example command::

  perccli show

Disk status
...........

This command shows all disks for controller 1::

  perccli /c1/eall/sall show 

This command shows the RAID rebuild status for controller 1::

  perccli /c1/eall/sall show rebuild


.. _perccli: https://www.dell.com/support/home/us/en/04/drivers/driversdetails?driverid=f48c2

Booting and BIOS configuration
==============================

Press **F2** during start-up to enter the BIOS and firmware setup menus.
Go to the *BIOS Settings* menu.

Minimal configuration of a new server or motherboard
----------------------------------------------------

At our site the following minimal settings are required for a new server or a new motherboard.  
Remaining settings will be configured by racadm_.

The Dell iDRAC9_ (BMC) setup is accessed via the *System Setup* menu item *iDRAC Settings*:

* In the *System Summary* page read the NIC **iDRAC MAC Address** from this page for configuring the DHCP server.

* In the *Network* page set the **Enable IPMI over LAN** to **Enabled**.

Go to the *System Setup* menu item *Device Settings* and select the *Integrated NIC* items:

* In the NIC *Main Configuration Page* select *NIC Configuration*.  We use **NIC port 3** (1 Gbit) as the system's NIC.

* Read the NIC **Ethernet MAC Address** from this page for configuring the DHCP server.

* Select the **Legacy Boot Protocol** item **PXE**.

*Boot Sequence* menu:

  * Click the **Boot Sequence** item to move PXE boot up above the hard disk boot.

Boot settings menu
------------------

* **Boot Mode** = **BIOS**.

* In the *Boot Sequence* menu:

  * Click the **Boot Sequence** item to move PXE boot up above the hard disk boot (if desired).

  * Verify that the correct devices are selected in *Boot Option Enable/Disable*.

UEFI boot settings
------------------

If UEFI boot mode is selected, the following must be enabled before installing the OS for the first time:

* In the **Boot Setting** menu:

  * **Hard-disk Drive Placeholder = Enabled**

Memory settings menu
--------------------

* **Memory Operating Mode** = **Optimizer Mode**.
* **Node interleaving** = **Disabled**.
* **Opportunistic Self-Refresh** = **Disabled**.
* **ADDDC setting** = **Disabled**.

*Adaptive Double DRAM Device Correction* (ADDDC) that is available when a system is configured with memory that has x4 DRAM organization (32GB, 64GB DIMMs). 
ADDDC is not available when a system has x8 based DIMMs (8GB, 16GB) and is immaterial in those configurations. 
For HPC workloads, it is recommended that ADDDC be set to disabled when available as a tunable option.
See 
`BIOS characterization for HPC with Intel Cascade Lake processors <https://www.dell.com/support/kbdoc/da-dk/000176921/bios-characterization-for-hpc-with-intel-cascade-lake-processors>`_.

Processor settings menu
-----------------------

* Disable Hyperthreading by **Logical Processor** = **Disabled**.

* **Virtualization Technology** = **Disabled**.

* **Dell Controlled Turbo** = **Disabled**.

* **Sub NUMA Cluster** = **Enabled**.

The *Sub NUMA Cluster* (SNC_, replaces the older Cluster-on-Die (COD) implementation) has been shown to improve performance, see
`BIOS characterization for HPC with Intel Cascade Lake processors <https://www.dell.com/support/kbdoc/da-dk/000176921/bios-characterization-for-hpc-with-intel-cascade-lake-processors>`_.
This will cause each processor socket to have **two NUMA domains** for the two memory controllers, so a dual-socket server will have 4 NUMA domains.

Display the NUMA domains by::

  $  numactl --hardware
  available: 4 nodes (0-3)
  ...

.. _SNC: https://software.intel.com/content/www/us/en/develop/articles/intel-xeon-processor-scalable-family-technical-overview.html

System Profile Settings menu
----------------------------

* **System Profile** = **Performance**.

System Thermal settings
-----------------------

System Thermal Profile settings can be changed based on the need to maximize performance or power efficiency.
This can make **CPU thermal throttling** less likely.

Read the document `Custom Cooling Fan Options for Dell EMC PowerEdge Servers <https://downloads.dell.com/manuals/common/customcooling_poweredge_idrac9.pdf>`_.

In the BIOS setup screen, select **iDRAC->Thermal** and configure **Thermal profile = Maximum performance**.

Read the current settings::

  racadm get System.ThermalSettings

For HPC applications set the fans to high performance::

  racadm set System.ThermalSettings.ThermalProfile "Maximum Performance"
  racadm set System.ThermalSettings.MinimumFanSpeed 25

A ``MinimumFanSpeed`` value of **255** indicates the **Default** setting.
Values between 21 (the default) and 100 may be used, but high values consume lots of power and generate noise.
For HPC systems a ``MinimumFanSpeed`` of 40 to 50 may perhaps be useful.

System Security menu
--------------------

* **AC Power Recovery** = **Last** state.

Miscellaneous Settings menu
---------------------------

* **Keyboard NumLock** = **Off**.

.. _NVDIMM_Setup:

NVDIMM Optane persistent memory setup
=========================================

Note that Intel has discontinued NVDIMM_ Optane persistent memory with recent processor generations
as described in the Optane_EOL_ page.
Documentation of NVDIMM_ Optane persistent memory:

* NVDIMM_Wiki_ at kernel.org.
* `Using NVDIMM persistent memory storage <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/managing_storage_devices/using-nvdimm-persistent-memory-storage_managing-storage-devices>`_.

Configuration of persistent memory in Dell PowerEdge servers is described in the manual *Dell EMC PMem 200 Series User's Guide* 
in the `server documentation <https://www.dell.com/support/home/en-uk/product-support/product/poweredge-r750/docs>`_:

* To configure NVDIMM_ 3D_XPoint_ known as *Intel Optane* persistent memory DIMM modules go to the *System BIOS Settings* boot menus.
  Select the menu::

    Memory Settings > Persistent Memory > Intel Persistent Memory > Persistent Memory DIMM Configuration

* Memory mode configuration for persistent memory:

  - To create an NVDIMM_ goal in BIOS, go to the sub-menu ``Create Goal Config``.
  - The BIOS options determine how the goal is created and the PMems are configured::

      Operation Target: Platform - Applies the goal to all the DIMMs in the system (recommended)
      Persistent [%]: 100 - Creates a goal of 100% Persistent memory across the selected PMems

Configure persistent memory namespaces
---------------------------------------------

Install this package::

  dnf install ndctl

and list all physical devices::

  ndctl list -DHi

The configuration of namespaces will decide how much memory capacity to expose to the OS.
Create a namespace on each of the persistent memory modules::

  ndctl create-namespace

See the manual for ndctl-create-namespace_.
List namespaces::

  ndctl list -N

To correlate a namespace to a PMem device, use the ``lsblk`` command.

.. _NVDIMM: https://en.wikipedia.org/wiki/NVDIMM
.. _NVDIMM_Wiki: https://nvdimm.wiki.kernel.org/
.. _3D_XPoint: https://en.wikipedia.org/wiki/3D_XPoint
.. _Optane_EOL: https://www.intel.com/content/www/us/en/support/articles/000057951/memory-and-storage/intel-optane-memory.html
.. _ndctl-create-namespace: https://docs.pmem.io/ndctl-user-guide/ndctl-man-pages/ndctl-create-namespace

Managing NVDIMMs with ipmctl
---------------------------------

The ipmctl_ is a utility for configuring and managing Intel® Optane™ Persistent Memory modules (PMem).
On EL8 systems install this package from EPEL_::

  dnf install ipmctl

Read the ipmctl_ manual page.
For example, display the NVDIMM_ in the system::

  $ ipmctl show -dimm
   DimmID | Capacity    | LockState        | HealthState | FWVersion    
  ======================================================================
   0x0001 | 126.742 GiB | Disabled, Frozen | Healthy     | 02.02.00.1553
   0x1001 | 126.742 GiB | Disabled, Frozen | Healthy     | 02.02.00.1553

Other useful commands::

  $ ipmctl help
  $ ipmctl show -topology -socket

.. _ipmctl: https://github.com/intel/ipmctl
.. _EPEL: https://docs.fedoraproject.org/en-US/epel/

PXE boot setup
==============

Go to the *System Setup* menu item *Device Settings* and select the *Integrated NIC* items:

* In the NIC *Main Configuration Page* select *NIC Configuration*.  We use **NIC port 3** (1 Gbit) as the system's NIC.

* Read the NIC **Ethernet MAC Address** from this page for configuring the DHCP server.

* Select the **Legacy Boot Protocol** item **PXE**.

* Set **Wake On LAN** to **Enabled**.

* Set the **Boot Retry Count = 3** if desired.

* Disable PXE boot for all unused NICs (port 1).

Press *Finish* to save all settings.

It is possible to request a one-time PXE boot from the BMC using this IPMItool_ raw command::

  ipmitool -I lanplus -H <BMC-address> -U <username> -P <password> raw 0x00 0x08 0x05 0xa0 0x04 0x00 0x00 0x00

The FreeIPMI_ command ipmi-raw_ may also be used.

.. _IPMItool: https://github.com/ipmitool/ipmitool
.. _FreeIPMI: https://www.gnu.org/software/freeipmi/
.. _ipmi-raw: https://www.gnu.org/software/freeipmi/manpages/man8/ipmi-raw.8.html

iDRAC (BMC) setup
=================

The Dell iDRAC9_ (BMC) setup is accessed via the *System Setup* menu item *iDRAC Settings*:

* In the *System Summary* page read the NIC **iDRAC MAC Address** from this page for configuring the DHCP server.

* In the *Network* page set the **Enable IPMI over LAN** to **Enabled**.

* In the *User Configuration* page set the *User 2* (**root**) Administrator user name and change the **password**.
  The Dell iDRAC_ **default password** for *root* is **calvin** and you will be asked to change this at the first login.

  **IMPORTANT:** The iDRAC9_ keyboard layout is **US English**!  Do not use characters that differ from the US layout!

* Optional: In the *Thermal* page set Thermal: **Maximum Performance**.

Press *Finish* to save all settings.

.. _iDRAC9: https://www.dell.com/support/article/us/en/04/sln311300/idrac9-home?lang=en

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

If DHCP is enabled on iDRAC and you want to use the DNS server IP provided by the DHCP server::

  racadm set iDRAC.IPv4.DNSFromDHCP 1
  racadm set iDRAC.NIC.DNSDomainFromDHCP 1
  racadm set iDRAC.NIC.DNSDomainNameFromDHCP 1

The iDRAC DNS Name **cannot be obtained from DHCP!**
Therefore you must always set the DNS name manually::

    racadm set iDRAC.NIC.DNSRacName <iDRACNAME>

Manual DNS settings:

* Set iDRAC domain name::

    racadm set iDRAC.NIC.DNSDomainName <DOMAIN.NAME>

* Set iDRAC DNS Server::

    racadm config -g cfgLanNetworking -o cfgDNSServer1 x.x.x.x
    racadm config -g cfgLanNetworking -o cfgDNSServer2 y.y.y.y

* Set the server's DNS hostname by::

    racadm  set System.ServerOS.HostName <Server-DNS-name>

iDRAC web-server security Host Header enforcement
-------------------------------------------------

Starting with **iDRAC firmware 5.10**, by default, iDRAC9 will check the HTTP / HTTPS Host Header and compare to the *DNSRacName* and *DNSDomainName* iDRAC parameters.
When the values do not match, the iDRAC will refuse the HTTP / HTTPS connection. 
This is a security issue recorded in `CVE-2021-21510 <https://nvd.nist.gov/vuln/detail/CVE-2021-21510>`_ with the description::

  Dell iDRAC8 versions prior to 2.75.100.75 contain a host header injection vulnerability. A remote unauthenticated attacker may potentially exploit this vulnerability by injecting arbitrary ‘Host’ header values to poison a web-cache or trigger redirections

This means that you **cannot** use the iDRAC's DNS name to access its web-server!
However, you can still connect to the IP-address in stead of the DNS name.

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

First you must configure the DNS name of the iDRAC, see https://www.dell.com/support/article/us/en/04/sln309388/dell-idrac-how-to-configure-the-email-notifications-for-system-alerts-on-idrac-7-8-and-9?lang=en

In the iDRAC web GUI go to *iDRAC Settings->Connectivity->Common Settings* and configure the DNS domain name and hostname.

Then configure alerts in *Configuration->System Settings->Alert Configuration->Alerts*.
Then go to the *SMTP (Email) Configuration* sub-menu and set up SMTP alerts.

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

We have seen the R640 LCC going into a **Recovery Mode** preventing the setting of BIOS parameters using racadm_, and an error message on the console::

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
• UEFI Diagnostics application
• System configuration settings—BIOS, iDRAC, and NIC

Easy Restore uses the Easy Restore flash memory to back up the data. When you replace the motherboard and power on the system, the
BIOS queries the iDRAC and prompts you to restore the backed-up data. The first BIOS screen prompts you to restore the Service Tag,
licenses, and UEFI diagnostic application. The second BIOS screen prompts you to restore system configuration settings. If you choose not
to restore data on the first BIOS screen and if you do not set the Service Tag by another method, the first BIOS screen is displayed again.
The second BIOS screen is displayed only once.

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
