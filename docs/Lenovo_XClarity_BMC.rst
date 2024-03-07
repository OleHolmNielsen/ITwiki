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

Use the ``onecli config restore`` command to restore previous settings on the **same** server.

System health commands::

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

If you made a ``onecli config save`` file, make sure to delete the line with ``IMM.IMMInfo_Name`` from that file because it 
will be overwritten by the *replicate* command..

Upload system logs to Lenovo
------------------------------

The OneCLI_ can upload system logs to Lenovo using the getinfor_ command::

  onecli inventory getinfor --ffdc --upload lenovo

The ``--upload`` command is described as:

* If specified with lenovo, the format is: --upload lenovo. The inventory data is uploaded to Lenovo Upload Facility. Users should specify the case number, or specify both machine type and serial number.

.. _getinfor: https://pubs.lenovo.com/lxce-onecli/onecli_r_getinfor_command

Firmware updates
-----------------

Updating a single firmware file on a single server (omit last file extension)::

  onecli update flash --dir <firmware-directory> --scope individual --includeid <firmware-file-name> 
