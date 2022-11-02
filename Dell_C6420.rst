.. _Dell_C6420:

=================
Dell C6420 server
=================

.. Contents::

This page contains information about Dell PowerEdge C6420_ servers deployed in our cluster.

.. _C6420: https://www.dell.com/en-us/work/shop/povw/poweredge-c6420

Documentation and software
==========================

Dell Support_ provides C6420_ information:

* C6420_manuals_.
* C6420_downloads_.
* iDRAC9_manuals_ and iDRAC9_User_Guide_.
* Dell OpenManage_.
* Dell Linux_Engineering_ site.
* C6400_ chassis support.
* Dell EMC OpenManage_Ansible_Modules_.

.. _C6420_manuals: https://www.dell.com/support/home/us/en/04/product-support/product/poweredge-c6420/manuals
.. _C6420_downloads: https://www.dell.com/support/home/us/en/04/product-support/product/poweredge-c6420/drivers
.. _Support: https://www.dell.com/support/home/us/en/04/product-support/product/poweredge-c6420/research
.. _C6400: https://www.dell.com/support/home/us/en/19/product-support/product/poweredge-c6400/research
.. _C6400_drivers: https://www.dell.com/support/home/dk/da/dkbsdt1/product-support/product/poweredge-c6400/drivers
.. _OpenManage: https://www.dell.com/support/article/us/en/04/sln310664/dell-emc-openmanage-systems-management-portfolio-overview?lang=en
.. _Linux_Engineering: https://linux.dell.com/
.. _iDRAC9_manuals: https://www.dell.com/support/home/us/en/19/products/software_int/software_ent_systems_mgmt/remote_ent_sys_mgmt/rmte_ent_sys_idrac9
.. _iDRAC9_User_Guide: https://www.dell.com/support/manuals/dk/da/dkdhs1/idrac9-lifecycle-controller-v3.30.30.30/idrac_3.30.30.30_ug
.. _OpenManage_Ansible_Modules: https://github.com/dell/dellemc-openmanage-ansible-modules

Dell OpenManage
===============

Download the OpenManage_ software ISO image from the C6420_downloads_ page in the *Systems Management* download category.

Booting and BIOS configuration
==============================

Press **F2** during start-up to enter the BIOS and firmware setup menus.

See `How to inspect and change BIOS configurations on a PowerEdge C-Series server with SetupBIOS tool <https://www.dell.com/support/article/us/en/04/sln266215/how-to-inspect-and-change-bios-configurations-on-a-poweredge-c-series-server-with-setupbios-tool?lang=en>`_.

Minimal configuration of a new server or motherboard
----------------------------------------------------

At our site the following minimal settings are required for a new server or a new motherboard.  
Remaining settings will be configured by ``racadm`` (see the :ref:`Dell_R640` page).

The Dell iDRAC9_ (BMC) setup is accessed via the *System Setup* menu item *iDRAC Settings*:

* In the *Network* page set:

  * **NIC Selection**: **Dedicated**
  * **Enable IPMI over LAN** to **Enabled**.

* In the *System Summary* page read the NIC **iDRAC MAC Address** from this page for configuring the DHCP server.

Go to the *System Setup* menu item *Device Settings* and select the *Integrated NIC* items:

* In the NIC *Main Configuration Page* select *NIC Configuration*.  We use **NIC port 3** (1 Gbit) as the system's NIC.

* Read the NIC **Ethernet MAC Address** from this page for configuring the DHCP server.

* Select the **Legacy Boot Protocol** item **PXE**.

*Boot Sequence* menu:

  * Click the **Boot Sequence** item to move PXE boot up above the hard disk boot.

Reconfiguring the network in BIOS
---------------------------------

The C6420 **factory default** network settings has the iDRAC9_ port shared with a 1 Gbit LOM Ethernet port.

Our network configuration is designed to be:

1. A dedicated iDRAC9_ port.
2. Server Ethernet port in port 2 of 10 Gbit mezzanine card.
3. The server Ethernet port must do PXE boot before hard disk boot.
4. BIOS boot (not UEFI boot).

The following procedure has been tested with BIOS 1.6.11 and iDRAC9_ firmware 3.21:

1. During system boot press **F2** to go to **System Setup**.

2. Enter **iDRAC Settings**:

   * Network:

     - **NIC Selection**: **Dedicated**

   * Optional: Thermal:

     - **Thermal Profile**: **Maximum Performance**

3. Go back and enter **Device Settings**:

   * Read the Ethernet MAC address of the desired port.

   * Go to NIC in Mezzanine 3 Port 2:

     * NIC Configuration:
   
       * **Legacy Boot Protocol**: PXE

       * **Wake on LAN**: Enabled

