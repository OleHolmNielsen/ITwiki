===================================
HPE Proliant SmartArray
===================================

.. Contents::

Management of HPE Proliant SmartArray RAID controllers
=======================================================

SmartArray software
========================

Install Linux software::

  rpm --import http://downloads.linux.hpe.com/SDR/hpePublicKey2048_key1.pub

Add Yum repository file ``/etc/yum.repos.d/HPE-MCP.repo``::

  [HPE-MCP]
  baseurl = http://downloads.linux.hpe.com/repo/mcp/centos/8/x86_64/current/
  enabled = 1
  gpgcheck = 1
  gpgkey = https://downloads.linux.hpe.com/SDR/repo/mcp/GPG-KEY-mcp
  name = HPE Management Component Pack

Install packages and OS prerequisites::

  yum install net-snmp net-snmp-utils net-snmp-libs net-snmp-agent-libs
  yum install ssa ssacli ssaducli hponcfg

A *Smart Storage Adminstrator CLI* command ``/usr/sbin/ssacli`` is installed.
An example usage is::

  # /usr/sbin/ssacli
  => help 
  => controller slot=0 physicaldrive all show 

A useful script is smartshow_ from GitHub.

.. _smartshow: https://github.com/OleHolmNielsen/HPE_Proliant

Extend a logical drive
=========================

New disks can be added to an existing logical drive (RAID-6, for example), see these help items::

  => help extend
  => help expand

Add a new drive to array B::

  => controller slot=0 array B add drives=1I:1:11

Extend the logical drive no. 2 size::

  => controller slot=0 logicaldrive 2 modify size=max 
  
When the SmartArray logical drive has been extended,
the Linux LVM volume must be extended as well by updating the disk partition table, for example::

  # parted /dev/sdb
  GNU Parted 3.5
  Using /dev/sdb
  Welcome to GNU Parted! Type 'help' to view a list of commands.
  (parted) p
  Warning: Not all of the space available to /dev/sdb appears to be used, you can fix the GPT to use all of the space (an extra 1172048384 blocks) or continue with the current setting?
  Fix/Ignore? fix
  Model: HP LOGICAL VOLUME (scsi)
  Disk /dev/sdb: 4201GB
  Sector size (logical/physical): 512B/512B
  Partition Table: gpt
  Disk Flags:
  
  Number  Start   End     Size    File system  Name     Flags
   1      17.4kB  3601GB  3601GB               primary  lvm

The disk partition is still the old size, and it must be resized as well to the available size::

  (parted) resizepart 1 4201GB
  (parted) p
  Model: HP LOGICAL VOLUME (scsi)
  Disk /dev/sdb: 4201GB
  Sector size (logical/physical): 512B/512B
  Partition Table: gpt
  Disk Flags:
  
  Number  Start   End     Size    File system  Name     Flags
   1      17.4kB  4201GB  4201GB               primary  lvm

Finally resize the PV (first make a verbose test) and verify the new Physical Volume size::

  # pvresize --test --verbose /dev/sdb1
  # pvresize --verbose /dev/sdb1
  # pvdisplay /dev/sdb1

Now you can use ``vgdisplay`` for the Volume Group containing ``/dev/sdb1`` to verify the new Volume group size.
