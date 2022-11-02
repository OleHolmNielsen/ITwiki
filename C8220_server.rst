.. _C8220_server:

Dell PowerEdge C8220 Intel Ivy Bridge compute nodes
===================================================

.. Contents::

Dell product info and support for C8220
-----------------------------------------------------

Product info is on the PowerEdge C8220_ Compute Node page.
For Dell support use the server's **service tag** on the Dell_support_ page.
There is also a general Dell C8000_support_ page, including C8000_manuals_ and a C8220_Hardware_Owners_Manual_.

.. _C8220: http://www.dell.com/us/business/p/poweredge-c8220/pd
.. _Dell_support: http://support.dell.com/
.. _C8000_support: http://www.dell.com/support/home/us/en/04/product-support/product/poweredge-c8000/get-started
.. _C8000_manuals: http://www.dell.com/support/home/us/en/04/product-support/product/poweredge-c8000/manuals
.. _C8220_Hardware_Owners_Manual: ftp://ftp.dell.com/Manuals/all-products/esuprt_ser_stor_net/esuprt_cloud_products/poweredge-c8000_Owner%27s%20Manual3_en-us.pdf

Dell Update Packages and repositories
-------------------------------------

Dell_Update_Packages_ offer ease and flexibility for updating the system software on Dell *PowerEdge(TM)* systems.  **Outdated??**.

.. _Dell_Update_Packages: http://www.dell.com/support/home/us/en/19/product-support/product/dell-update-pckages-v6.2/manuals

You may install a `Dell OpenManage Server Administrator <http://www.dell.com/support/contents/us/en/19/article/Product-Support/Self-support-Knowledgebase/enterprise-resource-center/Enterprise-Tools/OMSA>`_ server.

You can also use the Dell OpenManage_Linux_Repository_ offering repositories_.

.. _OpenManage_Linux_Repository: http://linux.dell.com/wiki/index.php/Repository/hardware
.. _repositories: http://linux.dell.com/repo/hardware/

Diagnostics
-----------

Dell PowerEdge C Server System Management
.........................................

See the page http://www.poweredgec.com/ containing a number of diagnostics tools for PowerEdge C servers.


Dell System E-Support Tool (DSET)
.................................

*Dell System E-Support Tool* (DSET_) provides the ability to collect hardware, storage and operating system information from a Dell PowerEdge server.

This information is consolidated into a single *System Configuration Report* that can be used for troubleshooting or inventory collection of a system. 
The browser user interface provides a convenient means to view specific data through hierarchical menu trees.

Download the DSET_ software for Linux as well as the **DSET Manuals** from the DSET_ page.
Install prerequisite packages::

  yum install sblim-sfcb

For installation instructions see the DSET_ *ReleaseNotes.txt* file.
Execute the DSET_ installation file::

  sh dell-dset-lx64-3.7.0.219.bin

.. _DSET: http://www.dell.com/support/contents/us/en/19/article/Product-Support/Self-support-Knowledgebase/enterprise-resource-center/Enterprise-Tools/dell-system-e-support-tool

C8220 BIOS settings
-----------------------------------------------------

Our C8220 nodes have been delivered with *performance optimized BIOS settings*.
However, there still are a few non-default settings which we must configure.

During power-on, **press F2** to enter *Setup*.
On the Main screen the network **MAC addresses** are displayed.

The following non-default settings must be made:

* **Advanced->CPU Configuration**: Hyper-threading = Disabled

* **Boot**: Quiet Boot = Disabled

* **Boot->Legacy boot device->Network**: Use F6 to move IBA (Intel Ethernet PXE boot) to 1st position. Make sure that MLNX (Mellanox Infiniband) is last.

* **Server**: Restore on AC Power Loss = Last State 

* **Server->Set BMC Lan Configuration->BMC Lan Port Configuration**: Select *Shared* (Lan port 1 is shared) or *Dedicated* (physical port).
  There is no option to select the C8000 chassis consolidated management port.

Performance BIOS settings
-------------------------

The nodes delivered by Dell have special *Performance BIOS settings*, but when a system board is replaced you get standard settings.
The standard settings **must be changed**, both as shown above, and in addition:


* **Advanced->Power Management**:

  - Power Management = Maximum Performance

* **Advanced->CPU Configuration**:

  - Hyper-threading = Disabled
  - Turbo Mode = Enabled
  - C-states = Disabled
  - Virtualization Technology = Disabled

