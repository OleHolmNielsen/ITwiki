.. _Lenovo_XClarity_BMC:

==========================
Lenovo XClarity (XCC) BMC
==========================

.. Contents::

This page contains information about Lenovo servers' XClarity_ Controller (XCC) BMC.
Most Lenovo ThinkSystem servers contain an integrated service processor, XClarity Controller (XCC),
which provides advanced service-processor control, monitoring, and alerting functions. 

.. _XClarity: https://lenovopress.lenovo.com/lp0880-xcc-support-on-thinksystem-servers

Documentation and software
==========================

* `Lenovo XClarity Administrator Product Guide <https://lenovopress.lenovo.com/tips1200-lenovo-xclarity-administrator>`_.
* Lenovo XClarity Essentials OneCLI_ and OneCLI_User_Guide_.
* `Lenovo XClarity Provisioning Manager <https://sysmgt.lenovofiles.com/help/index.jsp?topic=%2Flxpm_frontend%2Flxpm_product_page.html&cp=7>`_.

.. _OneCLI: https://support.lenovo.com/us/en/solutions/ht116433-lenovo-xclarity-essentials-onecli-onecli
.. _OneCLI_User_Guide: https://pubs.lenovo.com/lxce-onecli/onecli_bk.pdf

Lenovo XClarity Essentials Bootable Media Creator (BoMC)
===========================================================

You can use Lenovo XClarity Essentials *Bootable Media Creator* (BoMC_) to create bootable media suitable for
firmware updates, VPD updates, inventory and FFDC collection, advanced system configuration, FoD Keys management, secure erase, RAID configuration, and diagnostics.

Download the utility from the BoMC_ page, and run the Linux executable ``lnvgy_utl_lxce_bomc01t-14.2.0_linux_indiv`` (a GUI tool) as the root user.

The BoMC_ bootable media may be installed on a USB disk, a DVD, or via PXE booting.
Press F12 during boot to select the boot media.

There is a `Lenovo Bootable Media Creator Installation and User Guide <https://pubs.lenovo.com/lxce-bomc/bomc_bk.pdf>`_.

Collecting BoMC log file
------------------------

New log information is appended to the ``bomc103.log`` file in the ``/var/log/Lenovo_Support/`` folder.

If some operations failed while executing the BoMC_ image, for example,
failed to update the firmware while booting the BoMC_-created ISO image on a server,
do the following:

1. Click ``Save Logs`` in the last page.
2. Save the logs in the storage device or the SFTP server.

.. _BoMC: https://support.lenovo.com/us/en/solutions/ht115048-lenovo-xclarity-essentials-bootable-media-creator

Service log for Lenovo hardware support
===========================================

Gather ``Service Log`` files for Lenovo hardware support under the XCC GUI page under *Quick Actions* menu.
Press the *Export* button and the file will be stored in your ``$HOME/Downloads/`` directory.

Then upload the file to the `Lenovo Upload page <https://logupload.lenovo.com/>`_.
You must enter the case number (3000xxxx).

**Note:** Browsers on Linux (Firefox, Chrome) may refuse this web page with a
`Secure Connection Failed error page <https://support.mozilla.org/en-US/kb/secure-connection-failed-firefox-did-not-connect>`_.
We currently do not have a workaround for this issue.

Lenovo has a `Repair status <https://support.lenovo.com/us/en/repairstatus>`_ page.

Collecting inventory and service data on Linux
===================================================

This `page <https://pubs.lenovo.com/lxce-onecli/collect_inventory_and_service_data_linux>`_ 
explains how to collect inventory and service data on Linux
using the ``lnvgy_utl_lxceb_oneclixxx-xxx.bin`` tool.

XCC licenses
================

License keys for the XCC can be accessed in the product page's *Reference Information* pane item
`Feature On Demand Key <https://fod2.lenovo.com/lkms>`_.
There is *FoD* documentation in the `Using the FoD web site <https://pubs.lenovo.com/lenovo_fod/usingfod>`_.
First you must register a login account on the *FoD* homepage.

In the *FoD* dashboard you can click on the *Retrieve history* menu and select search type *Search history via machine type serial number*.
For the *Search value* you enter the 4-character *Machine type* followed by the server's serial number.
The license key file can be downloaded or E-mailed.

The license key can be installed in the XCC web-page's ``BMC License`` item or the menu 
*BMC Configuration->License* page.

.. _XClarity_Essentials_OneCLI:

XClarity Essentials OneCLI
==============================

Lenovo XClarity Essentials OneCLI_ is a collection of command line applications that facilitate
Lenovo server management by providing functions, such as system configuration, system inventory,
firmware and device driver updates.

Download the ``lnvgy_utl_lxcer_onecli02d-5.3.0_linux_indiv`` RPM file from the OneCLI_ page and install it.
This will create a soft-link ``/usr/bin/onecli`` to the OneCLI_ command.
There is a OneCLI_User_Guide_ and you may read the online help::

  onecli help

