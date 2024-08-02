.. _LinuxSoftwareRAID:

Linux Software-RAID disks
=========================

.. Contents::

In order to save money on true hardware-RAID controllers, it is sometimes useful to have 
*Software-RAID disks* where Linux takes care of the mirroring (RAID-1) or RAID-5.
This is certainly much less safe than hardware-RAID controllers, especially 
for bootable Linux partitions which are difficult to boot in the event of a disk failure.

Listing SCSI disk devices
----------------------------------

In order to list the SCSI disk devices in the system, use the lsscsi_ command.
Install relevant software by::

  yum install lsscsi smp_utils sg3_utils

.. _lsscsi: http://sg.danny.cz/scsi/lsscsi.html
.. _sg3_utils: http://sg.danny.cz/sg/sg3_utils.html
.. _smp_utils: http://sg.danny.cz/sg/smp_utils.html

The disk listing may look like::

  # lsscsi 
  [0:0:0:0]    disk    ATA      ST3250410AS      3.AH  /dev/sda 
  [1:0:0:0]    disk    ATA      WDC WD2002FAEX-0 05.0  /dev/sdb 
  [2:0:0:0]    disk    ATA      WDC WD2002FAEX-0 05.0  /dev/sdc 
  [3:0:0:0]    disk    ATA      WDC WD2002FAEX-0 05.0  /dev/sdd 
  [4:0:0:0]    disk    ATA      WDC WD2002FAEX-0 05.0  /dev/sde 

See also:

* http://www.cyberciti.biz/faq/debian-ubuntu-linux-list-scsi-devices-hosts-attributes-lsscsi-command/
* `Storage and SCSI tools <http://sg.danny.cz/sg/tools.html>`_
* The smp_utils_ package: Utilities for the Serial Attached SCSI (SAS) Serial Management Protocol (SMP)
* The sg3_utils_ package: Utilities that send SCSI commands to devices

LSI RAID and HBA controllers
----------------------------

Our server *rsnap1* has a LSI_ SAS `9207-8e <http://www.lsi.com/products/host-bus-adapters/pages/lsi-sas-9207-8e.aspx>`_ HBA disk controller.

LSI_ RAID and HBA controllers may use some LSI_ tools:

* Userworld Tool (SAS2IRCU) for RAID configuration on LSI SAS2 Controllers that is designed to run from a host.
* *lsiutil* tool (may be obsolete), see `download hints <http://www.dzhang.com/blog/2013/03/22/where-to-get-download-lsiutil>`_.

SAS2IRCU may be `searched <http://www.lsi.com/search/pages/Results.aspx?k=sas2ircu>`_ from LSI. Current version is *SAS2IRCU_P17*.
See the `SAS2IRCU User Guide <http://www.lsi.com/downloads/Public/Host%20Bus%20Adapters/Host%20Bus%20Adapters%20Common%20Files/SAS_SATA_6G_P12/SAS2IRCU_User_Guide.pdf>`_.
Unpack the SAS2IRCU zip-file and copy the relevant binary utility to /usr/local/bin.

To list LSI controllers::

  sas2ircu LIST

To list disks on controller 0::

  sas2ircu 0 display

Disk drive blinking LED
-----------------------

Determine the *Serial Number* of the disk to blink, for example, */dev/sdt*::

  smartctl -a /dev/sdt | grep Number

**IMPORTANT:**
The script lsi_device_list.sh__ uses the ``sas2ircu`` command to list devices in a readable format.
Here you can grep for disk serial numbers for identification and read the ``Encl:Slot`` information,
which seems to be impossible to read otherwise::

  lsi_device_list.sh | grep <Serial Number>

Now use the printed ``Encl:Slot`` information to make the disk blink.

To turn on the **blinking disk drive LED** use the command::

  sas2ircu <controller #> LOCATE <Encl:Bay> <Action>
    where <controller #> is:
      A controller number between 0 and 255.
    where <Encl:Bay> is:
      A valid Enclosure and Bay pair to identify 
      the drive
    where <Action> is:
      ON   -  turn ON the drives LED 
      OFF  -  turn OFF the drives LED 

