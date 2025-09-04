.. _Lenovo_SD650-N_V2:

========================
Lenovo SD650-N_V2 server
========================

.. Contents::

This page contains information about Lenovo SD650-N_V2_ servers deployed in our cluster.
The Lenovo ThinkSystem SD650-N_V2_ is a 2-socket 1U server that features the Intel Xeon family of processors and 4 A100_ GPUs and an NVLink_ interconnect. 

The nodes are housed in the upgraded ThinkSystem DW612S_ enclosure.

.. _DW612S: https://pubs.lenovo.com/dw612s_neptune_enclosure/
.. _SD650-N_V2: https://lenovopress.lenovo.com/lp1396-thinksystem-sd650-n-v2-server
.. _A100: https://www.nvidia.com/en-us/data-center/a100/
.. _NVLink: https://en.wikipedia.org/wiki/NVLink

Documentation and software
==========================

Lenovo provides SD650-N_V2_ information and downloads:

* https://pubs.lenovo.com/sd650-n-v2/

Booting and BIOS configuration
==============================

See the :ref:`Lenovo_BIOS_settings` page.

See the :ref:`Lenovo_XClarity_BMC` page.

NVIDIA GPUs
==============

Inquire GPU status with::

  nvidia-smi

The SD650-N_V2_ server has 4 A100_ GPUs with NVLink_ interconnect.
Inquire about the NVLink_ status::

  nvidia-smi nvlink --status
  nvidia-smi nvlink --help
