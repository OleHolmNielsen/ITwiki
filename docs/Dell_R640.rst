.. _Dell_R640:

================
Dell R640 server
================

.. Contents::

Note: We have moved contents about BIOS_ settings, iDRAC_, and racadm_ to separate pages,
see the main page :ref:`Dell_servers_and_storage`.

This page contains information out Dell PowerEdge R640_ could servers which we have deployed in our cluster.

.. _R640: https://www.dell.com/en-us/work/shop/povw/poweredge-r640
.. _BIOS: https://en.wikipedia.org/wiki/BIOS
.. _racadm: https://www.dell.com/support/manuals/us/en/04/idrac9-lifecycle-controller-v3.0-series/idrac_3.00.00.00_racadm/introduction

Documentation and software
==========================

Dell Support_ provides R640_ information:

* R640_manuals_.
* R640_downloads_.
* iDRAC9_manuals_.
* Dell OpenManage_.
* Dell Linux_Engineering_ site.
* Dell Linux_repository_.
* Dell EMC OpenManage_Ansible_Modules_.

.. _R640_manuals: https://www.dell.com/support/home/us/en/04/product-support/product/poweredge-r640/manuals
.. _R640_downloads: https://www.dell.com/support/home/us/en/04/product-support/product/poweredge-r640/drivers
.. _Support: https://www.dell.com/support/home/us/en/04/product-support/product/poweredge-r640/research
.. _OpenManage: https://www.dell.com/support/article/us/en/04/sln310664/dell-emc-openmanage-systems-management-portfolio-overview?lang=en
.. _Linux_Engineering: https://linux.dell.com/
.. _Linux_repository: https://linux.dell.com/repo/hardware/
.. _iDRAC: https://en.wikipedia.org/wiki/Dell_DRAC
.. _iDRAC9_manuals: https://www.dell.com/support/home/us/en/19/products/software_int/software_ent_systems_mgmt/remote_ent_sys_mgmt/rmte_ent_sys_idrac9
.. _OpenManage_Ansible_Modules: https://github.com/dell/dellemc-openmanage-ansible-modules
.. _Function_key: https://en.wikipedia.org/wiki/Function_key

===============================================================================================

PERC H330 RAID controller
=========================

The R640_ comes with a PERC H330_ RAID controller.

By default the installed disks are unallocated, and you have to configure their usage.

Press the **F2** Function_key_ during start-up to enter the setup menus.
Go to the *Device Settings* menu.

Configure the H330_ via the menu item *Device Settings* and select the RAID controller item:

* In the RAID controller *Main Menu* select the *Configuration Management* item.

* Change the disk setup into **Convert to Non-RAID**.

* In the *Controller Management* menu item *Select Boot Device* define the non-RAID disk as the boot device.

Press *Finish* to save all settings.

.. _H330: https://www.dell.com/en-us/shop/dell-perc-h330-raid-controller/apd/405-aadw/storage-drives-media

raidcfg tool
------------

The OpenManage_ tool raidcfg_ can be installed from the above mentioned *Dell EMC OpenManage Deployment Toolkit (Linux)* folder ``/mnt/RPMs/rhel7/x86_64/``::

  yum install raidcfg*rpm

See `raidcfg quick reference <https://www.dell.com/support/manuals/us/en/04/poweredge-r640/dtk_cli-v6/quick-reference-to-raidcfg-commands?guid=guid-9b466297-bc89-49f5-99a9-ab29ea937d41&lang=en-us>`_.

To list installed RAID controllers::

  /opt/dell/toolkit/bin/raidcfg controller

.. _raidcfg: https://www.dell.com/support/manuals/us/en/04/poweredge-r640/dtk_cli-v6/raidcfg?guid=guid-94012b57-ca54-44c3-9319-e472d0598ff4&lang=en-us

perccli tool
------------

The perccli_ tool for Linux is downloaded from the PowerEdge server's *SAS RAID* downloads