for example::

  sas2ircu 0 locate 3:18 ON

Notice: ON and OFF must be in Upper Case!

.. _LSI: http://www.lsi.com
__ attachment:lsi_device_list.sh

Software RAID documentation
----------------------------------

You should read the `Software-RAID HOWTO <http://tldp.org/HOWTO/Software-RAID-HOWTO.html>`_.
The Wikipedia article about the mdadm_ command is extremely useful.
Also, the on-line manual for the ``mdadm`` command is useful.

Some articles on the net about software RAID:

* `Quick HOWTO : Ch26 : Linux Software RAID <http://www.linuxhomenetworking.com/wiki/index.php/Quick_HOWTO_:_Ch26_:_Linux_Software_RAID>`_

.. _mdadm: http://en.wikipedia.org/wiki/Mdadm

Creating a RAID array from command line
-------------------------------------------------------------------

For a running system you have use the mdadm_ command to create and manage RAID disks.

First partition all the disks to be used for the RAID array (we use disk ``/dev/sdXX`` in this example)::

  # parted /dev/sdXX
  (parted) mklabel gpt                 # Makes a "GPT" label permitting large filesystems
  (parted) mkpart primary xfs 0 100%  # Allocate 100% of the partition for XFS filesystem
  (parted) set 1 raid on               # Configure partition 1 for RAID
  (parted) set 1 boot on               # Configure as bootable (optional)
  (parted) print                       # Check the partition
  (parted) quit

If you need to wipe any preexisting partitions on the disk, this may be done by zeroing the first few blocks on the disk::

  dd if=/dev/zero of=/dev/sdXX bs=512 count=10

Create a RAID 5 volume from 3 partitions of exactly or nearly exactly the same size (for example)::

  mdadm --create /dev/md0 --level=5 --raid-devices=3 /dev/sdd1 /dev/sde1 /dev/sdf1

**Warning**: anaconda (kickstart) creates partitions is random order https://bugzilla.redhat.com/show_bug.cgi?id=733791
There is no guarantee that /dev/sda1 is created first - always make sure you select the correct partitions for /dev/mdX device!

Configure RAID volume for reboot
--------------------------------

First identify all current RAID devices by::

  mdadm --examine --scan

To add all RAID devices to ``/etc/mdadm.conf`` so that it is recognized the next time you boot::

  mdadm --examine --scan > /etc/mdadm.conf

Monitoring RAID disks with mdmonitor
-------------------------------------------------------------------

RAID device events can be monitored by the daemon service **mdmonitor**, see the *Monitor* section of the *mdadm* man-page.

First you **must** define the notification E-mail address or program in ``/etc/mdadm.conf``, see *man 5 mdadm.conf*, for example::

  MAILADDR root@mail.fysik.dtu.dk

Then start the *mdmonitor* service::

  chkconfig mdmonitor on
  service mdmonitor start

Monitor disk errors in syslog
-----------------------------

A disk may be partly failing, but not so badly that it's kicked out of a RAID set.
To monitor the syslog for kernel messages such as::

  Feb 24 09:16:39 ghost309 kernel: ata2.00: failed command: READ FPDMA QUEUED

(and many others), insert the following crontab job::

  # Report any kernel syslog messages (maybe broken ATA disks)
  0 3 * * * /bin/grep kernel: /var/log/messages

A script to look only for md or ata errors from today is::

  TODAY=`date +'%b %e'`
  SYSLOG=/var/log/messages
  /bin/grep "$TODAY.*kernel:.*md:" $SYSLOG
  /bin/grep "$TODAY.*kernel:.*ata" $SYSLOG


Weekly RAID checks
------------------

