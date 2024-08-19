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

List disks in the system
=================================

The disks in the system must be identified.
The following commands are useful for listing disk block devices::

  lsblk
  lsscsi --wwn --size

List HPE server's disks
-----------------------------

If using a HPE HBA controller, the disks in the system can be displayed using the ``ssacli`` command from the *ssacli* RPM package.
See the :ref:`hpe_proliant_smartarray` page.

Example usage is::

  $ /usr/sbin/ssacli
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

Configuring ZFS
===================

The sections below describe how we have configured ZFS_.

Create RAIDZ disks
------------------------

To setup a RAIDZ_ pool ``<poolname>`` with RAIDZ-1, we use zpool_ with the "raidz1" VDEV, for example::

  zpool create <poolname> raidz1 sde sdf sdg

To setup a RAIDZ_ pool with RAIDZ-2, we use the "raidz2" VDEV::

  zpool create <poolname> raidz2 sde sdf sdg sdh

.. _RAIDZ: https://www.raidz-calculator.com/raidz-types-reference.aspx

Adding disks for an SLOG
------------------------------

Read about the *Separate Intent Logging Device* (SLOG) in the *ZFS Intent Log* (ZIL_) page.
The disks should be as fast as possible, such as NVMe or SSD.

To correlate a namespace to a disk device use the following command::

  lsblk

Use ``/dev/disk/by-id/*`` disk names with ZFS_ in stead of ``/dev/sd*`` which could become renamed.

.. _ZIL: https://pthree.org/2012/12/06/zfs-administration-part-iii-the-zfs-intent-log/

Add SLOG and ZIL disks
...........................

This section shows how to configure an L2ARC_cache_ on 2 disk devices.

Assume that the 2 disks ``/dev/sdb`` and ``/dev/sdc`` will be used.
First partition the disks::

  parted /dev/sdb unit s mklabel gpt mkpart primary 2048 4G mkpart primary 4G 120G
  parted /dev/sdc unit s mklabel gpt mkpart primary 2048 4G mkpart primary 4G 120G

Note: Perhaps it is necessary to use the ``parted`` command line and make individual commands like::

  parted /dev/sdb
  (parted) unit s 
  (parted) mklabel gpt
  (parted) mkpart primary 2048 4G 
  (parted) mkpart primary 4G 120G
  (parted) print
  (parted) quit

Use ``/dev/disk/by-id/*`` disk names with ZFS_ in stead of ``/dev/sd*`` which could become renamed.

To add 2 disks, for example ``/dev/sdb`` and ``/dev/sdc``, to the SLOG, first identify the device WWN_ names::

  ls -l /dev/disk/by-id/* | egrep 'sdb|sdc' | grep wwn

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

ZFS_ filesystems can be unmounted and mounted manually by these commands::

  zfs unmount ...
  zfs mount ...

See ``man zfs-mount`` for usage of these commands.

ZFS Snapshots and clones
------------------------

ZFS_ snapshots (see ``man zfs-snapshot``) are similar to snapshots with Linux LVM, see Snapshots_and_clones_.

You can list snapshots by two methods::

  zfs list -t all
  cd <mountpoint>/.zfs ; ls -l

You can access the files in a snapshot by mounting it, for example::

  mount -t zfs zfstest/zfstest@finbul1-20230131080810 /mnt

The files will be visible in ``/mnt``.
Remember to unmount ``/mnt`` afterwards.

To destroy a snapshot::

  zfs destroy [-Rdnprv] filesystem|volume@snap[%snap[,snap[%snap]]]

see ``man zfs-destroy``.

General snapshot advice:

* Snapshot frequently and regularly.
* Snapshots are cheap, and can keep a plethora of file versions over time.
* Consider using something like the zfs-auto-snapshot_ script.

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

The RHEL page `How to rescan the SCSI bus to add or remove a SCSI device without rebooting the computer  <https://access.redhat.com/solutions/3941>`_
has useful information about ``Adding a Storage Device or a Path``.
You may scan the system for disk changes using ``/usr/bin/rescan-scsi-bus.sh`` from the `sg3_utils` package.
Unfortunately, it may sometimes be necessary to reboot the server so that the OS will discover the replaced ``/dev/sd???`` disk device.

Use the zpool-replace_ command to replace a failed disk, for example disk *sde*::

  zpool replace <pool-name> sde sde
  zpool replace -f <pool-name> sde sde

The ``-f`` flag may be required in case of errors such as ``invalid vdev specification``.

Hot spare disks will **not** be added to the VDEV to replace a failed drive by default.
You MUST enable this feature.
Set the ``autoreplace`` feature to on, for example::

  zpool set autoreplace=on <pool-name>

Replacing disks can come with big problems, see 
`How to force ZFS to replace a failed drive in place <https://alchemycs.com/2019/05/how-to-force-zfs-to-replace-a-failed-drive-in-place/>`_.

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
