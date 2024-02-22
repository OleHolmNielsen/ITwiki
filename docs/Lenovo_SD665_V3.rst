.. _Lenovo_SD665_V3:

========================
Lenovo SD665_V3 server
========================

.. Contents::

This page contains information about Lenovo SD665_V3_ servers deployed in our cluster.
The Lenovo ThinkSystem SD665_V3_ is a 2-socket ½U server that features the AMD EPYC 9004 "Genoa" family of processors. 

The nodes are housed in the upgraded ThinkSystem DW612S_ enclosure.

The SD665_V3_ has a water-cooled NVIDIA 2-Port PCIe Gen5 x16 InfiniBand Adapter (SharedIO) 
`ThinkSystem NVIDIA ConnectX-7 NDR200 InfiniBand QSFP112 Adapters <https://lenovopress.lenovo.com/lp1693-thinksystem-nvidia-connectx-7-ndr200-infiniband-qsfp112-adapters>`_.
The adapter is located in the right-hand SD665_V3_ node and connects both servers in the tray.
Note that the right-hand SD665_V3_ node must be up and running in order for the left-hand node to have InfiniBand connectivity!

.. _SD665_V3: https://lenovopress.lenovo.com/lp1612-lenovo-thinksystem-sd665-v3-server
.. _DW612S: https://pubs.lenovo.com/dw612s_neptune_enclosure/

Documentation and software
==========================

Lenovo provides SD665_V3_ information and downloads:

* https://pubs.lenovo.com/sd665-v3/

There is a `Product Home <https://datacentersupport.lenovo.com/us/en/products/servers/thinksystem/sd665-v3/7d9p>`_ page for downloads.

Booting and BIOS configuration
==============================

See the :ref:`Lenovo_BIOS_settings` page.

See the :ref:`Lenovo_XClarity_BMC` page.
