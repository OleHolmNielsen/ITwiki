.. _Dell_BIOS_settings:

========================================
Dell BIOS settings common to servers
========================================

.. Contents::

.. _BIOS: https://en.wikipedia.org/wiki/BIOS
.. _Function_key: https://en.wikipedia.org/wiki/Function_key
.. _OpenManage: https://www.dell.com/support/article/us/en/04/sln310664/dell-emc-openmanage-systems-management-portfolio-overview?lang=en
.. _Linux_Engineering: https://linux.dell.com/
.. _Linux_repository: https://linux.dell.com/repo/hardware/
.. _iDRAC: https://en.wikipedia.org/wiki/Dell_DRAC
.. _iDRAC9_manuals: https://www.dell.com/support/home/us/en/19/products/software_int/software_ent_systems_mgmt/remote_ent_sys_mgmt/rmte_ent_sys_idrac9
.. _OpenManage_Ansible_Modules: https://github.com/dell/dellemc-openmanage-ansible-modules

Booting and BIOS configuration
==============================

Press the **F2** Function_key_ during start-up to enter system setup menus.

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

  * Click the **Boot Sequence** item to move PXE_ boot up above the hard disk boot.

.. _iDRAC: https://en.wikipedia.org/wiki/Dell_DRAC
.. _racadm: https://www.dell.com/support/manuals/us/en/04/idrac9-lifecycle-controller-v3.0-series/idrac_3.00.00.00_racadm/introduction
.. _PXE: https://en.wikipedia.org/wiki/Preboot_Execution_Environment

Boot settings menu
------------------

Press the **F2** Function_key_ during start-up to enter the BIOS_ and firmware setup menus.
Go to the *BIOS Settings* menu.

* **Boot Mode** = **UEFI**.

* In the *Boot Sequence* menu:

  * Click the **Boot Sequence** item to move PXE_ boot up above the hard disk boot (if desired).

  * Verify that the correct devices are selected in *Boot Option Enable/Disable*.

If UEFI_ boot mode is selected, the following must be enabled before installing the OS for the first time:

* In the **Boot Setting** menu:

  * **Hard-disk Drive Placeholder = Enabled**

UEFI Secure Boot configuration
------------------------------------

First set the system's *Boot Mode* to UEFI_, see above.

The UEFI_ Secure_Boot_ configuration can be set in the *System BIOS Settings* menu:

1. Click on the *System Security* item.

2. Set the *Secure Boot* item to *Enabled*.

3. Click on the *Finish* buttons to exit *System Setup*, and the system will restart in Secure_Boot_ mode.

.. _UEFI: https://en.wikipedia.org/wiki/UEFI
.. _Secure_Boot: https://en.wikipedia.org/wiki/UEFI#Secure_Boot
.. _Esc_key: https://en.wikipedia.org/wiki/Esc_key

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

In the BIOS_ setup screen, select **iDRAC->Thermal** and configure **Thermal profile = Maximum performance**.

Read the current settings::

  racadm get System.ThermalSettings

For HPC applications set the fans to high performance::

  racadm set System.ThermalSettings.ThermalProfile "Maximum Performance"
  racadm set System.ThermalSettings.MinimumFanSpeed 25

A ``MinimumFanSpeed`` value of **255** indicates the **Default** setting.
Values between 21 (the default) and 100 may be used, but high values consume lots of power and generate noise.
For HPC systems a ``MinimumFanSpeed`` of 40 to 50 may perhaps be useful.

To configure the default thermal settings::

  racadm set System.Thermalsettings.ThermalProfile "Default Thermal Profile Settings"
  racadm set System.ThermalSettings.MinimumFanSpeed 255

System Security menu
--------------------

* **AC Power Recovery** = **Last** state.

Miscellaneous Settings menu
---------------------------

* **Keyboard NumLock** = **Off**.