The OneCLI_ can be used Out-of-band_ from a management server with arguments for example::

  onecli <some command> -N --bmc $IPMI_USER:$IPMI_PASSWORD@<XCC-address>

where the IPMI_ login is defined by the variables ``$IPMI_USER:$IPMI_PASSWORD``.

For example, you can use OneCLI_ to configure some desirable XCC networking parameters::

  onecli config set IMM.IMMInfo_Name `hostname -s`
  onecli config set IMM.HostName1 `hostname -s`b
  onecli config set IMM.MinPasswordLen 8
  onecli config set IMM.DDNS_Enable Disabled

Other useful OneCLI_ commands are::

  onecli config show
  onecli config show system_prod_data
  onecli config show BMC --redfish      # Shows BMC.FailsafePowerLimit_* and other parameters

Power management can be done locally or Out-of-band_, see the options::

  onecli ospower help

A node Virtual_Reseat_ power cycling can be done (Out-of-band_ is recommended :-) with::

  onecli ospower acpower

Some system health commands::

  onecli misc syshealth
  onecli misc syshealth --device system
  onecli misc syshealth --device processor
  onecli misc syshealth --device dimm
  onecli misc syshealth --device power

Show system configuration parameters, for example::

  onecli config show BootOrder.BootOrder

Show/set BMC hostname::

  onecli config show IMM.HostName1
  onecli config set IMM.HostName1 <BMC-hostname>

Show/set the system's friendly name (unrelated to DNS names)::

  onecli config show IMM.IMMInfo_Name 
  onecli config set IMM.IMMInfo_Name <system-name>

Enable promoting the primary BMC firmware to the backup firmware::

  onecli config set IMM.BackupAutoPromote Enabled

.. _Out-of-band: https://en.wikipedia.org/wiki/Out-of-band_management
.. _Virtual_Reseat: https://pubs.lenovo.com/mgt_tools_smm2/c_chassis_front_overview
.. _IPMI: https://en.wikipedia.org/wiki/Intelligent_Platform_Management_Interface

Replicating UEFI configuration parameters
------------------------------------------

Saving the system configuration to a file::

  onecli config save --file <savetofilename> [--group <groupname>] [--excbackupctl] [<options>] # Save the current settings

Replicating the system configuration from a file::

  onecli config replicate --file <filename> [<options>] # Replicate the settings to ANOTHER system

Optional: The ``noreplicate`` parameters may be printed by the command::

  onecli config show noreplicate

**Important**:

* Use the ``onecli config restore`` command **only** to restore previous settings on the **same** server.

Edit the XCC system configuration file
.......................................

If you created a ``onecli config save`` file, make sure to delete a number of lines
that are unique to each server and must not be replicated:

* Delete the lines with ``IMM.IMMInfo_*``, for example::

    IMM.IMMInfo_Name=xxxx
    IMM.IMMInfo_Contact=
    ...

* Delete the lines with ``IMM*`` networking information, for example::

    IMM.HostName1=xxxx
    IMM.HostIPAddress1=172.29.101.1
    IMM.HostIPSubnet1=255.255.0.0
    IMM.GatewayIPAddress1=0.0.0.0
    IMM.SNMPv3EngineId=XCC-xxx-xxxx

* Delete the ``SYSTEM_PROD_DATA`` lines, for example::

    SYSTEM_PROD_DATA.SysInfoProdName=xxx
    SYSTEM_PROD_DATA.SysInfoProdIdentifier=xxx
    SYSTEM_PROD_DATA.SysInfoSerialNum=xxx
    SYSTEM_PROD_DATA.SysInfoUUID=xxx
    SYSTEM_PROD_DATA.SysEncloseAssetTag=

* Delete the boot order device lines containing specific hard disk and network identifiers::

    BootOrder.HardDiskBootOrder=UEFI xxx
    BootOrder.NetworkBootOrder=UEFI xxx

Upload system logs to Lenovo
------------------------------

The OneCLI_ can upload system logs to Lenovo using the getinfor_ command::

  onecli inventory getinfor --ffdc --upload lenovo

The ``--upload`` command is described as:

* If specified with lenovo, the format is: --upload lenovo. The inventory data is uploaded to Lenovo Upload Facility. Users should specify the case number, or specify both machine type and serial number.

.. _getinfor: https://pubs.lenovo.com/lxce-onecli/onecli_r_getinfor_command

Firmware updates
-----------------

The server's firmware versions can be displayed by::

  onecli update scan -N --bmc $IPMI_USER:$IPMI_PASSWORD@<XCC-address>

This command must be executed Out-of-band_ because OneCLI_ refuses to work locally on non-supported OSes (bug discovered August 2024).

