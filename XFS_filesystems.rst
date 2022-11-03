.. _XFS_filesystems:

===============
XFS filesystems
===============

.. Contents::

The *XFS filesystem* may be used as an alternative to *ext3* when large disks (>1TB) and/or large files are to be used.
XFS filesystems can be up to 8 Exabytes in size.

XFS was created by Silicon Graphics in 1993 for their IRIX OS, but is available in Linux as well.
See the Wikipedia article on `XFS <http://en.wikipedia.org/wiki/XFS>`_.

XFS documentation
============================

There is an `XFS information page <http://xfs.org/>`_ containing an XFS_FAQ_.

.. _XFS_FAQ: http://xfs.org/index.php/XFS_FAQ

The developers at SGI have a *Developer Central Open Source* page at http://oss.sgi.com/projects/xfs/.

There are some useful remarks on the page http://www.mythtv.org/wiki/XFS_Filesystem.

XFS on CentOS
============================

XFS is included in the *CentOS Extras* repository.
Please read the `CentOS Known Issues <http://wiki.centos.org/Manuals/ReleaseNotes/CentOS5.4#head-29511ff6659f6463d444feb92326ed2232fc8c08>`_ regarding XFS restrictions.

You first have to install XFS packages::

  yum install xfsprogs

You create an XFS filesystem on a disk device by the command::

  mkfs.xfs

see *man mkfs.xfs*.

The commands to backup and restore XFS filesystems are installed by::

  yum install xfsdump

Label disk for large filesystems
==========================================

Before using the disk a suitable disk label must be created using the parted_ command.
We assume below that the disk device is named **/dev/sdb**.

Create an XFS_ primary partition (see the parted_ manual page) with a GPT_ label with an on the device::

  # parted /dev/sdb
   (parted) mklabel gpt          # Makes a "GPT" label permitting large filesystems 
   (parted) print
   (parted) mkpart primary xfs 0 100%   # Allocate 100% of the partition
   (parted) set 1 lvm on         # Set LVM flag
   (parted) quit

Here we have set the LVM_ flag on the partition.
The new disk partition no. 1 will be named **/dev/sdb1**.

.. _parted: https://www.gnu.org/software/parted/manual/parted.html
.. _GPT: https://en.wikipedia.org/wiki/GUID_Partition_Table

Test a disk with errors in disk label
=======================================================

If the disk label (as shown by ``parted``) has become missing or defective due to hardware errors, you can search the disk for backup partition tables.

Install this tool from EPEL::

  yum install testdisk

There is a testdisk_ homepage.

.. _testdisk: https://www.cgsecurity.org/wiki/TestDisk

Use LVM to control disks
============================

Normally the ``system-config-lvm`` tool is used to manage LVM_ disks and filesystems.
Unfortunately, this tool does not understand XFS_ filesystems, so we have to use manual LVM_ commands.

.. _LVM: https://en.wikipedia.org/wiki/Logical_Volume_Manager_(Linux)

Initialize the disk for LVM and create a new volume group::

  pvcreate /dev/sdc1
  vgcreate vgxfs /dev/sdc1

Now create an LVM_ logical volume using 100% of the disk space::

  lvcreate -n lvxfs -l 100%VG vgxfs

Now you have this logical volume available::

  # lvdisplay /dev/mapper/vgxfs-lvxfs
  --- Logical volume ---
  LV Name                /dev/vgxfs/lvxfs
  VG Name                vgxfs
  LV UUID                yKMgnS-Pe57-0MBV-fHmf-TBHY-mCAd-ZSsLh3
  LV Write Access        read/write
  LV Status              available
  # open                 0
  LV Size                6.82 TB
  Current LE             1788431
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:3

Adding LVM disks to the system
------------------------------

Useful tools for working with LVM disks added to a running system::

  pvscan - scan all disks for physical volumes
  pvdisplay - display attributes of a physical volume
  vgscan - scan all disks for volume groups and rebuild caches
  vgdisplay - display attributes of volume groups
  lvscan - scan (all disks) for logical volumes
  lvdisplay - display attributes of a logical volume

To activate an LVM volume that has been added to the system run::

  vgchange -a y

Display the available space on a physical volume::

  pvdisplay -s

