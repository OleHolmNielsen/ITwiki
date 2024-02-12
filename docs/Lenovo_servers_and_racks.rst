
Lenovo servers and racks
========================

.. Contents::

This page contains information about Lenovo servers and racks deployed in our cluster:

* Lenovo_SD665-N_V3_ Neptune DWC Server.
* Lenovo_SR645_V3_ server.
* Lenovo_SR850_V3_ server.
* Lenovo_BIOS_settings_ common to servers.
* Lenovo_XClarity_BMC_ (XCC) controller.
* Lenovo_rack_ cabinets.
* Lenovo_PDU_ power distribution units.
* Lenovo_CDU_ direct water cooling distribution units.
* Lenovo_EveryScale_ framework for data center solutions.

.. _Lenovo_PDU: https://lenovopress.lenovo.com/lp1556-lenovo-1u-switched-monitored-3-phase-pdu
.. _Lenovo_EveryScale: https://lenovopress.lenovo.com/lp0900-lenovo-everyscale-lesi

Documentation and software
==========================

Lenovo documentation and downloads:

* `Lenovo XClarity Administrator Product Guide <https://lenovopress.lenovo.com/tips1200-lenovo-xclarity-administrator>`_.
* Lenovo XClarity Essentials OneCLI_ and OneCLI_User_Guide_.
* `Lenovo XClarity Provisioning Manager <https://sysmgt.lenovofiles.com/help/index.jsp?topic=%2Flxpm_frontend%2Flxpm_product_page.html&cp=7>`_.
* Firmware_updates_
  and `Best practices <https://lenovopress.lenovo.com/lp0656-lenovo-thinksystem-firmware-and-driver-update-best-practices>`_.
  The Firmware_download_ page.
* `Lenovo EveryScale (formerly Lenovo Scalable Infrastructure or LeSI) <https://lenovopress.lenovo.com/lp0900-lenovo-everyscale-lesi>`_ for HPC.

.. _OneCLI: https://support.lenovo.com/us/en/solutions/ht116433-lenovo-xclarity-essentials-onecli-onecli
.. _OneCLI_User_Guide: https://pubs.lenovo.com/lxce-onecli/onecli_bk.pdf
.. _Firmware_updates: https://pubs.lenovo.com/sr645/maintenance_manual_firmware_updates
.. _Firmware_download: https://datacentersupport.lenovo.com/us/en/products/servers/thinksystem/sr645v3/7d9c/downloads/driver-list/

Firmware upgrades
=================

In the BMC (XCC) GUI's ``Firmware Update`` window you may install update files.
Go to the Firmware_download_ page and type in the system serial number to search for updates.
Print the serial number by the command::

  dmidecode -s system-serial-number