The *mdadm* RPM package includes a cron script for weekly checks of the RAID devices in the file ``/etc/cron.d/raid-check``::

  # Run system wide raid-check once a week on Sunday at 1am by default
  0 1 * * Sun root /usr/sbin/raid-check

The ``raid-check`` configuration file is ``/etc/sysconfig/raid-check``.
To make the checks occur sequentially (a good idea for RAID devices on the same controller) use this setting::

  MAXCONCURRENT=1

You can disable the raid checks by setting::

  ENABLED=no

Set the check nice level::

  NICE=normal

To cancel a running test, use::

  echo idle > /sys/devices/virtual/block/md1/md/sync_action 

See https://lxadm.com/Mdadm:_stopping_and_starting_RAID_check_in_Linux

Increasing speed of RAID check
------------------------------

The default RAID check speed is controlled by these kernel parameter default values::

  # cat  /proc/sys/dev/raid/speed_limit_min /proc/sys/dev/raid/speed_limit_max
  1000
  200000

meaning:

* Minimum of 1000 kB/second per disk device.
* Maximum of 200.000 kB/second for the RAID set.

The kernel will report this in the syslog::

  md: minimum _guaranteed_  speed: 1000 KB/sec/disk.
  md: using maximum available idle IO bandwidth (but not more than 200000 KB/sec) for data-check.

See also http://www.cyberciti.biz/tips/linux-raid-increase-resync-rebuild-speed.html.

Since 200 MB/sec is quite modest and designed to keep the system responsive, the maximum speed can be increased at the cost of system resources, for example::

  echo 100000  > /proc/sys/dev/raid/speed_limit_min
  echo 1000000 > /proc/sys/dev/raid/speed_limit_max

which sets the minimum to 100 MB/s for each disk and maximum to 1 GB/s for the RAID array.

This can be configured at boot time in ``/etc/sysctl.conf``, for example::

  #################NOTE ################
  ##  You are limited by CPU and memory too #
  ###########################################
  dev.raid.speed_limit_min = 50000
  ## good for 4-5 disks based array ##
  dev.raid.speed_limit_max = 2000000
  ## good for large 6-12 disks based array ###
  dev.raid.speed_limit_max = 5000000

Monitoring RAID disks with logwatch
-------------------------------------------------------------------

The RHEL6/CentOS6 logwatch_ tool doesn't have scripts for RAID disk monitoring with *mdadm*.
Later versions of logwatch_ (7.4?) have scripts in the ``/scripts/services/mdadm`` and ``/conf/services/mdadm.conf``.
But these seem to need debugging for RHEL systems.

.. _logwatch: http://sourceforge.net/p/logwatch/code/HEAD/tree/

Performance optimization of RAID5/RAID6
-------------------------------------------------------------------

The Linux kernel by default allocates much too small kernel buffers for efficient RAID5 or RAID6 operations.
See for example:

* `5 Tips To Speed Up Linux Software Raid Rebuilding And Re-syncing <http://www.cyberciti.biz/tips/linux-raid-increase-resync-rebuild-speed.html>`_
* `RAID5 with mdadm <http://middoraid.blogspot.dk/2013/01/tweaking.html>`_
* `Making stripe_cache_size permanent <http://askubuntu.com/questions/20852/making-stripe-cache-size-permanent>`_
* `What is stripe_cache_size and what does it do? <http://serverfault.com/questions/579489/linux-what-is-stripe-cache-size-and-what-does-it-do>`_.

To increase the kernel read-ahead of a disk device::

  blockdev --setra 20480 /dev/md0

To check the current value::

  blockdev --report  /dev/md0

To change the cache kernel buffer size of RAID device md0::

  echo 8192 > /sys/block/md0/md/stripe_cache_size

To test RAID I/O performance::

  cd <RAID-disk dir>
  time dd bs=1M count=65536 if=/dev/zero of=test conv=fdatasync

The *md* man-page says:

