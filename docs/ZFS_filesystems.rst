.. _ZFS_filesystems:

===============================================
ZFS filesystems quick configuration guide
===============================================

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

**NOTICE:** Aaron_Toponce_ ’s documentation is apparently not available any longer since early 2024!!
You may find a ZFS_web_archive_ copy of this documentation.

* Getting_Started_ with ZFS_ including an RHEL-based-distro_ guide.

* First time OpenZFS users are encouraged to check out Aaron_Toponce_ ’s excellent documentation.

* Best_practices_ and caveats.

* OpenZFS_Newcomers_ documentation and FAQ_.

* `ZFS Basic Concepts <https://openzfs.github.io/openzfs-docs/Basic%20Concepts/index.html>`_.

* `ZFS man-pages <https://openzfs.github.io/openzfs-docs/man/index.html>`_.

* `ZFS mailing lists <https://github.com/openzfs/openzfs-docs/blob/master/docs/Project%20and%20Community/Mailing%20Lists.rst>`_.

* Lustre_ and ZFS_:

  - Lustre_ uses ZFS_, see https://wiki.lustre.org/ZFS.
  - A `ZFS setup for Lustre <https://github.com/ucphhpc/storage/blob/main/zfs/docs/zfs.rst>`_.
  - A `JBOD Setup <https://github.com/ucphhpc/storage/blob/main/jbod/doc/jbod.rst>`_ page.

* zpool_concepts_ overview of ZFS_ storage pools.

* `ZFS 101—Understanding ZFS storage and performance <https://arstechnica.com/information-technology/2020/05/zfs-101-understanding-zfs-storage-and-performance/>`_
  and `ZFS fans, rejoice—RAIDz expansion will be a thing very soon <https://arstechnica.com/gadgets/2021/06/raidz-expansion-code-lands-in-openzfs-master/>`_.

* ZFS_checksums_ are a key feature of ZFS_ and an important differentiator for ZFS_ over other RAID implementations and filesystems. 

.. _Getting_Started: https://openzfs.github.io/openzfs-docs/Getting%20Started/index.html
.. _RHEL-based-distro: https://openzfs.github.io/openzfs-docs/Getting%20Started/RHEL-based%20distro/index.html
.. _Aaron_Toponce: https://pthree.org/2012/12/04/zfs-administration-part-i-vdevs/
.. _ZFS_web_archive: https://web.archive.org/web/20230904234829/https://pthree.org/2012/04/17/install-zfs-on-debian-gnulinux/
.. _Best_practices: https://pthree.org/2012/12/13/zfs-administration-part-viii-zpool-best-practices-and-caveats/
.. _OpenZFS_Newcomers: https://openzfs.org/wiki/Newcomers
.. _Lustre: https://wiki.lustre.org/Main_Page
.. _FAQ: https://openzfs.github.io/openzfs-docs/Project%20and%20Community/FAQ.html
.. _ZFS_checksums: https://openzfs.github.io/openzfs-docs/Basic%20Concepts/Checksums.html
.. _zpool_concepts: https://openzfs.github.io/openzfs-docs/man/master/7/zpoolconcepts.7.html

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

Then activate the ZFS_ kernel module::

  /sbin/modprobe zfs

The alternative *kABI-tracking kmod* installation method may break the ZFS_on_Linux_ software after kernel upgrades.

.. _DKMS: https://en.wikipedia.org/wiki/Dynamic_Kernel_Module_Support
.. _EL8: https://en.wikipedia.org/wiki/Red_Hat_Enterprise_Linux_derivatives

Ansible management of ZFS
==============================

See the page on :ref:`Ansible_configuration`.
There are Ansible_ modules for ZFS_ management:

* https://docs.ansible.com/ansible/2.9/modules/zfs_module.html
* Additional ZFS_ modules are found at https://docs.ansible.com/ansible/latest/collections/community/general/

There does not seem to be any module for zpool_ management, however.

.. _Ansible: https://www.ansible.com/

Identifying disks in the system
=================================

The disks in the system must be identified.
Please read the section :ref:`list-disks` below.

.. _list-HPE-disks:

List HPE server's disks
-----------------------------

If using a HPE HBA controller, the disks in the system can be displayed using the ``ssacli`` command from the *ssacli* RPM package.
See the :ref:`hpe_proliant_smartarray` page.

