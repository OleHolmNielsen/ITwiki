.. _Dell_R650:

================
Dell R650 server
================

.. Contents::

This page contains information out Dell PowerEdge R650_ could servers which we have deployed in our cluster.

.. _R650: https://www.dell.com/en-us/work/shop/povw/poweredge-r650

Documentation and software
==========================

Dell Support_ provides R650_ information:

* R650_manuals_.
* R650_downloads_.
* iDRAC9_manuals_.
* Dell blog: `Intel Ice Lake - BIOS Characterization for HPC <https://infohub.delltechnologies.com/p/intel-ice-lake-bios-characterization-for-hpc/>`_.

.. _R650_manuals: https://www.dell.com/support/home/us/en/04/product-support/product/poweredge-r650/manuals
.. _R650_downloads: https://www.dell.com/support/home/us/en/04/product-support/product/poweredge-r650/drivers
.. _Support: https://www.dell.com/support/home/us/en/04/product-support/product/poweredge-r650/research
.. _iDRAC: https://en.wikipedia.org/wiki/Dell_DRAC
.. _iDRAC9_manuals: https://www.dell.com/support/home/us/en/19/products/software_int/software_ent_systems_mgmt/remote_ent_sys_mgmt/rmte_ent_sys_idrac9

Booting and BIOS configuration
==============================

Press **F2** during start-up to enter the BIOS and firmware setup menus.
Go to the *BIOS Settings* menu.

Minimal configuration of a new server or motherboard
----------------------------------------------------

At our site the following minimal settings are required for a new server or a new motherboard.  
Remaining settings will be configured by ``racadm``.

The Dell iDRAC9_ (BMC) setup is accessed via the *System Setup* menu item *iDRAC Settings*:

* In the *System Summary* page read the NIC **iDRAC MAC Address** from this page for configuring the DHCP server.

* In the *Network* page set the **Enable IPMI over LAN** to **Enabled**.

Go to the *System Setup* menu item *Device Settings* and select the *Integrated NIC* items:

* In the NIC *Main Configuration Page* select *NIC Configuration*.  We use **NIC port 3** (1 Gbit) as the system's NIC.

* Read the NIC **Ethernet MAC Address** from this page for configuring the DHCP server.

* Select the **Legacy Boot Protocol** item **PXE**.

Boot settings menu
------------------

* The **Boot Mode** may be either **BIOS** or **UEFI**.

* In the *Boot Sequence* menu:

  * Click the **Boot Sequence** item to move PXE boot up above the hard disk boot (if desired).

  * Verify that the correct devices are selected in *Boot Option Enable/Disable*.

If UEFI boot mode is selected, the following must be enabled before installing the OS for the first time:

* In the **Boot Setting** menu:

  * **Hard-disk Drive Placeholder = Enabled**

Performance settings for HPC
----------------------------

The following BIOS settings should be made on HPC nodes::

  [Key=BIOS.Setup.1-1#SysProfileSettings]
  SysProfile=PerfOptimized
  [Key=BIOS.Setup.1-1#SysProfileSettings]
  WorkloadProfile=HpcProfile
  [Key=BIOS.Setup.1-1#DellControlledTurbo]
  ControlledTurbo=Disabled
  [Key=BIOS.Setup.1-1#IntegratedDevices]
  SnoopHldOff=Roll2KCycles

The CLI commands are::

  racadm set BIOS.SysProfileSettings.SysProfile PerfOptimized
  racadm set BIOS.SysProfileSettings.WorkloadProfile HpcProfile
  racadm set BIOS.DellControlledTurbo.ControlledTurbo Disabled
  racadm set BIOS.IntegratedDevices.SnoopHldOff Roll2KCycles
  racadm jobqueue create BIOS.Setup.1-1

and then reboot the server.

The *SnoopHldOff* value (should be 2K since the default value 256 is too small) is important for high performance Omni-Path or Infiniband network fabrics.

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


Processor settings menu
-----------------------

You may want to verify the following BIOS settings on HPC nodes:

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

System Security menu
--------------------

* **AC Power Recovery** = **Last** state.

Miscellaneous Settings menu
---------------------------

* **Keyboard NumLock** = **Off**.

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
