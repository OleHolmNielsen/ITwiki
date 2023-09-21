.. _Lenovo_SR645_V3:

========================
Lenovo SR645 V3 server
========================

.. Contents::

This page contains information about Lenovo SR645_V3_ servers deployed in our cluster.
The Lenovo ThinkSystem SR645_V3_ is a 2-socket 1U server that features the AMD EPYC 9004 "Genoa" family of processors. 

.. _SR645_V3: https://lenovopress.lenovo.com/lp1607-thinksystem-sr645-v3-server

Documentation and software
==========================

Lenovo provides SR645_V3_ information:

* `ThinkSystem SR645 Setup Guide <https://pubs.lenovo.com/sr645/sr645_setup_guide.pdf>`_.
* software downloads.

Booting and BIOS configuration
==============================

Press **F2** during start-up to enter the BIOS and firmware setup menus.


Minimal configuration of a new server or motherboard
----------------------------------------------------

At our site the following minimal settings are required for a new server or a new motherboard.  

The (BMC) setup is accessed via the ...

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