Example usage may be::

  $ /usr/sbin/ssacli
  => controller all show status
  => ctrl slot=1 pd all show status
  => ctrl slot=1 physicaldrive 2I:1:29 show detail

  Smart HBA H240 in Slot 1 (HBA Mode)

   HBA Drives

      physicaldrive 2I:1:29
         Port: 2I
         Box: 1
         Bay: 29
         Status: OK
         Drive Type: HBA Mode Drive
         Interface Type: SAS
         Size: 6 TB
         Drive exposed to OS: True
         Logical/Physical Block Size: 512/512
         Rotational Speed: 7200
         Firmware Revision: HPD7
         Serial Number: 1EK2RLEJ
         WWID: 5000CCA232AE1049
         Model: HP      MB6000FEDAU
         .....
         Disk Name: /dev/sdac

Here you can read the **disk name**, serial number etc.,
and compare disk names with lists from ``lsblk`` and ``lsscsi`` as shown above as well as ``zpool status``.

If a replacement disk is hidden from the OS, it may be because it was previously attached to a RAID adapter,
see https://serverfault.com/questions/1142870/hp-smart-array-p812-hba-mode-masked-drives
This can me modified like in this example::

  $ /usr/sbin/ssacli
  => ctrl slot=1 physicaldrive 2I:1:29 modify clearconfigdata

Trying out ZFS
====================

Aaron_Toponce_ 's page has some initial examples.

Create a simple zpool_ named *tank* with 4 unused drives (wwn-0x5000cca232ae2514 wwn-0x5000cca232aaef30 wwn-0x5000cca232adc8ac wwn-0x5000cca232add4cc)::

  zpool create tank wwn-0x5000cca232ae2514 wwn-0x5000cca232aaef30 wwn-0x5000cca232adc8ac wwn-0x5000cca232add4cc
  zpool status tank
  df -Ph /tank

Define the mount point for the dataset by adding this option::

  -m <mountpoint>

A mirrored pool where all data are mirrored 4 times::

  zpool create tank mirror wwn-0x5000cca232ae2514 wwn-0x5000cca232aaef30 wwn-0x5000cca232adc8ac wwn-0x5000cca232add4cc

A RAID 0+1 pool with 2+2 disks::

  zpool create tank mirror wwn-0x5000cca232ae2514 wwn-0x5000cca232aaef30 mirror wwn-0x5000cca232adc8ac wwn-0x5000cca232add4cc 

.. _zpool: https://openzfs.github.io/openzfs-docs/man/8/zpool.8.html

Destroy the testing zpool_ created above with zpool-destroy_::

  zpool destroy tank

**WARNING:** The zpool-destroy_ command will **destroy your ZFS pool without any warnings!!**.

.. _zpool-destroy: https://openzfs.github.io/openzfs-docs/man/master/8/zpool-destroy.8.html

Configuring ZFS
===================

The sections below describe how we have configured ZFS_.

For ZFS_ usage it is recommended to use the permanent hardware-based WWN_ names in stead of the Linux disk device names which are changeable.
You should make a record of the above mapping of WWN_ names to Linux disk device names.

.. _list-disks:

List disks in the system
---------------------------

First identify the disk device WWN_ names and the corresponding `/dev/sd...` device names::

  $ ls -l /dev/disk/by-id/wwn* | sed /part/d | awk '{print $9 " is disk " $11}' | sort -k 4
  /dev/disk/by-id/wwn-0x600508b1001cf4b3e98de44628d4583c is disk ../../sda
  ...

or use one of the following commands::

  lsblk
  lsscsi --wwn --size

For ZFS_ usage it is recommended to use the permanent hardware-based WWN_ names in stead of the Linux disk device names which are changeable.
You should make a record of the above mapping of WWN_ names to Linux disk device names.

Create RAIDZ disks
------------------------

Read the zpool_concepts_ page about VDEV_ devices, Hot_spare_ etc.

To setup a RAIDZ_ pool ``<poolname>`` with RAIDZ-1, we use zpool-create_ with the "raidz1" VDEV_, for example::

  zpool create <poolname> raidz1 wwn-0x5000cca232ae2514 wwn-0x5000cca232aaef30 wwn-0x5000cca232adc8ac 

The recommended disk naming with WWN_ names
must include the ``wwn-`` string before the disks' WWN_ names, for example:::

  zpool create <poolname> raidz1 wwn-0x5000c500ec6e2b9f wwn-0x5000c500f294ad3f wwn-0x5000c500f29d1a3b

To setup a RAIDZ_ pool with RAIDZ-2, we use the "raidz2" VDEV_::

  zpool create <poolname> raidz2 wwn-0x5000cca232ae2514 wwn-0x5000cca232aaef30 wwn-0x5000cca232adc8ac wwn-0x5000cca232add4cc

