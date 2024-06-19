.. _Dell_ME484:

=======================
Dell ME484 JBOD storage
=======================

.. Contents::

The Dell EMC PowerVault ME484_ JBOD storage contains up to 84 3.5" SAS disks of up to 18 TB each.

ME484 support
=============

* ME484_support_ page including documentation, software and firmware.

* The `ME484 Support Matrix <https://dl.dell.com/topicspdf/powervault-me484-expansion_support-matrix3_en-us.pdf>`_ paper lists the server HBA_ that have been tested for use with ME484 JBOD storage enclosures:

  - Dell HBA355e for PowerEdge 15th generation servers
  - Dell 12 Gbps SAS HBA for PowerEdge 13th, 14th, and 15th generation servers

  Please note that Dell PERC_ RAID controllers are **not supported**, and the SHM_ tools **do not work** when the ME484_ is attached to a PERC_ controller.

* The iDRAC_ controller does show the ME484_ under the *Storage* page, even when it is attached to a PERC_ controller.

  However, the status of the ME484_ is often outdated, especially  regarding failed/rebuilding disks and system firmwares.
  A reboot of the iDRAC_ controller may sometimes update the information.

.. _ME484: https://www.delltechnologies.com/da-dk/storage/powervaultme4.htm
.. _ME484_support: https://www.dell.com/support/home/en-us/product-support/product/powervault-me484-expansion/overview
.. _PERC: https://en.wikipedia.org/wiki/Dell_PERC
.. _SHM: https://www.dell.com/support/home/en-us/product-support/product/software-tools/drivers
.. _iDRAC: https://en.wikipedia.org/wiki/Dell_DRAC
.. _HBA: https://en.wikipedia.org/wiki/Host_adapter

Server Hardware Manager (SHM)
=============================

See the SHM_ `Dell EMC Storage PowerTools Server Hardware Manager Release 3.0 Administrator’s Guide  <https://dl.dell.com/topicspdf/powertools-shm-ag_en-us.pdf>`_.
This software works only with HBA_ adapters, not PERC_ adapters.

perccli tools
=============

The perccli_ tools may be used to inquire the status of ME484_ systems when connected to a PERC_ controller.

.. _perccli: https://www.dell.com/support/home/en-us/drivers/driversdetails?driverid=j91yg

This page describes how to download, install and use the Dell EMC PowerEdge RAID Controller (PERC) Command Line Interface (CLI) utility to manage your RAID controller on Dell EMC systems:

* https://www.dell.com/support/kbdoc/en-us/000177280/how-to-use-the-poweredge-raid-controller-perc-command-line-interface-cli-utility-to-manage-your-raid-controller

List all command options::

  perccli -h

List PERC_ controllers in the system::

  perccli show

List storage enclosures on controller #1::

  perccli /c1 /eall show all

Show disk slots::

  perccli /c1 /eall /sall show

Show disk rebuild status::

  perccli /c1 /eall /sall show rebuild

Show detailed disk information including *Firmware Revision* (here for slot 75)::

  perccli /c1 /eall /s75 show all

ME484 firmware updates
======================

The latest ME484_ firmware as of February 2024 is `52CC, A08 <https://www.dell.com/support/home/en-us/drivers/driversdetails?driverid=tmvgc&oscode=wst14&productcode=powervault-me484-expansion>`_.

PERC controller notes
---------------------

**WARNING:** ME484_ firmware **cannot be updated** when attached to a PERC_ controller!

When connected to a PERC_ controller, the ME484 current firmware is displayed by (for controller #1)::

  perccli /c1 /eall show all

for example as::

  Vendor Identification = DellEMC
  Product Identification = Array584EMM
  Product Revision Level = 52CC

Using an HBA for firmware updates
---------------------------------

In stead of using PERC_, it is mandatory to attach the ME484_ to one of the HBA_ adapters listed above in the support matrix,
and the SHM_ tools only works with HBA_ adapters (probably due to ME484 being based on LSI MegaRAID_ technology).

We have found that storage data are **preserved** with this procedure:

* Shut down the server with ME484_ attached to a PERC_ controller.
* Disconnect the ME484_ SAS cables from the controller.
* Connect ME484_ SAS cables to a second server with an HBA_ controller.
* Power up the second server.
* Perform ME484_ firmware updates using SHM_ tools.
* Shut down the second server.
* Reattach ME484_ to the server with PERC_ controller and power it up again.

**IMPORTANT:** Do not disconnect ME484_ SAS cables from controllers without powering down the server first.
A PERC_ controller will fail the *Virtual Disks* in the ME484_ if disconnected while power is on!

.. _MegaRAID: https://www.broadcom.com/products/storage/raid-controllers

Using SHM to update firmware
----------------------------

When the ME484_ is attached to a supported HBA_ controller, the firmware package (for example, ``52CC.zip``) contains detailed installation instructions in the ``README.txt`` file.

As stated in the SHM_ manual section *Updating EMM firmware*::

  Stop all I/O between the server and the attached enclosures containing the EMMs you intend to update.
  NOTE:
  ● After this update process begins, you may lose access to the drives or enclosures connected to the update target.
  The EMM does not respond to commands again until it is back online.
  ● If you have more than one storage enclosure in a daisy-chain, Dell EMC recommends that you update the EMMs
  starting in the lowest tier of the chain and work back, up to the top enclosure.

First list adapters, enclosures and the 2 EMM modules per enclosure::

  shmcli list adapters
  shmcli list physical enclosures 
  shmcli list emms -a=0 

The EMM firmware is listed under the *Rev* column (for example, 52CC).
The ME484_ *ServiceTag* is listed under the *Enclosure* column.

The sequence of operations are to update **right and left sideplanes** and finally **both** EMMs 0 and 1::

  shmcli update emm -a=0 -enc=500c0ff0f169263c -emm=0 -file=right_sideplane_combined_r2019.20.10.gff
  shmcli update emm -a=0 -enc=500c0ff0f169263c -emm=0 -file=left_sideplane_combined_r2019.20.10.gff
  shmcli update emm -a=0 -enc=500c0ff0f169263c -emm=0 -file=emm_canister_local_combined_non_disruptive_r2019.20.10.gff
  shmcli update emm -a=0 -enc=500c0ff0f169263c -emm=1 -file=emm_canister_local_combined_non_disruptive_r2019.20.10.gff 

The correct enclosure WWN must be used (in the example it is WWN=500c0ff0f169263c).
The firmware file names depend on the release version.