Striping an LVM volume across multiple disks
--------------------------------------------

If you create a logical volume on multiple physical disks (or disk shelves on a RAID controller),
you can **stripe** the volume across disks for increased performance using the *lvcreate* flags *-i* and *-I* (see ``man lvcreate``).
For example, to stripe across 2 disks with stripe size 256 kbytes (must be a power of 2)::

  lvcreate -n lvxfs -l 100%VG vgxfs -i 2 -I 256

To display striping information about the LVM volumes in a volume group::

  lvs --segments vgxfs 

Create XFS filesystem
============================

If your disk is a multi-disk RAID device, please read the section on performance optimization for striped volumes below.
If you just have a simple disk or a mirrored disk, you can now create a filesystem on the new partition:: 

  # mkfs.xfs /dev/mapper/vgxfs-lvxfs
  meta-data=/dev/mapper/vgxfs-lvxfs isize=256    agcount=32, agsize=57229792 blks
           =                       sectsz=512   attr=0
  data     =                       bsize=4096   blocks=1831353344, imaxpct=25
           =                       sunit=0      swidth=0 blks, unwritten=1
  naming   =version 2              bsize=4096
  log      =internal log           bsize=4096   blocks=32768, version=1
           =                       sectsz=512   sunit=0 blks, lazy-count=0
  realtime =none                   extsz=4096   blocks=0, rtextents=0

Mount the filesystem::

  mkdir -p /u3/raid
  mount /dev/mapper/vgxfs-lvxfs /u3/raid

Checking an XFS filesystem
============================

You may have to check the sanity of an XFS file system::

  xfs_repair -n

Mount large XFS filesystems with inode64 option
=======================================================

XFS allocates inodes to reflect their on-disk location by default. 
However, because some 32-bit userspace applications are not compatible with inode numbers greater than 232, XFS will allocate all inodes in disk locations which result in 32-bit inode numbers. 
This can lead to decreased performance on very large filesystems (that is, larger than 2 terabytes), because inodes are skewed to the beginning of the block device, while data is skewed towards the end.
To address this, use the inode64 mount option. This option configures XFS to allocate inodes and data across the entire file system, which can improve performance::

  mount -o inode64 /dev/device /mount/point

See XFS_inode64_ and `8.2. Mounting an XFS File System <https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Storage_Administration_Guide/xfsmounting.html>`_.

Mounting with inode64 may be the solution, but then one cannot revert this mount option later for kernels < 2.6.35!

.. _XFS_inode64: http://xfs.org/index.php/XFS_FAQ#Q:_What_is_the_inode64_mount_option_for.3F

There are also some warnings about applications and NFS when using XFS_inode64_: https://hpc.uni.lu/blog/2014/xfs-and-inode64/

XFS performance optimization
============================

Dell has a Guide on the page `Dell HPC NFS Storage Solutions (NSS) <http://www.dell.com/us/enterprise/p/d/hpcc/storage-dell-nss.aspx>`_
which describes system performance tuning of a RHEL server with XFS filesystem.

On RHEL6 there is a utility `tuned <http://docs.redhat.com/docs/en-US/Red_Hat_Enterprise_Linux/6/html/Power_Management_Guide/Tuned.html>`_ which may be used to optimize system settings.

* If relevant, create a striped LVM volume over multiple disk shelves with correct number of stripes and a suitable stripesize, for example::

    lvcreate -n lvxfs -l 100%VG vgxfs -i 2 -I 4096

* Choose XFS stripe units consistent with the underlying disks, for example::

    mkfs.xfs -d su=256k,sw=20 /dev/mapper/vgxfs-lvxfs

See ``man mkfs.xfs`` about the *su,sw* parameters, and see below how to determine the stripe size.

Finally, check the filesystem parameters with::

  xfs_info /dev/mapper/vgxfs-lvxfs

Stripe size
-----------

The logical volume stripe size used by the HP *SmartArray* controllers may be viewed by the local script::

  /root/smartshow -l

Look for *Strip size* (which may vary), or identify somehow the correct PCI slot (for example, with ``lspci``) and do::

  /usr/sbin/hpacucli controller slot=4 logicaldrive all show detail

Mounting NFS volumes
============================

There are some articles on the net discussing performance tuning of the XFS filesystem:

