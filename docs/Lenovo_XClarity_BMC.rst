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

Saving and restoring system configuration::

  onecli config save --file <savetofilename> [--group <groupname>] [--excbackupctl] [<options>] # Save the current settings
  onecli config replicate --file <filename> [<options>] # Replicate the settings to ANOTHER system
  onecli config restore --file <filename> [<options>]   # Restore a saved setting value to the CURRENT system

System health commands::

  onecli misc syshealth
  onecli misc syshealth --device system
  onecli misc syshealth --device processor
  onecli misc syshealth --device dimm
  onecli misc syshealth --device power

Show system configuration parameters, for example::

  onecli config show BootOrder.BootOrder