You can also create a pool with multiple VDEV_ devices, so that each VDEV_ doesn't contain too many physical disks,
for example::

  zpool create <poolname>   raidz2 wwn-0x5000cca232ae2514 wwn-0x5000cca232aaef30 wwn-0x5000cca232adc8ac wwn-0x5000cca232add4cc   raidz2 wwn-0x5000cca232add7e0 wwn-0x5000cca232ae3878 wwn-0x5000cca232ae0c14 wwn-0x5000cca232aa1dec

or add a new VDEV_ device with zpool-add_ to an existing pool::

  zpool add <poolname>   raidz2 wwn-0x5000cca232add7e0 wwn-0x5000cca232ae3878 wwn-0x5000cca232ae0c14 wwn-0x5000cca232aa1dec

You may even designate one or more Hot_spare_ disks to the pool, for example a single spare disk ``sdm``::

  zpool create <poolname>   raidz2 wwn-0x5000cca232ae2514 wwn-0x5000cca232aaef30 wwn-0x5000cca232adc8ac wwn-0x5000cca232add4cc   raidz2 wwn-0x5000cca232add7e0 wwn-0x5000cca232ae3878 wwn-0x5000cca232ae0c14 wwn-0x5000cca232aa1dec   spare sdm

Check the status of the pools::

  zpool status

.. _zpool-create: https://openzfs.github.io/openzfs-docs/man/master/8/zpool-create.8.html
.. _zpool-add: https://openzfs.github.io/openzfs-docs/man/master/8/zpool-add.8.html
.. _zpool-set: https://openzfs.github.io/openzfs-docs/man/master/8/zpool-set.8.html
.. _RAIDZ: https://www.raidz-calculator.com/raidz-types-reference.aspx
.. _VDEV: https://www.45drives.com/community/articles/how-zfs-organizes-its-data/
.. _Hot_spare: https://en.wikipedia.org/wiki/Hot_spare

Adding disks for an SLOG
------------------------------

Read about the *Separate Intent Logging Device* (SLOG) in the *ZFS Intent Log* (ZIL_) page.
The disks should be as fast as possible, such as NVMe or SSD.

To correlate a namespace to a disk device use one of the following commands::

  lsblk
  lsscsi --wwn --size