* **Advanced->Memory Configuration**:

  - Memory Frequency = Auto
  - Memory Turbo Mode = Enabled
  - Memory Throttling Mode = Disabled
  - Memory Operating Mode = Optimizer Mode

* **Boot**:

  - Boot Type Order = Network, RAID, Hard Disk, USB, CD/DVD
  - Boot Mode = BIOS
  - Quiet Boot = Disabled

C8220 BIOS and firmware updates
-----------------------------------------------------

From the Dell_support_ page use the node's *Service tag*, and click on *Get drivers and downloads* to find the available firmware and software updates.
Pay special attention to BIOS and *Embedded Server Management* (BMC)

Download Linux (64-bit) files to ``audhumbla:/scratch/C8220/``.
Files of the *BIN* type may be named *C8000_BIOS_6GK31_LN_2.3.1.BIN*, for example.
Make the BIN files executable::

  chmod 755 *.BIN

When updating firmwares, the **node must be idle** (no user jobs).
On the C8220 compute nodes you may run one of the executables, for example::

  /home/audhumbla/C8220/C8000_BIOS_6GK31_LN_2.3.1.BIN --help

To run without input prompts use *-q*, and to reboot if needed use *-r*.

C8000 chassis cabling and BMC networking
-----------------------------------------------------

The C8000 chassis has (at least with C8220 nodes) two Ethernet ports for shared access to the BMC Ethernet NIC interfaces.

You can access BMC using two modes of operation: **non-central independent mode** or **non-central consolidated mode**:

1. In the non-central independent mode, you can access BMC through dedicated-NIC using the sled’s BMC management port. 
2. In the non-central consolidated mode, you can access BMC through shared-NIC using the PowerEdge C8000 server enclosure’s BMC management port or Ethernet port.

It is most convenient to use method 2.
**NOTE**: Do not connect the server enclosure’s front Ethernet connector and back BMC management port to the same Ethernet switch.
Presumably there is a built-in Ethernet switch in the C8000 chassis, and you must avoid network loops.

In the Dell PowerEdge C8220_Hardware_Owners_Manual_ p.16-20 *Management Interface* there is a detailed description of the BMC networking.

In the C8220_Hardware_Owners_Manual_ section *Installing the BMC Management Cable* is shown how to install 
the BMC management cable to the LAN passthrough connector on the NPDB and the other end of the cable to the consolidated BMC cable connector on the system board.
Apparently this cable **has not been installed** on our C8220 servers, so the consolidated chassis port cannot be used.

There is a nice C8000 cabling guide: http://www.slideshare.net/PrincipledTechnologies/a-quick-and-easy-guide-to-setting-up-the-dell-poweredge-c8000 

C8220 Linux installation
-----------------------------------------------------

The C8220 servers **require** CentOS/RHEL 6.5.
Using older releases you will get a *hardware not supported* error.

The CentOS6 Ethernet device names are::

  em1: Port 1
  em2: Port 2

Mellanox Infiniband adapter
-----------------------------------------------------

See the `MLNX_OFED: Firmware - Driver Compatibility Matrix <http://www.mellanox.com/page/mlnx_ofed_matrix?mtag=linux_sw_drivers>`_.
Note: Our ConnectX-2 adapters are **not supported**.

Our C8220 servers have these Mellanox Infiniband adapters:

* Nodes i001-i021: ???? `InfiniBand 4X QDR ConnectX-2 PCIe G2 Dual Port HCA <http://www8.hp.com/emea_middle_east/en/products/file-object-storage/product-detail.html?oid=4068635#!tab=features>`_

* Nodes i022-i051: Network controller: Mellanox Technologies MT27500 Family [ConnectX-3]

Verify the presence of the adapter::
  
  [root@i001 ~]# lspci | grep Mellanox
  08:00.0 InfiniBand: Mellanox Technologies MT26428 [ConnectX VPI PCIe 2.0 5GT/s - IB QDR / 10GigE] (rev b0)


OFED software and drivers
-------------------------

The OpenFabrics Enterprise Distribution (OFED_) is open-source software for RDMA and kernel bypass applications, as provided by the `OpenFabrics Alliance <http://en.wikipedia.org/wiki/OFED>`_.

.. _OFED: https://www.openfabrics.org/index.php/resources/ofed-for-linux-ofed-for-windows/ofed-overview.html

For the Mellanox Infiniband adapters it is recommended to download the .tar.gz file from 
`Mellanox OpenFabrics Enterprise Distribution for Linux (MLNX_OFED) <http://www.mellanox.com/content/pages.php?pg=products_dyn&product_family=26&menu_section=34#tab-three>`_.

