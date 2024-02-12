#########################
Lenovo servers and racks
#########################

This page contains information about Lenovo servers and racks deployed in our cluster:

.. toctree::
   :maxdepth: 1

   Lenovo_SD665-N_V3
   Lenovo_SR645_V3
   Lenovo_SR850_V3
   Lenovo_BIOS_settings
   Lenovo_XClarity_BMC

External pages:

* Lenovo_rack_ cabinet solutions.
* Lenovo_PDU_ power distribution units.
* Lenovo_Neptune_ liquid cooling technology.
* Lenovo_EveryScale_ framework for data center solutions (formerly Lenovo Scalable Infrastructure or LeSI).

.. _Lenovo_rack: https://lenovopress.lenovo.com/lp1287-lenovo-rack-cabinet-reference#availability=Available
.. _Lenovo_PDU: https://lenovopress.lenovo.com/lp1556-lenovo-1u-switched-monitored-3-phase-pdu
.. _Lenovo_EveryScale: https://lenovopress.lenovo.com/lp0900-lenovo-everyscale-lesi
.. _Lenovo_Neptune: https://www.lenovo.com/us/en/servers-storage/neptune/

Firmware upgrades
=================

In the BMC (XCC) GUI's ``Firmware Update`` window you may install update files.
Go to the Firmware_download_ page and type in the system serial number to search for updates.
Print the serial number by the command::

  dmidecode -s system-serial-number

* Firmware_updates_
  and `Best practices <https://lenovopress.lenovo.com/lp0656-lenovo-thinksystem-firmware-and-driver-update-best-practices>`_.
  The Firmware_download_ page.

.. _Firmware_updates: https://pubs.lenovo.com/sr645/maintenance_manual_firmware_updates
.. _Firmware_download: https://datacentersupport.lenovo.com/us/en/products/servers/thinksystem/sr645v3/7d9c/downloads/driver-list/
