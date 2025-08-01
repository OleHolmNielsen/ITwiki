.. _Lenovo_SD650-N_V3:

========================
Lenovo SD650-N_V3 server
========================

.. Contents::

This page contains information about Lenovo SD650-N_V3_ servers deployed in our cluster.
The Lenovo ThinkSystem SD650-N_V3_ is a 2-socket 1U server that features the Intel Xeon family of processors and 4 H200_ GPUs and an NVLink_ interconnect. 

The nodes are housed in the upgraded ThinkSystem DW612S_ enclosure.

.. _DW612S: https://pubs.lenovo.com/dw612s_neptune_enclosure/
.. _SD650-N_V3: https://lenovopress.lenovo.com/lp1613-thinksystem-sd650-n-v3-server
.. _H200: https://www.nvidia.com/en-us/data-center/h200/
.. _NVLink: https://en.wikipedia.org/wiki/NVLink

Documentation and software
==========================

Lenovo provides SD650-N_V3_ information and downloads:

* https://pubs.lenovo.com/sd650-n-v3/

Booting and BIOS configuration
==============================

See the :ref:`Lenovo_BIOS_settings` page.

See the :ref:`Lenovo_XClarity_BMC` page.

NVIDIA GPUs
==============

Inquire GPU status with::

  nvidia-smi

The SD650-N_V3_ server has 4 H200_ GPUs with NVLink_ interconnect.
Inquire about the NVLink_ status::

  nvidia-smi nvlink --status
  nvidia-smi nvlink --help