**Notice:** OFED software includes kernel modules for the running kernel, and these must be rebuilt if the kernel is upgraded!

Installation instructions are in the *User Manual* on the Mellanox website.

If your kernel version does not match with any of the offered pre-built RPMs, you can add your kernel version by using the ``mlnx_add_kernel_support.sh`` script.

There are some prerequisite RPMs::

  yum install perl pciutils python gcc-gfortran libxml2-python tcsh libnl.i686 libnl expat glib2 tcl libstdc++ bc tk gtk2 atk cairo numactl pkgconfig ethtool lsof

Among other things output from the installation includes::

  - The FCA Manager and FCA MPI Runtime library are installed in /opt/mellanox/fca directory.
  - The FCA Manager will not be started automatically. 
  - To start FCA Manager now, type:
    # /etc/init.d/fca_managerd start

  - There should be single process of FCA Manager running per fabric.

  - To start FCA Manager automatically after boot, type:
    # /etc/init.d/fca_managerd install_service

  - Check /opt/mellanox/fca/share/doc/fca/README.txt for quick start instructions.

Testing the Infiniband adapter
..............................

To test the Infiniband adapter::

  /usr/bin/hca_self_test.ofed

Process limits
..............

The user batch jobs inherit the user limits from the Torque *pbs_mom* daemons and seem to ignore the settings in the file ``/etc/security/limits.conf``.

Therefore it is required on Infiniband nodes to add the file ``/etc/sysconfig/pbs_mom`` containing::

  ulimit -n 32768  
  ulimit -s unlimited
  ulimit -l unlimited

This file is read when the *pbs_mom* daemon is started.

How to increase MTT Size in Mellanox HCA
........................................

Jobs end (successfully) with this type of errors message::

  # Fix Registerable memory

  # WARNING: It appears that your OpenFabrics subsystem is configured to only
  # allow registering part of your physical memory.  This can cause MPI jobs to
  # run with erratic performance, hang, and/or crash.

  # This may be caused by your OpenFabrics vendor limiting the amount of
  # physical memory that can be registered.  You should investigate the
  # relevant Linux kernel module parameters that control how much physical
  # memory can be registered, and increase them to allow registering all
  # physical memory on your machine.

  #  Local host:              g054.dcsc.fysik.dtu.dk
  #  Registerable memory:     4096 MiB
  #  Total memory:            65501 MiB

The solution can be found in http://community.mellanox.com/docs/DOC-1120.
For RHEL/CentOS 6.x, the fix/workaround is create a file (e.g. /etc/modprobe.d/mofed.conf file) and add this line below, and restart openibd service::

    options mlx4_core log_num_mtt=25

What we do is to add *log_num_mtt=25* in the following line in ``/etc/modprobe.d/mlx4_en.conf``::

  options mlx4_core log_num_mtt=25 pfctx=0 pfcrx=0

Probably one needs to do::

  service openibd restart

Uninstall OFED and drivers
..........................

It may be necessary to remove the OFED software and drivers, for example in order to upgrade RPM packages including the kernel.
The above mentioned .ISO image contains an uninstall script::

  /mnt/uninstall.sh

Mellanox firmware upgrade
-------------------------

Firmware upgrades and installation instructions should be downloaded from the Dell support page.

Steps to be followed for firmware upgrade:

* Install HCA card in supported Server
* Install supported InfiniBand drivers based off MLNX OFED 1.5.3.300 or later
* Use mstflint to Query the HCA Card
* Validate that the query reports HCA card has PSID =  HP_0230240009
* Use mstflint to upgrade the HCA card firmware
* Reboot the server and verify that the card is running new Firmware 

Verify the hardware and firmware for the relevant PCI device 82:00.0 by::

  # mstflint -d 82:00.0 q
  Image type:      FS2
  FW Version:      2.30.8000
  Rom Info:        type=PXE  version=3.4.151 devid=4099 proto=VPI
  Device ID:       4099
  Description:     Node             Port1            Port2            Sys image
  GUIDs:           f452140300596790 f452140300596791 f452140300596792 f452140300596793 
  MACs:                                 f45214596791     f45214596792
  VSD:             
  PSID:            DEL0A30000019


You **must verify** the correct hardware ID PSID: HP_0230240009 before installing new firmware!
Upgrade the firmware by::

  mstflint -d 82:00.0 -i <fw-file.bin> -nofs burn
  mstflint -d 82:00.0 q
