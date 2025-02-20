.. _Lenovo_SD665_V3:

========================
Lenovo SD665_V3 server
========================

.. Contents::

This page contains information about Lenovo SD665_V3_ servers deployed in our cluster.
The Lenovo ThinkSystem SD665_V3_ is a 2-socket ½U server that features the AMD EPYC 9004 "Genoa" family of processors. 

The nodes are housed in the upgraded ThinkSystem DW612S_ enclosure with SMM2_ management module.
See the SMM2_ page with SMM2_ functions and IPMItool_ commands for managing the SMM2_.

To offer solution-level interoperability support for HPC and AI configurations based on the Lenovo ThinkSystem portfolio and OEM components,
Lenovo_EveryScale_ extensively tests the components and their combinations.
The extensive testing results in a Best_Recipe_ release of software and firmware levels.
Lenovo warrants Best_Recipe_ components to work seamlessly together as a fully integrated data center solution instead of a collection of individual components at the time of implementation.

.. _SMM2: https://pubs.lenovo.com/mgt_tools_smm2/
.. _SD665_V3: https://lenovopress.lenovo.com/lp1612-lenovo-thinksystem-sd665-v3-server
.. _DW612S: https://pubs.lenovo.com/dw612s_neptune_enclosure/
.. _IPMItool: https://github.com/ipmitool/ipmitool
.. _Lenovo_EveryScale: https://lenovopress.lenovo.com/lp0900-lenovo-everyscale-lesi
.. _Best_Recipe: https://support.lenovo.com/us/en/solutions/HT510136
.. _NVIDIA_Lenovo_EveryScale: https://network.nvidia.com/support/firmware/lenovo-intelligent-cluster/
.. _Lenovo_Archive: https://network.nvidia.com/support/firmware/lenovo-archive/

NVIDIA InfiniBand Adapter (SharedIO)
=======================================

The SD665_V3_ has a water-cooled NVIDIA 2-Port PCIe Gen5 x16 InfiniBand Adapter (SharedIO) 
`ThinkSystem NVIDIA ConnectX-7 NDR200 InfiniBand QSFP112 Adapters <https://lenovopress.lenovo.com/lp1693-thinksystem-nvidia-connectx-7-ndr200-infiniband-qsfp112-adapters>`_.
The adapter is located in the right-hand SD665_V3_ node and connects both servers in the tray.
https://datacentersupport.lenovo.com/de/en/solutions/ht510888

There is important information regarding SharedIO for older SD650 servers in the article 
`Considerations when using ThinkSystem SD650, SD650 V2, SD650 V3 and ConnectX-6 HDR, ConnectX-7 NDR SharedIO <https://support.lenovo.com/us/en/solutions/ht510888-thinksystem-sd650-and-connectx-6-hdr-sharedio-lenovo-servers-and-storage>`_.
The issues have apparently been resolved in the SD665_V3_ system.

Please note that several Infiniband tools such as ``ibnetdiscover`` fail with an error message when executed on the SD665_V3_ "auxiliary" (left-hand) node, 
and you **must** execute such tools on the "primary" (right-hand) node (private communication with a Lenovo support person).

For debugging purposes, Mellanox provides a linux-sysinfo-snapshot_ tool which
is designed to take a snapshot of all the configuration and relevant information on the server and Mellanox's adapters.

.. _linux-sysinfo-snapshot: https://github.com/Mellanox/linux-sysinfo-snapshot

Updating Mellanox Infiniband firmware
-----------------------------------------------

* Mellanox Infiniband and Ethernet software and firmware **MLNX_OFED / MLNX_EN for Lenovo** must be downloaded from the special NVIDIA_Lenovo_EveryScale_ site.
  Click on the ``Firmware`` tab to download the latest firmware.
* Older firmware can be downloaded from the Lenovo_Archive_.

The Lenovo Mellanox adapters' firmware **must** be updated with the special Lenovo firmware executable, for example::

  mlxfwmanager_LES_24A_ES_OFED-24.04-0_build1

Adding the ``--query`` flag will display firmware versions.

**WARNING:**
There seems to be an undocumented restriction that node Virtual_Reseat_ (performed virtually using the SMM2_ module)
are **required** whenever SharedIO adapter firmwares are updated!! 
Both the **left and right nodes** of a tray have to be reseated simultaneously!

The node Virtual_Reseat_ may be performed in several alternative ways:

