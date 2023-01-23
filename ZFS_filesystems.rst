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

* Best_practices_ and caveats.

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

* ZFS_checksums_ are a key feature of ZFS_ and an important differentiator for ZFS_ over other RAID implementations and filesystems. 

.. _Getting_Started: https://openzfs.github.io/openzfs-docs/Getting%20Started/index.html
.. _RHEL-based-distro: https://openzfs.github.io/openzfs-docs/Getting%20Started/RHEL-based%20distro/index.html
.. _Aaron_Toponce: https://pthree.org/2012/12/04/zfs-administration-part-i-vdevs/
.. _Best_practices: https://pthree.org/2012/12/13/zfs-administration-part-viii-zpool-best-practices-and-caveats/
.. _OpenZFS_Newcomers: https://openzfs.org/wiki/Newcomers
.. _Lustre: https://wiki.lustre.org/Main_Page
.. _FAQ: https://openzfs.github.io/openzfs-docs/Project%20and%20Community/FAQ.html
.. _ZFS_checksums: https://openzfs.github.io/openzfs-docs/Basic%20Concepts/Checksums.html

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

ZFS Compression
------------------

Compression is transparent with ZFS_ if you enable it,
see the Compression_and_Deduplication_ page.
This means that every file you store in your pool can be compressed.
From your point of view as an application, the file does not appear to be compressed, but appears to be stored uncompressed. 

To enable compression on a dataset, we just need to modify the ``compression`` property.
The valid values for that property are: "on", "off", "lzjb", "lz4", "gzip", "gzip[1-9]", and "zle"::

  zfs set compression=lz4 <pool-name>

Monitor compression::

  zfs get compressratio <pool-name>

.. _Compression_and_Deduplication: https://pthree.org/2012/12/18/zfs-administration-part-xi-compression-and-deduplication/

ZFS Snapshots and clones
------------------------

ZFS snapshots (see ``man zfs-snapshot``) are similar to snapshots with Linux LVM, see Snapshots_and_clones_.

Snapshot frequently and regularly.
Snapshots are cheap, and can keep a plethora of file versions over time.
Consider using something like the zfs-auto-snapshot_ script.

.. _Snapshots_and_clones: https://pthree.org/2012/12/19/zfs-administration-part-xii-snapshots-and-clones/
.. _zfs-auto-snapshot: https://github.com/zfsonlinux/zfs-auto-snapshot

ZFS backups
--------------

Backup of ZFS filesystems to a remote storage may be done by Sending_and_receiving_filesystems_.

A ZFS snapshot can be sent to a remote system like this example::

  zfs send tank/test@tuesday | ssh user@server.example.com "zfs receive pool/test"

There are several tools for performing such backups:

* zfs-autobackup_ creates ZFS snapshots on a *source* machine and then replicates those snapshots to a *target* machine via SSH.
* https://serverfault.com/questions/842531/how-to-perform-incremental-continuous-backups-of-zfs-pool

.. _Sending_and_receiving_filesystems: https://pthree.org/2012/12/20/zfs-administration-part-xiii-sending-and-receiving-filesystems/
.. _zfs-autobackup: https://github.com/psy0rz/zfs_autobackup

Useful ZFS commands
-------------------

List ZFS_ filesystems and their properties::

  zfs list
  zpool list
  zpool status <pool-name>
  zpool get all <pool-name>
  mount -l -t zfs

See the sub-command manual pages for details (for example ``man zpool-list``).

Get and set a mountpoint::

  zfs get mountpoint <pool-name>
  zfs set mountpoint=/u/zfs <pool-name>

Scrub and Resilver disks
--------------------------

With ZFS on Linux, detecting and correcting silent data errors is done through scrubbing the disks,
see the Scrub_and_Resilver_ page.

.. _Scrub_and_Resilver: https://pthree.org/2012/12/11/zfs-administration-part-vi-scrub-and-resilver/

