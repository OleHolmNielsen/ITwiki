.. _ZFS_filesystems:

===============
ZFS filesystems
===============

.. Contents::

The ZFS_ filesystem is an alternative to XFS_.
While introduced originally in the Solaris_ OS,
ZFS_ has been ported to ZFS_on_Linux_.
See also the OpenZFS_ developers page.

.. _ZFS: https://en.wikipedia.org/wiki/ZFS
.. _ZFS_on_Linux: https://zfsonlinux.org/
.. _OpenZFS: https://openzfs.org/wiki/Main_Page
.. _Solaris: https://en.wikipedia.org/wiki/Oracle_Solaris
.. _XFS: http://en.wikipedia.org/wiki/XFS

ZFS documentation
============================

* Getting_Started_ with ZFS_ including an RHEL-based-distro_ guide.

* First time OpenZFS users are encouraged to check out Aaron_Toponce_ ’s excellent documentation.

* OpenZFS_Newcomers_ documentation and FAQ_.

* `ZFS Basic Concepts <https://openzfs.github.io/openzfs-docs/Basic%20Concepts/index.html>`_.

* `ZFS man-pages <https://openzfs.github.io/openzfs-docs/man/index.html>`_.

* Lustre_ and ZFS_:

  - Lustre_ uses ZFS_, see https://wiki.lustre.org/ZFS.
  - A `ZFS setup for Lustre <https://github.com/ucphhpc/storage/blob/main/zfs/docs/zfs.rst>`_.
  - A `JBOD Setup <https://github.com/ucphhpc/storage/blob/main/jbod/doc/jbod.rst>`_ page.

* `Zpool Concepts <https://openzfs.github.io/openzfs-docs/man/7/zpoolconcepts.7.html>`_.

* `ZFS 101—Understanding ZFS storage and performance <https://arstechnica.com/information-technology/2020/05/zfs-101-understanding-zfs-storage-and-performance/>`_
  and `ZFS fans, rejoice—RAIDz expansion will be a thing very soon <https://arstechnica.com/gadgets/2021/06/raidz-expansion-code-lands-in-openzfs-master/>`_.

.. _Getting_Started: https://openzfs.github.io/openzfs-docs/Getting%20Started/index.html
.. _RHEL-based-distro: https://openzfs.github.io/openzfs-docs/Getting%20Started/RHEL-based%20distro/index.html
.. _Aaron_Toponce: https://pthree.org/2012/12/04/zfs-administration-part-i-vdevs/
.. _OpenZFS_Newcomers: https://openzfs.org/wiki/Newcomers
.. _Lustre: https://wiki.lustre.org/Main_Page
.. _FAQ: https://openzfs.github.io/openzfs-docs/Project%20and%20Community/FAQ.html

Installation of ZFS
=========================

We assume an EL8_ OS in this page.
Following the RHEL-based-distro_ guide, enable the *zfs-release* repo from ZFS_on_Linux_::

  dnf install https://zfsonlinux.org/epel/zfs-release-2-2$(rpm --eval "%{dist}").noarch.rpm

(The ``rpm --eval "%{dist}"`` command simply prints ``.el8`` or similar for your OS).

Use the DKMS_ kernel module installation method::

  dnf install epel-release
  dnf install kernel-devel
  dnf install zfs

The alternative *kABI-tracking kmod* installation method may break the ZFS_on_Linux_ software after kernel upgrades.

.. _DKMS: https://en.wikipedia.org/wiki/Dynamic_Kernel_Module_Support
.. _EL8: https://en.wikipedia.org/wiki/Red_Hat_Enterprise_Linux_derivatives

List disks in the system
=================================

The disks in the system must be identified.
The following commands are useful for listing disk block devices::

  lsblk
  lsscsi --wwn --size

Trying out ZFS
====================

Aaron_Toponce_ 's page has some initial examples.

Create a simple zpool_ named *tank* with 4 unused drives (sde sdf sdg sdh)::

  zpool create tank sde sdf sdg sdh
  zpool status tank
  df -Ph /tank

Define the mount point for the dataset by adding this option::

  -m <mountpoint>

Destroy the testing zpool_::

  zpool destroy tank

A mirrored pool where all data are mirrored 4 times::

  zpool create tank mirror sde sdf sdg sdh

A RAID 0+1 pool with 2+2 disks::

  zpool create tank mirror sde sdf mirror sdg sdh

.. _zpool: https://openzfs.github.io/openzfs-docs/man/8/zpool.8.html

Configuring RAIDZ disks
------------------------

Some examples of RAIDZ_ pools: 
To setup a zpool_ with RAIDZ-1, we use the "raidz1" VDEV, using only 3 drives::

  zpool create tank raidz1 sde sdf sdg

To setup a zpool_ with RAIDZ-2, we use the "raidz2" VDEV::

  zpool create tank raidz2 sde sdf sdg sdh

.. _RAIDZ: https://www.raidz-calculator.com/raidz-types-reference.aspx

Adding an SLOG
--------------

Read about the *Separate Intent Logging Device* (SLOG) in the *ZFS Intent Log* (ZIL_) page.
Use ``/dev/disk/by-id/`` disk names in stead of ``/dev/sd*`` which may be renamed.

To add the (current) disks ``/dev/sdb`` and ``/dev/sdc`` to the SLOG, first identify the device names::

  ls -l /dev/disk/by-id/* | grep sdb$
  ls -l /dev/disk/by-id/* | grep sdc$

**TODO:** Partition the disk with 5 GB for ZIL and the rest for ARC.
The EL8 parted does not support "zfs" partitions???

Add a mirrored SLOG with the devices found to the zpool_::

  zpool add tank log mirror \
   /dev/disk/by-id/wwn-0x600508b1001c978de94b7497de2aa015 \
   /dev/disk/by-id/wwn-0x600508b1001c0be9159fde47f74dd4bc
  zpool status

.. _ZIL: https://pthree.org/2012/12/06/zfs-administration-part-iii-the-zfs-intent-log/

Add SLOG and ZIL on Optane persistent memory
-----------------------------------------------

Configure an `L2ARC cache <https://pthree.org/2012/12/07/zfs-administration-part-iv-the-adjustable-replacement-cache/>`_
using NVDIMM_ 3D_XPoint_ known as *Intel Optane* persistent memory DIMM modules.

To correlate a namespace to a PMem device, use the following command::

  lsblk

Partition the NVDIMM_ disks::

  parted /dev/pmem0 unit s mklabel gpt mkpart primary 2048 4G mkpart primary 4G 120G
  parted /dev/pmem1 unit s mklabel gpt mkpart primary 2048 4G mkpart primary 4G 120G

and then add the partitions as ZFS cache and log::

  zpool add <pool-name> cache /dev/pmem0p2 /dev/pmem1p2 log mirror /dev/pmem0p1 /dev/pmem1p1

.. _NVDIMM: https://en.wikipedia.org/wiki/NVDIMM
.. _3D_XPoint: https://en.wikipedia.org/wiki/3D_XPoint


Useful ZFS commands
-------------------

List ZFS_ filesystems::

  zfs list
  zpool status <name>

Get and set mountpoint::

  zfs get mountpoint <name>
  zfs set mountpoint=/u/zfs <name>

NFS sharing ZFS file systems
================================

Use the zfs_ command to set or list NFS shared::

  zfs set sharenfs='rw=192.168.122.203' pool1/fs1
  zfs get sharenfs pool1/fs1
