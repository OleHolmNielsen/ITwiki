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

There is important information regarding SharedIO for older SD650 servers in the article 
`Considerations when using ThinkSystem SD650, SD650 V2, SD650 V3 and ConnectX-6 HDR, ConnectX-7 NDR SharedIO <https://support.lenovo.com/us/en/solutions/ht510888-thinksystem-sd650-and-connectx-6-hdr-sharedio-lenovo-servers-and-storage>`_.
The issues have apparently been resolved in the SD665_V3_ system.

Documentation and software
==========================

Lenovo provides SD665_V3_ information and downloads:

* https://pubs.lenovo.com/sd665-v3/

There is a `Product Home <https://datacentersupport.lenovo.com/us/en/products/servers/thinksystem/sd665-v3/7d9p>`_ page for downloads.

Booting and BIOS configuration
==============================

See the :ref:`Lenovo_BIOS_settings` page.

See the :ref:`Lenovo_XClarity_BMC` page.

There is a document
`Lenovo ThinkSystem SR645 Recommended UEFI and OS settings for Lenovo Scalable Infrastructure (LeSI) <https://download.lenovo.com/servers/sr645_and_sr665_uefi_and_os_settings_v1.4.txt>`_
which recommends:

* For best performance set to **Maximum Performance** first, then set to **Custom Mode**

OFED software and drivers
-------------------------

The OpenFabrics Enterprise Distribution (OFED_) is open-source software for RDMA and kernel bypass applications, as provided by the `OpenFabrics Alliance <http://en.wikipedia.org/wiki/OFED>`_.

Install these prerequisite packages::

  dnf -y install libibverbs rdma libmlx4 libibverbs-utils infiniband-diags librdmacm librdmacm-utils ibacm
  dnf -y install tk gcc-gfortran kernel-modules-extra

For the Mellanox Infiniband adapters it is recommended to download the .tar.gz file from 
`Mellanox OpenFabrics Enterprise Distribution for Linux (MLNX_OFED) <https://network.nvidia.com/products/infiniband-drivers/linux/mlnx_ofed/>`_.
Unpack the tar-ball and run the installer, for example::

  tar xzf MLNX_OFED_LINUX-24.01-0.3.3.1-rhel8.9-x86_64.tgz
  cd MLNX_OFED_LINUX-24.01-0.3.3.1-rhel8.9-x86_64
  ./mlnxofedinstall

The installer script has some options::

  ./mlnxofedinstall --help
  ./mlnxofedinstall -q          # Set quiet - no messages will be printed
  yes | ./mlnxofedinstall       # Answer yes to all questions

The installer attempts to make firmware updates, but we may experience this warning::

  Attempting to perform Firmware update...
  The firmware for this device is not distributed inside Mellanox driver: 42:00.0 (PSID: LNV0000000049)
  To obtain firmware for this device, please contact your HW vendor.
  Failed to update Firmware.

so it may be a good idea to add this flag and omit firmware updates::

  ./mlnxofedinstall --without-fw-update

Installation instructions are in the *User Manual* from the `Mellanox documentation <https://docs.nvidia.com/networking/software/adapter-software/index.html#linux>`_.

Verify that the Mellanox driver RPMs have been installed and the ``openibd`` service started::

  rpm -qa | grep mlnx
  systemctl status openibd

If your kernel version does not match with any of the offered pre-built RPMs,
you can add your kernel version by using the ``mlnx_add_kernel_support.sh`` script located inside the MLNX_OFED package.

**Notices**:

* On Redhat and SLES distributions with errata kernel installed there is no need to use the ``mlnx_add_kernel_support.sh`` script.
  The regular installation can be performed and weak-updates mechanism will create symbolic links to the MLNX_OFED kernel modules.
* OFED_ software includes kernel modules for the running kernel, and these must be rebuilt if the kernel is upgraded!

.. _OFED: https://www.openfabrics.org/index.php/resources/ofed-for-linux-ofed-for-windows/ofed-overview.html