Use ``/dev/disk/by-id/*`` disk names with ZFS_ in stead of ``/dev/sd*`` which could become renamed.

.. _ZIL: https://pthree.org/2012/12/06/zfs-administration-part-iii-the-zfs-intent-log/

Add SLOG and ZIL disks
...........................

This section shows how to configure an L2ARC_cache_ on 2 disk devices.

To add 2 disks, for example ``sdb`` and ``sdc``, to the SLOG, first identify the device WWN_ names::

  ls -l /dev/disk/by-id/* | egrep 'sdb|sdc' | grep wwn

Assume that the 2 disks ``wwn-0x58ce38ee201fe7b5`` (sdb) and ``wwn-0x600508b1001c45bf78142b67cda9c82b`` (sdc) will be used.
First partition the disks::

  parted /dev/sdb unit s mklabel gpt mkpart primary 2048 4G mkpart primary 4G 120G
  parted /dev/sdb unit s mklabel gpt mkpart primary 2048 4G mkpart primary 4G 120G

Note: Perhaps it is necessary to use the ``parted`` command line and make individual commands like::

  parted /dev/sdb
  (parted) unit s 
  (parted) mklabel gpt
  (parted) mkpart primary 2048 4G 
  (parted) mkpart primary 4G 120G
  (parted) print
  (parted) quit

Use ``/dev/disk/by-id/*`` disk names with ZFS_ in stead of ``/dev/sd*`` which could become renamed.

The disks and their partitions ``partN`` may be listed as in this example::

  /dev/disk/by-id/wwn-0x600508b1001c5db0139e52b3964d02ee -> ../../sdb
  /dev/disk/by-id/wwn-0x600508b1001c5db0139e52b3964d02ee-part1 -> ../../sdb1
  /dev/disk/by-id/wwn-0x600508b1001c5db0139e52b3964d02ee-part2 -> ../../sdb2
  /dev/disk/by-id/wwn-0x600508b1001c45bf78142b67cda9c82b -> ../../sdc
  /dev/disk/by-id/wwn-0x600508b1001c45bf78142b67cda9c82b-part1 -> ../../sdc1
  /dev/disk/by-id/wwn-0x600508b1001c45bf78142b67cda9c82b-part2 -> ../../sdc2

When the partitions have been created, add the **disk partitions 1 and 2** as a ZFS_ mirrored log and cache, respectively::

  zpool add <pool-name> log mirror /dev/disk/by-id/wwn-<name>-part1 /dev/disk/by-id/wwn-<name>-part1 cache /dev/disk/by-id/wwn-<name>-part2 /dev/disk/by-id/wwn-<name>-part2

where the WWN_ names found above must be used.

Cache and mirror devices can be removed, if necessary, by the zpool-remove_ command, for example::

  zpool remove <pool-name> <mirror>
  zpool remove <pool-name> /dev/disk/by-id/wwn-<name>-part2

where the disks are listed by the zpool-status_ command.

.. _zpool-remove: https://openzfs.github.io/openzfs-docs/man/8/zpool-remove.8.html
.. _L2ARC_cache: https://pthree.org/2012/12/07/zfs-administration-part-iv-the-adjustable-replacement-cache/
.. _WWN: https://en.wikipedia.org/wiki/World_Wide_Name

Add SLOG and ZIL on Optane NVDIMM persistent memory
......................................................

Setting up NVDIMM persistent memory is described in :ref:`NVDIMM_Setup`.
Install thse packages::

  dnf install ndctl ipmctl

Display NVDIMM devices by::

  ipmctl show -dimm

This section show how to configure an L2ARC_cache_
using NVDIMM_ 3D_XPoint_ known as *Intel Optane* persistent memory DIMM modules.

Partition the NVDIMM_ disks::

  parted /dev/pmem0 unit s mklabel gpt mkpart primary 2048 4G mkpart primary 4G 120G
  parted /dev/pmem1 unit s mklabel gpt mkpart primary 2048 4G mkpart primary 4G 120G

and then add the **disk partitions 1 and 2** as ZFS_ cache and log::

  zpool add <pool-name> log mirror /dev/pmem0p1 /dev/pmem1p1 cache /dev/pmem0p2 /dev/pmem1p2 

.. _NVDIMM: https://en.wikipedia.org/wiki/NVDIMM
.. _3D_XPoint: https://en.wikipedia.org/wiki/3D_XPoint
.. _PMem: https://docs.pmem.io/persistent-memory/

ARC RAM cache
-------------

**Adaptive Replacement Cache** (ARC_) is a page replacement algorithm with better performance than LRU (least recently used).
This is accomplished by keeping track of both frequently used and recently used pages plus a recent eviction history for both.

ZFS automatically uses RAM memory for ARC_ caching, and by default 50% of RAM memory is used for ARC_ caching.
There is also a secondary ARC_ cache called L2ARC_cache_ (**Level II Adaptive Replacement Cache**) using fast persistent storage.

The ``arc_summary`` command prints statistics on the ZFS_ ARC_ Cache and other information, for example::

  ARC size (current):                                  99.6 %  125.0 GiB
        Target size (adaptive):                       100.0 %  125.4 GiB
        Min size (hard limit):                          6.2 %    7.8 GiB
        Max size (high water):                           16:1  125.4 GiB
        Most Frequently Used (MFU) cache size:          8.6 %   10.4 GiB
        Most Recently Used (MRU) cache size:           91.4 %  109.6 GiB
        Metadata cache size (hard limit):              75.0 %   94.1 GiB
        Metadata cache size (current):                  7.4 %    7.0 GiB
        Dnode cache size (hard limit):                 10.0 %    9.4 GiB
        Dnode cache size (current):                    26.6 %    2.5 GiB
  ...
  L2ARC size (adaptive):                                         283.9 GiB
        Compressed:                                    78.5 %  222.8 GiB
        Header size:                                  < 0.1 %  122.3 MiB
        MFU allocated size:                             8.7 %   19.5 GiB
        MRU allocated size:                            91.1 %  203.0 GiB
        Prefetch allocated size:                        0.2 %  349.8 MiB
        Data (buffer content) allocated size:          99.9 %  222.7 GiB
        Metadata (buffer content) allocated size:       0.1 %  161.5 MiB
  ...

The arcstat_ command reports ZFS ARC_ and L2ARC_cache_ statistics.

.. _ARC: https://en.wikipedia.org/wiki/Adaptive_replacement_cache
.. _arcstat: https://openzfs.github.io/openzfs-docs/man/master/1/arcstat.1.html

ZFS pool capacity should be under 80%
-------------------------------------------

From the Best_practices_ page:

* Keep ZFS_ pool capacity under 80% for best performance.
  Due to the copy-on-write nature of ZFS_, the filesystem gets heavily fragmented.

* Email reports of capacity at least monthly.

Use this command to view the ZFS_ pool capacity::

  zpool list
  zpool list -H -o name,capacity

This crontab job for Monday mornings might be useful::

  # ZFS list capacity
  0 6 * * 1 /sbin/zpool list


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

Create ZFS filesystems
---------------------------

You can create multiple separate filesystems within a ZFS_ pool, for example::

  zfs create -o mountpoint=/u/test1 zfspool1/test1

ZFS_ filesystems can be unmounted and mounted manually by zfs_mount_ commands::

  zfs unmount ...
  zfs mount ...

.. _zfs_mount: https://openzfs.github.io/openzfs-docs/man/master/8/zfs-mount.8.html

ZFS Snapshots and clones
------------------------

zfs-snapshot_ is similar to a Linux LVM snapshot, see Snapshots_and_clones_.

You can list snapshots by two methods::

  zfs list -t all
  cd <mountpoint>/.zfs ; ls -l

You can access the files in a snapshot by mounting it, for example::

  mount -t zfs zfstest/zfstest@finbul1-20230131080810 /mnt

The files will be visible in ``/mnt``.
Remember to unmount ``/mnt`` afterwards.

To destroy a snapshot use zfs-destroy_::

  zfs destroy [-Rdnprv] filesystem|volume@snap[%snap[,snap[%snap]]]

**WARNING:** The zfs-destroy_ command will **destroy your ZFS volume without any warnings!!**.

It is recommended to create a zfs-snapshot_ and use zfs-hold_ to prevent zfs-destroy_ from destroying accidentally, 
see `prevent dataset/zvol from accidental destroy  <https://www.reddit.com/r/zfs/comments/suh9nx/prevent_datasetzvol_from_accidental_destroy/>`_.

For example create a snapshot and hold it::

  zfs snapshot tank@snapshot1
  zfs list -t snapshot
  zfs hold for_safety tank@snapshot1
  zfs holds tank@snapshot1

.. _zfs-hold: https://openzfs.github.io/openzfs-docs/man/master/8/zfs-hold.8.html

General snapshot advice:

* Snapshot frequently and regularly.
* Snapshots are cheap, and can keep a plethora of file versions over time.
* Consider using something like the zfs-auto-snapshot_ script.

.. _zfs-snapshot: https://openzfs.github.io/openzfs-docs/man/master/8/zfs-snapshot.8.html
.. _zfs-destroy: https://openzfs.github.io/openzfs-docs/man/master/8/zfs-destroy.8.html
.. _Snapshots_and_clones: https://pthree.org/2012/12/19/zfs-administration-part-xii-snapshots-and-clones/
.. _zfs-auto-snapshot: https://github.com/zfsonlinux/zfs-auto-snapshot

ZFS backups
--------------

Backup of ZFS_ filesystems to a remote storage may be done by Sending_and_receiving_filesystems_.

A ZFS_ snapshot can be sent to a remote system like this example::

  zfs send tank/test@tuesday | ssh user@server.example.com "zfs receive pool/test"

There are several tools for performing such backups:

* zfs-autobackup_ creates ZFS_ snapshots on a *source* machine and then replicates those snapshots to a *target* machine via SSH.

* https://serverfault.com/questions/842531/how-to-perform-incremental-continuous-backups-of-zfs-pool

.. _Sending_and_receiving_filesystems: https://pthree.org/2012/12/20/zfs-administration-part-xiii-sending-and-receiving-filesystems/

zfs-autobackup
..............

See the zfs-autobackup_ `Getting Started <https://github.com/psy0rz/zfs_autobackup/wiki>`_ Wiki page.

On the remote source machine, we set the ``autobackup:offsite1`` zfs property to true as follows::

  [root@remote ~]# zfs set autobackup:offsite1=true <poolname>
  [root@remote ~]# zfs get -t filesystem,volume autobackup:offsite1

Running a *pull backup* from the remote host::

  zfs-autobackup -v --ssh-source <remote> offsite1 <poolname>

Since the path to zfs-autobackup_ is ``/usr/local/bin`` and ZFS_ commands are in ``/usr/sbin``,
you must add these paths when running crontab jobs, for example::

  0 4 * * * PATH=$PATH:/usr/sbin:/usr/local/bin; zfs-autobackup args...

It is convenient to list all snapshots created by zfs-autobackup_::

  zfs list -t all

You can mount a snapshot as shown above.

There is a zfs-autobackup_ `troubleshooting page <https://github.com/psy0rz/zfs_autobackup/wiki/Problems>`_.
We have seen the error::

  cannot receive incremental stream: destination has been modified since most recent snapshot

which was resolved by zfs_rollback_::

  zfs rollback <problem-snapshot-name>

.. _zfs-autobackup: https://github.com/psy0rz/zfs_autobackup
.. _zfs_rollback: https://openzfs.github.io/openzfs-docs/man/8/zfs-rollback.8.html

Useful ZFS commands
-------------------

List ZFS_ filesystems and their properties::

  zfs list
  zpool list
  zpool status <pool-name>
  zpool get all <pool-name>
  mount -l -t zfs

See the sub-command manual pages for details (for example ``man zpool-list``).

Display logical I/O statistics for ZFS_ storage pools with zpool-iostat_::

  zpool iostat -v

Get and set a mountpoint::

  zfs get mountpoint <pool-name>
  zfs set mountpoint=/u/zfs <pool-name>

.. _zpool-iostat: https://openzfs.github.io/openzfs-docs/man/8/zpool-iostat.8.html

E-mail notifications
--------------------------

Using the *ZFS Event Daemon* (see ZED_ or ``man zed``),
ZFS_ can send E-mail messages when zpool-events_ occur.
Check the status of ZED_ by::

  systemctl status zed

The ZED_ configuration file ``/etc/zfs/zed.d/zed.rc`` defines variables such as the
Email address of the zpool administrator for receipt of notifications;
multiple addresses can be specified if they are delimited by whitespace::

  ZED_EMAIL_ADDR="root"

You should change ``root`` into a system administrator E-mail address, 
otherwise the domain ``root@localhost.localdomain`` will be used.
Perhaps you need to do ``systemctl restart zed`` after changing the ``zed.rc`` file(?).

.. _ZED: https://openzfs.github.io/openzfs-docs/man/8/zed.8.html
.. _zpool-events: https://openzfs.github.io/openzfs-docs/man/8/zpool-events.8.html

Scrub and Resilver disks
--------------------------

With ZFS_ on Linux, detecting and correcting silent data errors is done through scrubbing the disks,
see the Scrub_and_Resilver_ or Resilver_ pages.

.. _Scrub_and_Resilver: https://web.archive.org/web/20230828015540/https://pthree.org/2012/12/11/zfs-administration-part-vi-scrub-and-resilver/

Scrubbing can be made regularly with crontab, for example monthly::

  0 2 1 * * /sbin/zpool scrub <pool-name>

or alternatively on machines using Systemd_, scrub timers can be enabled on per-pool basis.
See the ``systemd.timer(5)`` manual page.
Weekly and monthly timer units are provided::

  systemctl enable zfs-scrub-weekly@<pool-name>.timer --now
  systemctl enable zfs-scrub-monthly@<pool-name>.timer --now

.. _Systemd: https://en.wikipedia.org/wiki/Systemd
.. _Resilver: https://docs.oracle.com/cd/E19253-01/819-5461/gbcus/index.html

Hot spare disks
-------------------

Hot spare disks will **not** be added to the VDEV_ to replace a failed drive by default.
You MUST enable this feature.
Set the zpool-set_ ``autoreplace`` feature to on, for example::

  zpool set autoreplace=on <pool-name>

Replacing defective disks
-------------------------------

Detecting broken disks is explained in the Scrub_and_Resilver_ page.
Check the zpool-status_ if any disks have failed::

  zpool status
  zpool status -x       # Only pools with errors
  zpool status -e       # Only VDEVs with errors
  zpool status -L       # Display real paths for vdevs resolving all symbolic links
  zpool status -P       # Display full paths for vdevs

Replacing disks can come with big problems, see 
`How to force ZFS to replace a failed drive in place <https://alchemycs.com/2019/05/how-to-force-zfs-to-replace-a-failed-drive-in-place/>`_.

The RHEL page `How to rescan the SCSI bus to add or remove a SCSI device without rebooting the computer  <https://access.redhat.com/solutions/3941>`_
has useful information about ``Adding a Storage Device or a Path``.
You may scan the system for disk changes using ``/usr/bin/rescan-scsi-bus.sh`` from the `sg3_utils` package.
Unfortunately, it may sometimes be necessary to reboot the server so that the OS will discover the replaced ``/dev/sd???`` disk device.

Identify the broken disk
...........................

Identify the broken (``REMOVED``) ZFS_ drive's WWN_ name::

  zpool status | grep REMOVED
    wwn-0x5000cca232ae3fe0    REMOVED      0     0     0

The difficult part is identifying exactly the physical disk slot in the server corresponding to the WWN_ name.
Please read the section :ref:`list-disks` above, and :ref:`list-HPE-disks` for HPE Proliant servers in particular.
For example, the disk may be shown as (omit the ``wwn-`` part of the name)::

  lsscsi --wwn --size | grep 0x5000cca232ae3fe0
  [1:0:54:0] disk HP MB6000FEDAU HPD7 0x5000cca232ae3fe0 /dev/sdbc 6.00TB

Unfortunately, the device name ``/dev/sdbc`` or the bus-id ``[1:0:54:0]`` do not 
identify the slot in the disk cage unambiguously.
You have to locate the WWN_ name or device name in the disk controller to identify the disk slot,
for example :ref:`list-HPE-disks` may show `WWID`::

  physicaldrive 1I:1:55
    Port: 1I
    Box: 1
    Bay: 55
    ...
    Serial Number: 1EK2USPH
    WWID: 5000CCA232AE3FE1
    Model: HP      MB6000FEDAU
    ...
    Disk Name: /dev/sdbc 

**NOTE:** The WWN_ name of a disk can differ on the last digit, here 0 and 1,
because the disk may have multiple ports with different WWN_ names,
so when searching for WWN_ you should omit the last digit.

In this example the ``Disk bay: 55`` contains the defective disk,
and the disk slot should be identifiable on the disk cage cabinet.

Some storage systems allow you to **blink** the disk LED for easy identification.
If the disk is completely dead, blinking the two disks left and right allows you to identify the disk in the middle.

Replace the disk drive
..........................

Obtain a new disk drive of the same size etc. as the defective drive.

**Important:** Take a photo of the disk drive label which should display the WWN_ name, serial number, and size,
and record this information for reference.

Remove the defective drive from the disk slot.
**Double check** the WWN_ name, serial number, and size of the removed drive and compare with the above ``REMOVED`` drive.

Now use the zpool-replace_ command to replace a failed ZFS_ disk,
for example the old disk ``wwn-0x5000cca232ae3fe0``, by a new one::

  zpool replace <pool-name> wwn-0x5000cca232ae3fe0(old) wwn-0x5000cca232af661c(new)

The ``-f`` flag may possibly be required in case of errors such as ``invalid vdev specification``::

  zpool replace -f <pool-name> wwn-0x5000cca232ae3fe0(old) wwn-0x5000cca232af661c(new)

Now you can see the disk Resilver_ taking place::

  zpool status
  ...
  replacing-0                 DEGRADED     0     0     0
   wwn-0x5000cca232ae3fe0    REMOVED      0     0     0
   wwn-0x5000cca232af661c    ONLINE       0     0     0  (resilvering)
  ...

.. _zpool-status: https://openzfs.github.io/openzfs-docs/man/8/zpool-status.8.html
.. _zpool-replace: https://openzfs.github.io/openzfs-docs/man/8/zpool-replace.8.html

ZFS troubleshooting
-------------------------

There is a useful Troubleshooting_ page which includes a discussion of ZFS_events_.
Some useful commands are::

  zpool events -v
  zpool history

If a normal user, and also the daily ``logwatch`` scripts, tries to execute ``zpool status`` an error message may appear::

  Permission denied the ZFS utilities must be run as root

This seems to be a Systemd_ issue, see 
`permissions issues with openzfs #28653 <https://github.com/systemd/systemd/issues/28653>`_.
There seems to be a fix in
`Udev vs tmpfiles take 2 #28732 <https://github.com/systemd/systemd/pull/28732>`_,
however, this has not been tested on EL8 yet.

.. _Troubleshooting: https://openzfs.github.io/openzfs-docs/Basic%20Concepts/Troubleshooting.html
.. _ZFS_events: https://openzfs.github.io/openzfs-docs/Basic%20Concepts/Troubleshooting.html#zfs-events

Disk quotas for ZFS
======================

Read the zfs-userspace_ manual page to display space and quotas of a ZFS_ dataset.
We assume a ZFS_ filesystem ``<pool-name>`` and a specific user's name ``<username>`` in the examples below.

Define a user's disk quota ``userquota`` and number-of-files quota ``userobjquota``::

  zfs set userquota@<username>=1TB userobjquota@<username>=1M <pool-name>

Using a quota value of ``none`` will remove the quota.

We have written some Tools_for_managing_ZFS_disk_quotas_ providing,
for example, commands similar to the standard Linux commands ``repquota`` and ``quota``.

.. _Tools_for_managing_ZFS_disk_quotas: https://github.com/OleHolmNielsen/ZFS_tools

The superuser can view the user disk usage and quotas, see the zfs-userspace_ manual page::

  zfs userspace filesystem|snapshot|path|mountpoint
  zfs userspace -p filesystem|snapshot|path|mountpoint
  zfs userspace -H -p -o name,quota,used,objquota,objused filesystem|snapshot|path|mountpoint

The ``-p`` prints parseable numbers, the ``-H`` omits the heading.
The ``-o`` displays only specific columns, this could be used to calculate *quota warnings*.

Normal users are not allowed to read quotas with the above commands.
The following command allows a normal user to print disk usage and quotas::

  /usr/sbin/zfs get userquota@$USER,userused@$USER,userobjquota@$USER,userobjused@$USER <pool-name>

.. _zfs-userspace: https://openzfs.github.io/openzfs-docs/man/8/zfs-userspace.8.html
.. _Oracle_Solaris_ZFS: https://docs.oracle.com/cd/E23824_01/html/821-1448/zfsover-2.html

Default quotas
------------------

Unfortunately, the OpenZFS_ has no **default user quota** option,
this is only available in the Oracle_Solaris_ZFS_ implementation, see the defaultuserquota_ page::

  zfs set defaultuserquota=30gb <pool-name>

So with Linux OpenZFS_ you must set disk quotas individually for each user as shown above.

.. _defaultuserquota: https://docs.oracle.com/cd/E53394_01/html/E54801/gazvb.html#SVZFSgpwey

NFS sharing ZFS file systems
================================

The zfsprops_ manual page explains about the NFS_ sharenfs_ option:

* A file system with a sharenfs_ property of **off** is managed with the exportfs_ command and entries in the /etc/ exports_ file.
  Otherwise, the file system is automatically shared and unshared with the ``zfs share`` and ``zfs unshare`` commands.

Alternatively to the exports_ file, use the ``zfs set/get sharenfs`` command to set or list the sharenfs_ property like in this example::

  zfs set sharenfs='rw=192.168.122.203' pool1/fs1
  zfs get sharenfs pool1/fs1

ZFS_ will update its ``/etc/zfs/exports`` file automatically.
Never edit this file directly! 

There are some discussions on NFS_ with ZFS:

* https://klarasystems.com/articles/nfs-shares-with-zfs/
* https://svennd.be/sharenfs-on-zfs-and-mounting-with-autofs/
* https://blog.programster.org/sharing-zfs-datasets-via-nfs

.. _NFS: https://en.wikipedia.org/wiki/Network_File_System
.. _sharenfs: https://openzfs.github.io/openzfs-docs/man/7/zfsprops.7.html#sharenfs
.. _zfsprops: https://openzfs.github.io/openzfs-docs/man/7/zfsprops.7.html
.. _exports: https://linux.die.net/man/5/exports
.. _exportfs: https://linux.die.net/man/8/exportfs

NFS tuning
---------------

Make sure that a sufficient number of nfsd_ threads are started by configuring the ``/etc/nfs.conf`` file::

  threads=32

This number might be around the number of CPU cores in the server.
A ``systemctl restart nfs-server`` is required to update the parameters.

For optimizing the transfer of large files, increase the NFS_ read and write size in the NFS_ mount command on **NFS clients**,
see ``man 5 nfs``::

  rsize=32768,wsize=32768

Larger values (powers of 2, such as 131072) may also be tried.

See also `Optimizing Your NFS Filesystem <https://www.admin-magazine.com/HPC/Articles/Useful-NFS-Options-for-Tuning-and-Management>`_.

.. _nfsd: https://man7.org/linux/man-pages/man8/nfsd.8.html

ZFS quotas over NFS
-------------------

The quota tools for Linux has absolutely no knowledge about ZFS_ quotas, nor does rquotad_, and hence clients mounting via NFS_ are also unable to obtain this information.
See a hack at https://aaronsplace.co.uk/blog/2019-02-12-zfsonline-nfs-quota.html

.. _rquotad: https://linux.die.net/man/8/rpc.rquotad

Exporting and importing ZFS pools between systems
=====================================================

A ZFS_ storage pools can be explicitly exported to indicate that they are ready to be migrated. 
See also zpool_concepts_.

Use zpool_export_ to export a pool so that it can be moved between systems::

  zpool export <poolname>

On the new system, use zpool_import_ to list pools available for import::

  zpool import 

To import a specific pool::

  zpool import <poolname>

.. _zpool_export: https://openzfs.github.io/openzfs-docs/man/master/8/zpool-export.8.html
.. _zpool_import: https://openzfs.github.io/openzfs-docs/man/master/8/zpool-import.8.html