4. Go back to **Finish**:

   * **Reboot the system** (mandatory).

5. During system boot press **F2** to go to **System Setup**.

6. Enter **System Setup**:

   * **Boot Settings**:

     * BIOS Boot Settings:

       * Change **Boot Sequence**: NIC, then Hard drive C:

7. Go back to **Finish**:

   * **Reboot the system** (mandatory).

.. _iDRAC9: https://www.dell.com/support/article/us/en/04/sln311300/idrac9-home?lang=en

C6400 Chassis System Management
===============================

Front control panel LED colors
------------------------------

The C6400 chassis front control panel LED colors are undocumented.
The page *Interpreting LED Colors and Blinking Patterns* for the PowerEdge_VRTX_ product may perhaps be useful, 
see the *Server* table::

  Green, glowing steadily	Turned on
  Green, blinking	Firmware is being uploaded
  Green, dark	Turned off
  Blue, glowing steadily	Normal
  Blue, blinking	User-enabled module identifier
  Amber, glowing steadily	Not used
  Amber, blinking	Fault
  Blue, dark	No fault


.. _PowerEdge_VRTX: https://www.dell.com/support/manuals/dk/da/dkbsdt1/dell-cmc-v2.0-vrtx/cmcvrtx_ug_2.0-v1/interpreting-led-colors-and-blinking-patterns?guid=guid-9b775c1b-8a38-43db-a7aa-835020072013&lang=en-us


DellEMC System Update
---------------------

The C6400_ chassis can be managed using the Dell EMC iDRAC_Tools_ for Linux.

DellEMC System Update (DSU_) is a script optimized update deployment tool for applying *Dell Update Packages* (DUP) to Dell EMC PowerEdge servers. 
See the DSU page https://www.dell.com/support/article/da-dk/sln310654/dell-emc-system-update-dsu?lang=en

Download the driver *DELL EMC System Update, v1.8.0*, filename::

  Systems-Management_Application_7PMM2_LN64_1.8.0_A00.BIN

and then execute it.

This will create the Yum repository file::

  /etc/yum.repos.d/dell-system-update.repo

Install RPM packages including iDRAC_tools_::

  yum install dell-system-update syscfg srvadmin-idracadm7 

racadm command
--------------

Make a soft link for the ``racadm`` command::

  ln -s /opt/dell/srvadmin/bin/idracadm7 /usr/local/bin/racadm

.. _iDRAC_Tools: https://www.dell.com/support/home/us/en/19/drivers/driversdetails?driverid=g3ndf&oscode=rhe70&productcode=poweredge-c6420
.. _DSU: http://linux.dell.com/repo/hardware/dsu/

Chassis information
-------------------

Get the chassis information::

  racadm get System.ChassisInfo

Get the chassis power information::

  racadm get System.SC-BMC

Inquire the system power::

  racadm get System.Power
  racadm get System.ServerPwr

Inquire thermal and fan settings::

  racadm get System.ThermalSettings

Inquire the Thermal Profile::

  racadm get System.ThermalSettings.ThermalProfile  

Values for the ThermalProfile parameter are::

  0- Default Thermal Profile Settings; 1- Maximum Performance; 2- Minimum Power; 3- Sound Cap; Default - 0


Use the *set* command to change the values.


C6400 firmware upgrade
----------------------

In the C6400_drivers_ page find *Chassis System Management* firmware.
Read the firmware *Release Notes* file.

Get the chassis information (including firmware)::

  racadm get System.ChassisInfo
  clush -bg xeon40 'racadm get System.ChassisInfo | grep FirmwareVersion'

You may also verify the CM chassis firmware version by::

  $ ipmitool raw 0x30 0x12
  01 e9 1b 02 28 01 00 00 00 01 02 00 01 2d 37 ff
  ff 08 c2 00 00 00 08 01 08 10 64 23 fa 01

Interpretation:

* Byte 4 - Major version (02 hex) - 02
* Byte 5 - Minor version (28 hex) - 40

Install firmware updates by::

  racadm update -f cm.sc

Note: It may take 5-10 minutes after upgrading before the new firmware is active on the chassis.

It is useful to loop over every 4th node using clush_.
For example, a list of every 4th c[001-196] node name between 1 and 196 may be generated by *seq*::

  seq -f 'c%03g' -s, 1 4 196

This can be used with clush_ as in this example::

  clush -bw `seq -f 'c%03g' -s, 1 4 196` 'racadm get System.ChassisInfo | grep FirmwareVersion'
  

C6400 Chassis Power Supplies
============================

