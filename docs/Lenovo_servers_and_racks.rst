#########################
Lenovo servers and racks
#########################

This page contains information about Lenovo servers and racks deployed in our cluster:

.. toctree::
   :maxdepth: 1

   Lenovo_SD665_V3
   Lenovo_SD650-N_V2
   Lenovo_SR645_V3
   Lenovo_SR850_V3
   Lenovo_BIOS_settings
   Lenovo_XClarity_BMC
   Lenovo_DW612S

Lenovo product pages:

* Lenovo_rack_ cabinet solutions.
* Lenovo_PDU_ power distribution units.
  Vertiv `User Documentation for Lenovo <https://www.vertiv.com/en-us/support/avocent-support-lenovo/>`_.
* Lenovo_Neptune_ liquid cooling technology.
* Lenovo_EveryScale_ framework for data center solutions (formerly *Lenovo Scalable Infrastructure* or LeSI).

.. _Lenovo_rack: https://lenovopress.lenovo.com/lp1287-lenovo-rack-cabinet-reference#availability=Available
.. _Lenovo_PDU: https://lenovopress.lenovo.com/lp1556-lenovo-1u-switched-monitored-3-phase-pdu
.. _Lenovo_EveryScale: https://lenovopress.lenovo.com/lp0900-lenovo-everyscale-lesi
.. _Lenovo_Neptune: https://www.lenovo.com/us/en/servers-storage/neptune/

Server firmware upgrades
==========================

In the BMC (XCC) GUI's ``Firmware Update`` window you may install update files.

The system product and SKU name can be read from the BMC (XCC) GUI's Home page.
You can also print the system information by these Linux commands::

  dmidecode -s system-product-name
  dmidecode -s system-sku-number
  dmidecode -s system-serial-number
  dmidecode -s bios-version

Go to the Data_Center_Support_ page and click on the ``Servers`` tile and select your server model:

* Select series: ``ThinkSystem``.
* Select subseries and search for the ``system product name``.
* Select machine type as the 4 first letters of the ``SKU number``.

Alternatively, just type in the ``System serial number`` in the search bar.

* The Data_Center_Support_ page including download pages.
* Firmware `Best practices <https://lenovopress.lenovo.com/lp0656-lenovo-thinksystem-firmware-and-driver-update-best-practices>`_.

.. _Data_Center_Support: https://datacentersupport.lenovo.com/us/en