Updating a single firmware file on a single server can be performed with OneCLI_, but no working examples have been found in the OneCLI_User_Guide_.
However, we have tested these procedures successfully:

V3/V4 server firmware updates
..............................

In case the firmware is delivered from Data_Center_Support_ as a ZIP_ archive (for V3 and V4servers):

1. Unpack the firmware payload ZIP_ file in a dedicated directory (example `XCC` firmware file `lnvgy_fw_xcc_qgx330d-5.10_anyos_comp.zip`)::

     mkdir XCC
     cd XCC
     unzip <somewhere>/lnvgy_fw_xcc_qgx330d-5.10_anyos_comp.zip

   A subdirectory ``payload`` will now contain the firmware payload file.
   Note: Change the ``XCC`` directory name for other firmwares such as `UEFI`.

2. Execute this command (example filename only)::

     onecli update flash --scope individual --dir <somewhere>/XCC --nocompare --includeid lnvgy_fw_xcc_qgx330d-5.10_anyos_comp --output /tmp

V2 server firmware updates
..............................

In case the firmware is delivered only as a Lenovo-special compressed ``.uxz`` file (for V2 servers):

1. Download **both** the firmware payload ``.uxz`` file as well as the accompanying ``.xml`` file from Data_Center_Support_.

2. Copy the firmware payload ``.uxz`` and the ``.xml`` file to a dedicated directory, for example::

     mkdir XCC
     cd XCC

   Note: Change the ``XCC`` directory name for other firmwares such as `UEFI`.

3. Execute this command (example filename only)::

     onecli update flash --scope individual --dir <somewhere>/XCC --nocompare --includeid lnvgy_fw_xcc_tgbt58d-6.10_anyos_noarch -- output /tmp

Firmware update notes
.............................

* The firmware file extension must be omitted.
* Output logs will be written to `/tmp` (useful if the `XCC` directory is on a remote file server)..

Special notes on booting the server:

* When the XCC (BMC) is updated it will be rebooted as part of the firmware update.

* When the UEFI is updated, the server must be rebooted manually.

* When updating the `NVIDIA/Mellanox` network adapters, the firmware update bundle contains separate firmware files for different adapter families.
  These must be used with the above procedure:

  - NVIDIA ConnectX-6 Lx 10/25GbE LOM Ethernet ``fam010``.
  - Nvidia ConnectX-7 NDR200/HDR QSFP112 2-port PCIe Gen5 x16 InfiniBand Adapter (SharedIO) DWC: ``fam016``.
    Notice that the server power must be hard cycled for the firmware update to be effective!
    In the DW612S chassis the nodes can be power cycled by a ``Reseat`` operation in the SMM2 web GUI,
    and it may take 5 minutes before the node can be powered on again.

See also:

* `How to use Lenovo XClarity Essentials OneCLI to locally update your system <https://support.lenovo.com/us/en/solutions/ht511326-how-to-use-lenovo-xclarity-essentials-onecli-to-locally-update-your-system>`_.
* *Lenovo XClarity Administrator Quick Start Guide* `Updating firmware and software <https://sysmgt.lenovofiles.com/help/topic/com.lenovo.lxca.doc/lxca_qsg_update_sw_fw.pdf>`_.

.. _ZIP: https://en.wikipedia.org/wiki/ZIP_(file_format)
.. _Data_Center_Support: https://datacentersupport.lenovo.com/us/en

XCC CLI access using SSH
==========================

One may have XCC CLI access using SSH, however, it's necessary to specify *which* of your multiple SSH keys to use::

  ssh -i $HOME/.ssh/id_rsa.pub <node-xcc-name>

Once logged into the XCC CLI there are many options, use `help` to list options.

To display Vital Product Data::

  system> help vpd
  usage:
   vpd sys  - displays Vital Product Data for the system
   vpd bmc  - displays Vital Product Data for the management controller
   vpd uefi - displays Vital Product Data for system BIOS
   vpd lxpm - displays Vital Product Data for system LXPM
   vpd fw   - displays Vital Product Data for the system firmware
   vpd comp - displays Vital Product Data for the system components
   vpd pcie - displays Vital Product Data for PCIe devices

XCC Effortless Reset
========================

It is possible to reset the system to factory default settings with the XCC Effortless_Reset_ tool 
which is available in the *F1 Setup* console window.
You can select one or more resets from the list:

1. To erase the data on all RAID volumes and all disk devices (including HDD, SSD, and SED), select **Permanently erase all data on storage devices**.

2. To clear all system logs, including LSI RAID Event Log and System Event Log (SEL), select **Clear all system logs**.

3. To reset the credentials and networking of UEFI, BMC, TPM, and CMOS to factory default settings, select **Reset all system to factory default, including credentials and networking**.

.. _Effortless_Reset: https://pubs.lenovo.com/lxpm-v3/effortless_reset