* http://www.mythtv.org/wiki/Optimizing_Performance (see *Disabling File Access Time Logging*, *Changing Number of Log Buffers* and *XFS-Specific Tips*)
* `Filesystem performance tweaking with XFS on Linux <http://everything2.com/index.pl?node_id=1479435>`_

So it may be a good idea to disable file access time logging **noatime,nodiratime** 
and inrease the number of log buffers **logbufs=X** with the mount options in ``/etc/fstab``::

  /dev/mapper/vgxfs-lvxfs /u3/raid  xfs  defaults,quota,noatime,nodiratime,logbufs=8,nosuid,nodev  1 2

XFS quotas
============================

Quotas are administered differently in XFS, see the ``man xfs_quota`` section *QUOTA ADMINISTRATION*.
Quotas are enabled by default, provided the filesystem is mounted with the quotas option in ``/etc/fstab``::

  defaults,quota,...

The xfs_quota administrative commands require the -x *expert* flag.

To set the default user quotas to 100/120 GB on the /u2/raid disk use the -d flag::

  xfs_quota -x -c "limit bsoft=100g bhard=120g isoft=100000 ihard=120000 -d" /u2/raid

To set a specific user's quota::

  xfs_quota -x -c "limit bsoft=240g bhard=300g isoft=100000 ihard=120000 abild" /u2/raid

Note that a user's quota doesn't get updated until his files are modified.

To list the current disk quotas in "human" units::

  xfs_quota -x -c "report -h" /u2/raid


Extend a Logical Volume and XFS filesystem
=======================================================

To add additional disks to a logical volume the procedure is as follows.
We assume that a new disk ``/dev/sdc1`` is available.

Initialize the disk for LVM and add it to the volume group::

  pvcreate /dev/sdc1
  vgextend vgxfs /dev/sdc1

Now that the Volume Group has available free space, the easiest way to extend the Logical Volume and XFS filesystem is using the GUI::

  system-config-lvm

If you prefer to do this with manual commands, here is an example:
Add 80% of the newly added disk to the previously created Logical Volume::

  lvextend -l +80%FREE /dev/mapper/vgxfs-lvxfs

Use the flag ``lvextend -r`` to resize the filesystem automatically.

The XFS filesystem can now be extended to occupy all of the available disk space added above.
Assume that the XFS filesystem is mounted on ``/u3/raid``, then it is extended to occupy all available free disk space by::

  # xfs_growfs /u3/raid
  meta-data=/dev/mapper/vgxfs-lvxfs isize=256    agcount=32, agsize=28614880 blks
           =                       sectsz=512   attr=0
  data     =                       bsize=4096   blocks=915676160, imaxpct=25
           =                       sunit=0      swidth=0 blks, unwritten=1
  naming   =version 2              bsize=4096
  log      =internal               bsize=4096   blocks=32768, version=1
           =                       sectsz=512   sunit=0 blks, lazy-count=0
  realtime =none                   extsz=4096   blocks=0, rtextents=0
  data blocks changed from 915676160 to 1831352320

Shrinking an XFS filesystem ?
=======================================================

If you would like to shrink an XFS filesystem, this is **not possible** as explained in this XFS_FAQ_:
`Is there a way to make a XFS filesystem larger or smaller? <http://xfs.org/index.php/XFS_FAQ#Q:_Is_there_a_way_to_make_a_XFS_filesystem_larger_or_smaller.3F>`_.

Remove a disk from a volume group
=======================================================

If you want to remove a physical vole (disk) from a volume group, see 
`4.3. Volume Group Administration <https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Logical_Volume_Manager_Administration/VG_admin.html>`_, 
section *4.3.7. Removing Physical Volumes from a Volume Group*.

For example, if you have 2 disks D and E in a volume group *vgtest*, migrate all data from disk D to disk E::

  pvmove /dev/sdd1 /dev/sde1

This operation may take several hours!

Make sure that disk D is actually empty (PV Status = available)::

  pvdisplay /dev/sdd1

Then remove the **empty disk** D from the volume group *vgtest*::

  vgreduce vgtest /dev/sdd1

Extend an ext3 filesystem
============================

