.. _Lenovo_SD665_V3:

========================
Lenovo SD665_V3 server
========================

.. Contents::

This page contains information about Lenovo SD665_V3_ servers deployed in our cluster.
The Lenovo ThinkSystem SD665_V3_ is a 2-socket ½U server that features the AMD EPYC 9004 "Genoa" family of processors. 

The nodes are housed in the upgraded ThinkSystem DW612S_ enclosure.

.. _SD665_V3: https://lenovopress.lenovo.com/lp1612-lenovo-thinksystem-sd665-v3-server
.. _DW612S: https://pubs.lenovo.com/dw612s_neptune_enclosure/

NVIDIA InfiniBand Adapter (SharedIO)
=======================================

The SD665_V3_ has a water-cooled NVIDIA 2-Port PCIe Gen5 x16 InfiniBand Adapter (SharedIO) 
`ThinkSystem NVIDIA ConnectX-7 NDR200 InfiniBand QSFP112 Adapters <https://lenovopress.lenovo.com/lp1693-thinksystem-nvidia-connectx-7-ndr200-infiniband-qsfp112-adapters>`_.
The adapter is located in the right-hand SD665_V3_ node and connects both servers in the tray.
Note that the right-hand SD665_V3_ node must be up and running in order for the left-hand node to have InfiniBand connectivity!

There is important information in the article 
`Considerations when using ThinkSystem SD650, SD650 V2, SD650 V3 and ConnectX-6 HDR, ConnectX-7 NDR SharedIO <https://support.lenovo.com/us/en/solutions/ht510888-thinksystem-sd650-and-connectx-6-hdr-sharedio-lenovo-servers-and-storage>`_:

Power up
--------

When powering up nodes with Shared I/O adapters, from an A/C down state or after a virtual reseat, the Primary node must be powered on before the Auxiliary node.
It is recommended to wait until the Primary node completes POST before attempting to power up the Auxiliary node, or ideally, wait until the Primary node has completed boot to the operating system.
Failure to wait will result in the Auxiliary node not being granted power permission, and therefore, the Auxiliary node will not boot.
The System Event Log (SEL) for the Auxiliary node will also report the either one of following events:

* Module/Board - SharedIO fail Asserted
* Sensor Aux/Pri SharedIO has transitioned to critical from a less severe state.

Power down or Rebooting
-------------------------

When powering down, or rebooting, nodes with Shared I/O adapters, the Auxiliary node should always be powered down before the Primary Node.
The Aux adapter cannot operate without the Primary node adapter having power.
There is no mechanism in place to prevent the Primary node from powering down while the Auxiliary node is still powered up, so it is important to pay close attention to the order that the nodes are being powered off.
Failure to power down the Auxiliary node first will result in a fault reported in the System Event Log (SEL) on the Auxiliary node, or in some cases, a software NMI once the Aux adapter loses power and is no longer visible:

* Slot/Connector - PCIe 1 - Fault - PCIe 1
* Critical interrupt - NMI State - Software NMI

Other considerations
-------------------------

When installing the Shared I/O adapters, the primary adapter should be installed on the right side of the chassis, with the auxiliary adapter on the left side.

To update firmware on the Shared I/O adapter, first power down the Auxiliary node.
Once the code has been applied to the primary card, power down the Primary node and power it back up.
Once the operating system has booted, power up the Auxiliary node.

If at any point a PCI bus fault or Software NMI has been generated in the System Event Log because of an incorrect power off sequence, a virtual reseat can be done to clear the event.

Documentation and software
==========================

Lenovo provides SD665_V3_ information and downloads:

* https://pubs.lenovo.com/sd665-v3/

There is a `Product Home <https://datacentersupport.lenovo.com/us/en/products/servers/thinksystem/sd665-v3/7d9p>`_ page for downloads.

Booting and BIOS configuration
==============================

See the :ref:`Lenovo_BIOS_settings` page.

See the :ref:`Lenovo_XClarity_BMC` page.
