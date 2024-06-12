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

XClarity Essentials OneCLI
==============================

Lenovo XClarity Essentials OneCLI_ is a collection of command line applications that facilitate
Lenovo server management by providing functions, such as system configuration, system inventory,
firmware and device driver updates.

Download the ``lnvgy_utl_lxcer_onecli01z-4.2.0_linux_x86-64`` RPM file from the download page and install it.
This will create a soft-link ``/usr/bin/onecli`` to the OneCLI_ command.
There is a OneCLI_User_Guide_.

Some useful OneCLI_ commands are::

  onecli config show
  onecli config show system_prod_data

Saving and replicating the system configuration::

  onecli config save --file <savetofilename> [--group <groupname>] [--excbackupctl] [<options>] # Save the current settings
  onecli config replicate --file <filename> [<options>] # Replicate the settings to ANOTHER system

Use the ``onecli config restore`` command **only** to restore previous settings on the **same** server.
If you made a ``onecli config save`` file, make sure to delete the line with ``IMM.IMMInfo_Name`` from that file because it 
will be overwritten by the *replicate* command.
In the ``onecli config replicate`` log file you should identify all **VPD setting** parameters and delete those from the file, for example::

  Some settings are failed to set with some reason. The settings and reasons are as following:
  SYSTEM_PROD_DATA.SysInfoSerialNum
        Reason:SYSTEM_PROD_DATA.SysInfoSerialNum is skipped since this is VPD setting

The ``noreplicate`` parameters may be printed by the command::

  onecli config show noreplicate

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

Upload system logs to Lenovo
------------------------------

The OneCLI_ can upload system logs to Lenovo using the getinfor_ command::

  onecli inventory getinfor --ffdc --upload lenovo

The ``--upload`` command is described as:

* If specified with lenovo, the format is: --upload lenovo. The inventory data is uploaded to Lenovo Upload Facility. Users should specify the case number, or specify both machine type and serial number.

.. _getinfor: https://pubs.lenovo.com/lxce-onecli/onecli_r_getinfor_command

Firmware updates
-----------------

Updating a single firmware file on a single server can be performed with OneCLI_, but the no working examples have been found in the OneCLI_User_Guide_.
We have tested this procedure:

1. Unpack the firmware payload zip file in a dedicated directory (example `XCC` firmware file `lnvgy_fw_xcc_qgx330d-5.10_anyos_comp.zip`)::

     mkdir XCC
     cd XCC
     unzip <somewhere>/lnvgy_fw_xcc_qgx330d-5.10_anyos_comp.zip

   A subdirectory ``payload`` will contain the firmware file.
   Change the `XCC` directory name for other firmwares such as `UEFI`.

2. Execute this command::

     onecli update flash --scope individual --dir <somewhere>/XCC --nocompare --includeid lnvgy_fw_xcc_qgx330d-5.10_anyos_comp --output /tmp

Note that the firmware file extension must be omitted,
and that output logs will be written to `/tmp` (useful if the `XCC` directory is on a remote file server)..

Special notes:

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