The C6400_ chassis contains two power supplies of either 1600, 2000 or 2400 W.
The C6400_ factory default PSU configuration is::

  Dual, HotPlug Redundant Power Supply

The PSU handle LED codes are:

* Off: Input fail / System off
* Solid Green: Input OK / System on
* Blinking Amber: PSU failsafe failure
* Blinking Green: Firmware updating
* Blinking Amber: Firmware update failed
* Blinking Green and Off: PSU mismatch

Internal Dell information
-------------------------

The 1600 W PSU is special since it can be configured in 1+1 (default) redundancy mode, as well as a non-redundant 2+0 mode.

To set non-redundant 2+0 mode::

  ipmitool -I wmi 0x30 0xC7 0x30 0x2 0x0

Set back to 1+1 redundant mode::

  ipmitool -I wmi 0x30 0xC7 0x30 0x1 0x1

The C6400_ Chassis Manager must be reset to activate a new mode by::

  ipmitool -I wmi 0x6 0x34 0x45 0x70 0x18 0xc8 0x20 0x0 0x2 0xd8

Disk firmware upgrade without RAID controller
=============================================

Our C6420 servers have a SATA SSD disk connected to a simple S140 HBA controller.
The Linux firmware update xxx.BIN file apparently can only update firmwares on disks connected to a PERC RAID controller.

The alternative is to upgrade the disk firmware through the iDRAC9_ controller using the above **racadm** command together with 
the upgrade file in **Windows 32-bit .EXE** format.

For example::

  racadm update -f /home/que/Dell/C6420/Serial-ATA_Firmware_8VGP8_WN32_DL63_A00.EXE --reboot

**NOTE:** This upgrade **does not work** in a non-interactive crontab job.
You have to run the *racadm* command from an interactive shell, which also includes *ssh* and clush_ commands.

.. _clush: https://clustershell.readthedocs.io/en/latest/tools/clush.html

iDRAC Easy Restore
==================

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

Memory DIMM errors
==================

In the BMC and iDRAC event log there may be DIMM errors such as:

* Correctable memory error rate exceeded for DIMM_XX
* Warning - MEM0701- "Correctable memory error rate exceeded for DIMM_XX."
* Critical - MEM0702 - "Correctable memory error rate exceeded for DIMM_XX."

**NOTE: Do not swap** DIMM modules as the first action!

According to the internal Dell KB QNA44643, with BIOS 2.1.x and newer there is a memory "self healing" operation performed during reboot, 
see the QNA44643 `What is DDR4 Self-healing on Dell PowerEdge Servers with Intel Xeon Scalable Processors <https://www.dell.com/support/article/dk/da/dkbsdt1/qna44643/what-is-ddr4-self-healing-on-dell-poweredge-servers-with-intel-xeon-scalable-processors?lang=en.>`_.
See also the paper `Memory Errors and Dell EMC PowerEdge YX4X Server Memory RAS Features <https://downloads.dell.com/manuals/common/dellemc_poweredge_yx4x_memoryras.pdf>`_.

Memory retraining enhancements
------------------------------

Memory retraining which happens during boot, optimizes the signal timing/margining for each DIMM/slot for best access. Timing characteristics of a DIMM may change for several different reasons:

* Changes in Server memory configuration
* BIOS changes
* Different operating temperatures of the Server or DIMM
* General age of the DIMM

Post Package Repair (PPR)
-------------------------

Post Package Repair (PPR_) - The second "self-healing' memory enhancement,
results in repairing a failing memory location on a DIMM by disabling the
location/address at the hardware layer enabling a spare memory row to be used
instead. The exact number of spare memory rows available depends on the DRAM
device, and DIMM size.

Note: Message ID MEM8000 (**Correctable memory error logging disabled for a memory device at location DIMM_XX**) by itself, will not result in a PPR being scheduled for the next reboot. 
This message ID is expected to result in a PPR being scheduled for the next reboot starting with the **BIOS version AFTER 2.3.10** (February 2020).

After the reboot, verify that the PPR_ operation was successfully performed. An example of a successful PPR_ operation will be similar to:

* Message ID MEM9060 - "The Post-Package Repair operation is successfully completed on the Dual In-line memory Module (DIMM) device that was failing earlier."

A DIMM replacement for these correctable memory errors is not necessary unless the PPR_ operation failed after the reboot. An example of a failing PPR message is:

* Critical - Message ID UEFI10278 - "Unable to complete the Post Package Repair (PPR_) operation because of an issue in the DIMM memory slot X."

.. _PPR: https://patents.google.com/patent/WO2017030564A1/en