* Using Lenovo Confluent_ software.
* Using the DW612S_ SMM2_ web GUI (see the SMM2_ page).
* Using IPMItool_ commands (see the :ref:`Lenovo_DW612S` page).

This command displays the NVIDIA/Mellanox firmware version::

  ibv_devinfo | grep fw_ver

This standard Mellanox drivers tool also reports firmware versions::

  mlxfwmanager --query

Updating networking firmware from a repository folder *XXX/* can be done from the XCC GUI, or by using a OneCLI_ command like this example::

  onecli update flash --nocompare --includeid mlnx-lnvgy_fw_nic_cx-j9m3u-0302_anyos_comp --dir XXX/ --log=5 -N --output /tmp/logs

This will loop over all firmwares in the repository and try to apply them one by one.
To select only a specific firmware family: **TBD**

.. _OneCLI: https://support.lenovo.com/us/en/solutions/ht116433-lenovo-xclarity-essentials-onecli-onecli
.. _Confluent: https://hpc.lenovo.com/users/documentation/whatisconfluent.html
.. _Virtual_Reseat: https://pubs.lenovo.com/mgt_tools_smm2/c_chassis_front_overview

MST (Mellanox Software Tools) service
----------------------------------------

The ``mst`` tool (from the `mft` Mellanox firmware tools package) has a number of functions:

* ``mst help``: Print usage information
* ``mst start``: Create special files that represent Mellanox devices.
* ``mst status -v``: Print current status of Mellanox devices

If it is necessary to reset the firmware on a Mellanox device, this command may have to be used::

  mlxfwreset -d /dev/mst/mt4129_pciconf0 reset 

Documentation and software
==========================

Lenovo provides SD665_V3_ information and downloads:

* https://pubs.lenovo.com/sd665-v3/

There is a `Product Home <https://datacentersupport.lenovo.com/us/en/products/servers/thinksystem/sd665-v3/7d9p>`_ page for downloads.

The `EasyBuild` software module `OpenMPI` seems to have issues with the Mellanox libraries.
Setting these variables may be a workaround::

  export OMPI_MCA_btl='^openib,ofi'
  export OMPI_MCA_mtl='^ofi' 

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

The OpenFabrics Enterprise Distribution (OFED_) is open-source software for RDMA and kernel bypass applications,
as provided by the `OpenFabrics Alliance <http://en.wikipedia.org/wiki/OFED>`_.
Mellanox provides some information about Inbox_drivers_ from various OS vendors,
but it is not stated whether they can be used in place of the drivers from NVIDIA/Mellanox described below.

**IMPORTANT:** The NVIDIA `Red Hat Enterprise Linux (RHEL) 8.10 Driver Documentation <https://docs.nvidia.com/networking/display/rhel810/general+support>`_
has the statement::

  Warning
  ConnectX-7 is only supported as technical preview (i.e., the feature is not fully supported for production).

Since the SD665_V3_ nodes have ``ConnectX-7`` adapters, these are **NOT SUPPORTED** by the Inbox_drivers_ of RHEL drivers at present! 

.. _Inbox_drivers: https://network.nvidia.com/products/adapter-software/ethernet/inbox-drivers/

Installing NVIDIA OFED drivers
..................................

NVIDIA offers a `Linux MLNX OFED repository <https://network.nvidia.com/support/mlnx-ofed-public-repository/>`_ which is enabled by:

1. Install key::

     rpm --import https://www.mellanox.com/downloads/ofed/RPM-GPG-KEY-Mellanox 

2. Add the desired repo, for example::

     cd /etc/yum.repos.d/ 
     wget https://linux.mellanox.com/public/repo/mlnx_ofed/latest/rhel8.10/mellanox_mlnx_ofed.repo
     dnf clean all

3. Install driver packages: TBD?

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

Verify the installed OFED package name and version::

  ofed_info -s

If your kernel version does not match with any of the offered pre-built RPMs,
you can add your kernel version by using the ``mlnx_add_kernel_support.sh`` script located inside the MLNX_OFED package.

**Notices**:

* On Redhat and SLES distributions with errata kernel installed there is no need to use the ``mlnx_add_kernel_support.sh`` script.
  The regular installation can be performed and weak-updates mechanism will create symbolic links to the MLNX_OFED kernel modules.
* OFED_ software includes kernel modules for the running kernel, and these must be rebuilt if the kernel is upgraded!

.. _OFED: https://www.openfabrics.org/index.php/resources/ofed-for-linux-ofed-for-windows/ofed-overview.html