Scrubbing can be made regularly with crontab, for example monthly::

  0 2 1 * * /sbin/zpool scrub <pool-name>

or alternatively on machines using Systemd_, scrub timers can be enabled on per-pool basis.
See the ``systemd.timer(5)`` manual page.
Weekly and monthly timer units are provided::

  systemctl enable zfs-scrub-weekly@<pool-name>.timer --now
  systemctl enable zfs-scrub-monthly@<pool-name>.timer --now

.. _Systemd: https://en.wikipedia.org/wiki/Systemd

Replacing defective disks
-------------------------------

Detecting broken disks is explained in the Scrub_and_Resilver_ page.
See the zpool-status_ if any disks have failed::

  zpool status
  zpool status -x

Use the zpool-replace_ command to replace a failed disk, for example::

  zpool replace <pool-name> sde sde

Hot spare disks will **not** be added to the VDEV to replace a failed drive by default.
You MUST enable this feature.
Set the ``autoreplace`` feature to on.
Use ``zpool set autoreplace=on <pool-name>`` as an example.

.. _zpool-status: https://openzfs.github.io/openzfs-docs/man/8/zpool-status.8.html
.. _zpool-replace: https://openzfs.github.io/openzfs-docs/man/8/zpool-replace.8.html

Disk quotas for ZFS
======================

From the Best_practices_ page:

* Keep ZFS_ pool capacity under 80% for best performance.
  Due to the copy-on-write nature of ZFS_, the filesystem gets heavily fragmented.

Read the zfs-userspace_ manual page to display space and quotas of a ZFS dataset.
We assume a ZFS filesystem ``<pool-name>`` and a specific user's name ``<username>`` in the examples below.

Define a user's disk quota ``userquota`` and number-of-files quota ``userobjquota``::

  zfs set userquota@<username>=1TB userobjquota@<username>=1M <pool-name>

Unfortunately, the OpenZFS_ has no **default user quota** option.
This is only available in the Oracle_Solaris_ZFS_ implementation,
so with Linux OpenZFS_ you must set disk quotas individually for each user.

View the user disk usage and quotas::

  zfs userspace <pool-name>
  zfs userspace <pool-name> -p
  zfs userspace <pool-name> -H -p -o name,quota,used,objquota,objused

The ``-p`` prints parseable numbers, the ``-H`` omits the heading.
The ``-o`` displays only specific columns, this could be used to calculate *quota warnings*.

.. _zfs-userspace: https://openzfs.github.io/openzfs-docs/man/8/zfs-userspace.8.html
.. _Oracle_Solaris_ZFS: https://docs.oracle.com/cd/E23824_01/html/821-1448/zfsover-2.html

NFS sharing ZFS file systems
================================

The zfsprops_ manual page explains about the sharenfs_ option:

* A file system with a sharenfs_ property of **off** is managed with the exportfs_ command and entries in the /etc/ exports_ file.
  Otherwise, the file system is automatically shared and unshared with the ``zfs share`` and ``zfs unshare`` commands.

Alternatively to the exports_ file, use the zfs_ command to set or list NFS shares like in this example::

  zfs set sharenfs='rw=192.168.122.203' pool1/fs1
  zfs get sharenfs pool1/fs1

.. _sharenfs: https://openzfs.github.io/openzfs-docs/man/7/zfsprops.7.html#sharenfs
.. _zfsprops: https://openzfs.github.io/openzfs-docs/man/7/zfsprops.7.html
.. _exports: https://linux.die.net/man/5/exports
.. _exportfs: https://linux.die.net/man/8/exportfs

ZFS quotas over NFS
-------------------

The quota tools for Linux has absolutely no knowledge about ZFS_ quotas, nor does rquotad_, and hence clients mounting via NFS are also unable to obtain this information.
See a hack at https://aaronsplace.co.uk/blog/2019-02-12-zfsonline-nfs-quota.html

.. _rquotad: https://linux.die.net/man/8/rpc.rquotad