* md/stripe_cache_size
    This is only available on RAID5 and RAID6. It records the size (in pages per device) of the stripe cache which is used for synchronising all write operations to the array and all read operations if the array is degraded.
    The default is 256. Valid values are 17 to 32768. Increasing this number can increase performance in some situations, at some cost in system memory.
    Note, setting this value too high can result in an "out of memory" condition for the system.

    memory_consumed = system_page_size * nr_disks * stripe_cache_size 

Disable NCQ on SATA disks in mdadm RAID arrays
----------------------------------------------

See advcie in:

* https://www.cyberciti.biz/tips/linux-raid-increase-resync-rebuild-speed.html
* https://serverfault.com/questions/956083/md-raid-disable-ncq

This loop may be put in ``/etc/rc.local``::


  for i in sdaa sdab sdac sdad sdae sdaf sdag sdah sdai sdaj sdak sdal sdam sdan sdao sdap sdaq sdar sdas sdat sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr sds sdt sdu sdv sdw sdx sdy sdz
  do
        echo 1 > /sys/block/$i/device/queue_depth
  done


How to replace a failed RAID disk
----------------------------------

The *mdadm* monitoring may send mail about a failed disk.
To see the status of a RAID array do::

  mdadm --detail /dev/md0
  ...
      Number   Major   Minor   RaidDevice State
       0       8       17        0      active sync   /dev/sdb1
       1       8       33        1      active sync   /dev/sdc1
       2       0        0        2      removed
       3       8       65        3      active sync   /dev/sde1

Make sure the failed disk state is faulty::

   mdadm --manage /dev/md0 --fail /dev/sdd1

and removed from the array::

   mdadm --manage /dev/md0 --remove /dev/sdd1

This may need to be performed for all the partitions on the failed physical disk.

Only working devices should be listed by ``cat /proc/mdstat`` now.

You now have to physically identify the failed hard disk.
The first system disk may be */dev/sda*, the second */dev/sdb* and so on,
and the system board may show you which disk is *SATA0*, *SATA1* and so on.

For a simple few-disks systems with disk drives mounted externally,
one can identify working drives by their activity::

  cat /dev/sdX >/dev/null

Power down the system and remove the failed disk.
If the failed disk was the boot device replacing it with a clean disk
will prevent booting. In this case one has to physically switch the order of disks,
so the system boots from the first disk (is there a workaround?).
On hot-swap systems you can boot from single, working disk, and add the new disk after.
Boot up the system and check the RAID status as above.

Replacing a hot-swap disk
-------------------------

You can **blink** the drive LED on an LSI controller as described above.

If your system supports hot-swap disks, swap the disk and list all devices::

  lsscsi

If the disk does not appear as ``/dev/sdX`` after inserting, force a rescan on a SCSI BUS::

  echo "- - -" >/sys/class/scsi_host/host<n>/scan  # for all n

If the disk contains data, you may clear the partitions on the new disk (remember that ``cat /proc/mdstat`` lists only active disks now)::

  dd if=/dev/zero of=/dev/sdd bs=512 count=10

We have had cases where the SCSI bus appeared on the disk drive, and we had to reboot the server.

Partition the new disk (for example, /dev/sdd1) for RAID as shown above,
or clone the partition table of the working disk (``/dev/sdc``)::

  sfdisk -d /dev/sdc | sfdisk --force /dev/sdd

**Note**: one is supposed to use gdisk (`yum install gdisk`), but this didn't work for me::

  sgdisk -R /dev/sdd /dev/sdc  # clone - note the order of arguments!
  sgdisk -G /dev/sdd  # randomize UUID of /dev/sdd

Now you can add the (all) new disk partitions to (all) the RAID disks::

  mdadm /dev/md0 -a /dev/sdd1
  mdadm --detail /dev/md0

The rebuilding to the newly added disk begins automatically (see *man mdadm*).
This can also be monitored in the output like this::

  # mdadm --detail /dev/md0 | grep Rebuild
  Rebuild Status : 8% complete

  # cat /proc/mdstat