Like an XFS filesystem, an *ext3* filesystem can also be extended on the fly.
First you must enlarge the logical volume as above.
Then you can extend the *ext3* filesystem to the available size of the partition::

  resize2fs -f /dev/VolGroup00/LogVol00 

An optional *size* parameter can also be specified, see the man-page.

XFS performance measurement
============================

We can measure the filesystem write performance by creating a file full of zeroes. 

Hardware config for this measurement:

* HP DL380 G5 server with a P800 Smart Array controller (512 MB RAM).
* MSA60 disk shelf with 12 SATA disks 750 GB in a RAID-6 configuration.

We run this command to create a file of size 10 GB::

  time dd if=/dev/zero of=temp bs=1024k count=10240

We obtain these timings from the ``dd`` command:

* **XFS** filesystem: 10737418240 bytes (11 GB) copied, 55.6954 seconds, **193 MB/s**
* **ext3** filesystem: 10737418240 bytes (11 GB) copied, 104.275 seconds, **103 MB/s**

XFS fragmentation
============================

There is some advice on `XFS fragmentation <http://www.mythtv.org/wiki/Optimizing_Performance#Combat_Fragmentation_2>`_.
For example the **allocsize** mount option may be useful.

Run the following command to determine how fragmented your filesystem is::

  xfs_db -c frag -r /dev/mapper/vgxfs-lvxfs

For files which are already heavily fragmented, the ``xfs_fsr`` command (from the xfsdump package) can be used to defragment individual files, or an entire filesystem::

  xfs_fsr /dev/mapper/vgxfs-lvxfs

XFS filesystem gives "No space left on device" errors
=======================================================

This error message may be given even when there is plenty of free disk space.
The reason is a problem with all inodes being located below 1 TB disk size, see 
`this thread <http://oss.sgi.com/archives/xfs/2009-01/msg01031.html>`_ 
and the `XFS FAQ on No space left <http://xfs.org/index.php/XFS_FAQ#Q:_Why_do_I_receive_No_space_left_on_device_after_xfs_growfs.3F>`_ 
and the XFS_FAQ_ on XFS_inode64_.

There is a Red Hat `Knowledge base <https://access.redhat.com/site/solutions/657283>`_ article about this.

Mounting with inode64 may be the solution, but then one cannot revert this mount option later for kernels < 2.6.35!

Listing LVM disk segments and stripes
=======================================================

There is a useful LVM summary page `cheat sheet on LVM using Linux <http://www.datadisk.org.uk/html_docs/redhat/rh_lvm.htm>`_.

To list the LVM logical volumes in one or more physical volumes::

  pvdisplay -m

where the *-m* flag means display the mapping of physical extents to logical volumes and logical extents.

To list the LVM disk segments used::

  pvs -v --segments

To list the number of disk segments, as well as the stripes of an LVM volume group use the *lvs* command::

  # lvs -v --segments vgxfs
  Using logical volume(s) on command line
  LV     VG    Attr       Start  SSize    #Str Type    Stripe  Chunk
  lvxfs2 vgxfs -wi-ao----     0    23.44t    4 striped 512.00k    0 
  lvxfs2 vgxfs -wi-ao---- 23.44t   12.84t    4 striped 512.00k    0 
  lvxfs2 vgxfs -wi-ao---- 36.27t    1.34t    4 striped 512.00k    0 
  lvxfs2 vgxfs -wi-ao---- 37.62t    1.45t    4 striped 512.00k    0 
  lvxfs3 vgxfs -wi-ao----     0     9.77t    1 linear       0     0 
  lvxfs4 vgxfs -wi-ao----     0     6.61t    1 linear       0     0 
  lvxfs4 vgxfs -wi-ao----  6.61t    1.20t    1 linear       0     0 
  lvxfs4 vgxfs -wi-ao----  7.81t    2.93t    1 linear       0     0 
  lvxfs4 vgxfs -wi-ao---- 10.74t 1000.00g    1 linear       0     0 
  lvxfs6 vgxfs -wi-ao----     0     4.88t    4 striped 512.00k    0 
  lvxfs7 vgxfs -wi-ao----     0     8.43t    1 linear       0     0 
  lvxfs7 vgxfs -wi-ao----  8.43t    2.31t    1 linear       0     0 

This example shows how many physical disk volume stripes are being used by the logical volumes.