Install the RPM (the version may differ)::

  tar xzf perccli_linux_NF8G9_A07_7.529.00.tar.gz
  cd perccli_7.5-007.0529_linux/
  yum install perccli-007.0529.0000.0000-1.noarch.rpm 
  ln -s /opt/MegaRAID/perccli/perccli64 /usr/local/bin/perccli

See the *Reference Guide* at https://topics-cdn.dell.com/pdf/dell-sas-hba-12gbps_reference-guide_en-us.pdf

Example command::

  perccli show

Disk status
...........

This command shows all disks for controller 1::

  perccli /c1/eall/sall show 

This command shows the RAID rebuild status for controller 1::

  perccli /c1/eall/sall show rebuild

.. _perccli: https://www.dell.com/support/home/us/en/04/drivers/driversdetails?driverid=f48c2

===============================================================================================

.. _NVDIMM_Setup:

NVDIMM Optane persistent memory setup
=========================================

Note that Intel has discontinued NVDIMM_ Optane persistent memory with recent processor generations
as described in the Optane_EOL_ page.
Documentation of NVDIMM_ Optane persistent memory:

* NVDIMM_Wiki_ at kernel.org.
* `Using NVDIMM persistent memory storage <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/managing_storage_devices/using-nvdimm-persistent-memory-storage_managing-storage-devices>`_.

Configuration of persistent memory in Dell PowerEdge servers is described in the manual *Dell EMC PMem 200 Series User's Guide* 
in the `server documentation <https://www.dell.com/support/home/en-uk/product-support/product/poweredge-r750/docs>`_:

* To configure NVDIMM_ 3D_XPoint_ known as *Intel Optane* persistent memory DIMM modules go to the *System BIOS Settings* boot menus.
  Select the menu::

    Memory Settings > Persistent Memory > Intel Persistent Memory > Persistent Memory DIMM Configuration

* Memory mode configuration for persistent memory:

  - To create an NVDIMM_ goal in BIOS, go to the sub-menu ``Create Goal Config``.
  - The BIOS_ options determine how the goal is created and the PMems are configured::

      Operation Target: Platform - Applies the goal to all the DIMMs in the system (recommended)
      Persistent [%]: 100 - Creates a goal of 100% Persistent memory across the selected PMems

Configure persistent memory namespaces
---------------------------------------------

Install this package::

  dnf install ndctl

and list all physical devices::

  ndctl list -DHi

The configuration of namespaces will decide how much memory capacity to expose to the OS.
Create a namespace on each of the persistent memory modules::

  ndctl create-namespace

See the manual for ndctl-create-namespace_.
List namespaces::

  ndctl list -N

To correlate a namespace to a PMem device, use the ``lsblk`` command.

.. _NVDIMM: https://en.wikipedia.org/wiki/NVDIMM
.. _NVDIMM_Wiki: https://nvdimm.wiki.kernel.org/
.. _3D_XPoint: https://en.wikipedia.org/wiki/3D_XPoint
.. _Optane_EOL: https://www.intel.com/content/www/us/en/support/articles/000057951/memory-and-storage/intel-optane-memory.html
.. _ndctl-create-namespace: https://docs.pmem.io/ndctl-user-guide/ndctl-man-pages/ndctl-create-namespace

Managing NVDIMMs with ipmctl
---------------------------------

The ipmctl_ is a utility for configuring and managing Intel® Optane™ Persistent Memory modules (PMem).
On EL8 systems install this package from EPEL_::

  dnf install ipmctl

Read the ipmctl_ manual page.
For example, display the NVDIMM_ in the system::

  $ ipmctl show -dimm
   DimmID | Capacity    | LockState        | HealthState | FWVersion    
  ======================================================================
   0x0001 | 126.742 GiB | Disabled, Frozen | Healthy     | 02.02.00.1553
   0x1001 | 126.742 GiB | Disabled, Frozen | Healthy     | 02.02.00.1553

Other useful commands::

  $ ipmctl help
  $ ipmctl show -topology -socket

.. _ipmctl: https://github.com/intel/ipmctl
.. _EPEL: https://docs.fedoraproject.org/en-US/epel/
