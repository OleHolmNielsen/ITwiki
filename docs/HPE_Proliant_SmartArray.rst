.. _hpe_proliant_smartarray:

===================================
HPE Proliant SmartArray
===================================

.. Contents::

Management of HPE Proliant SmartArray RAID controllers
=======================================================

SmartArray software
========================

Install Linux software::

  # rpm --import http://downloads.linux.hpe.com/SDR/hpePublicKey2048_key1.pub

Add Yum repository file ``/etc/yum.repos.d/HPE-MCP.repo``::

  [HPE-MCP]
  baseurl = http://downloads.linux.hpe.com/repo/mcp/centos/8/x86_64/current/
  enabled = 1
  gpgcheck = 1
  gpgkey = https://downloads.linux.hpe.com/SDR/repo/mcp/GPG-KEY-mcp
  name = HPE Management Component Pack

Install packages and OS prerequisites::

  # yum install net-snmp net-snmp-utils net-snmp-libs net-snmp-agent-libs
  # yum install ssa ssacli ssaducli hponcfg

A *Smart Storage Adminstrator CLI* command ``/usr/sbin/ssacli`` is installed.
Example usages are::

  # /usr/sbin/ssacli
  => help 
  => controller all show status

Status of controller slot=0::

  => controller slot=0 show status
  => controller slot=0 show detail
  => controller slot=0 enclosure all show detail

Show slot=1 physical drives and details::

  => controller slot=1 physicaldrive all show 
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

Here you can read the disk name, serial number etc.


Show arrays::

  => controller slot=0 array all show detail

Show logical drives::

  => controller slot=0 logicaldrive all show detail

A useful script is smartshow_ from GitHub.

.. _smartshow: https://github.com/OleHolmNielsen/HPE_Proliant

Moving SmartArray disk to another server
===========================================

It may be necessary to move SmartArray disk to another HPE Proliant server
and import the logical drives contained on the set of disks.
The following command will import all new logical drives::

  # vgimportdevices -a

Verify the new Physical Volumes and Logical Volumes::

  # pvdisplay
  # lvdisplay

Extend a logical drive
=========================

New disks can be added to an existing logical drive (RAID-6, for example), see these ``ssacli`` help items::

  => help extend
  => help expand

For example, add a new drive to controller in slot=0 array B::

  => controller slot=0 array B add drives=1I:1:11

Having added disk drives, the logical drive will be transformed, and this can take a number of hours.
After this you can extend the logical drive no. 2 size::

  => controller slot=0 logicaldrive 2 modify size=max 

At this point you may need to **reboot the server** so that it recognizes the updated disk label!
Also watch out for disk being renamed in the process (sda may become sdb and vice versa),
a new reboot may solve this issue.
  
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

The disk partition is still the old size, and it must be resized as well to the available size (which is 4201GB in the above example)::

  (parted) resizepart 1 4201GB
  (parted) p
  Model: HP LOGICAL VOLUME (scsi)
  Disk /dev/sdb: 4201GB
  Sector size (logical/physical): 512B/512B
  Partition Table: gpt
  Disk Flags:
  
  Number  Start   End     Size    File system  Name     Flags
   1      17.4kB  4201GB  4201GB               primary  lvm

After updating the disk partition size, a **reboot of the server** may be required for LVM to recognize the changed disk size!

Finally resize the PV (first make a verbose test) and verify the new Physical Volume size::

  # pvresize --test --verbose /dev/sdb1
  # pvresize --verbose /dev/sdb1
  # pvdisplay /dev/sdb1

Now you can use ``vgdisplay`` for the Volume Group containing ``/dev/sdb1`` to verify the new Volume Group size.
