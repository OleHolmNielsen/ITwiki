.. _PXE_and_UEFI:

==================================
Install EL Linux via PXE and UEFI
==================================

.. Contents::

Overview
========

This *HowTo* guide documents how to install EL Linux using PXE_ on a client host booting by UEFI_.

This page assumes that you already have a working DHCP_ and PXE_ boot server for installing client hosts using the Legacy_BIOS_boot_ method. 
We will show how to support also UEFI_ booting with PXE_.
Optionally, you may also use an NFS server to store Kickstart_ files.

See also our network PXE-booting_ page for Linux OS installation.

See also some useful pages:

* https://www.gnu.org/software/grub/manual/grub/grub.html
* https://fedoraproject.org/wiki/GRUB_2
* https://help.ubuntu.com/community/Grub2/Passwords
* https://wiki.fogproject.org/wiki/index.php/BIOS_and_UEFI_Co-Existence
* https://github.com/quattor/aii/issues/216

.. _CentOS: https://www.centos.org/
.. _PXE: https://en.wikipedia.org/wiki/Preboot_Execution_Environment
.. _DHCP: https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol
.. _UEFI: https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface
.. _Legacy_BIOS_boot: https://en.wikipedia.org/wiki/Legacy_mode
.. _PXE-booting: https://wiki.fysik.dtu.dk/niflheim/PXE-booting
.. _GRUB2: https://fedoraproject.org/wiki/GRUB_2

Setting up the DHCP and PXE server
==================================

Enable UEFI support in the DHCP server
--------------------------------------

We assume a Linux DHCP server and add the following to ``/etc/dhcpd.conf`` in the top (global) section::

  # These settings are required for UEFI boot:
  option arch code 93 = unsigned integer 16; # RFC4578

The *Client System Architecture Type Option* 93 (*EFI x86-64*) is defined in RFC4578_.

Add these options only if you need to support MTFTP_ (*Multicast TFTP*) as recommended (but undocumented) in many places::

  option space PXE;
  option PXE.mtftp-ip    code 1 = ip-address;
  option PXE.mtftp-cport code 2 = unsigned integer 16;
  option PXE.mtftp-sport code 3 = unsigned integer 16;
  option PXE.mtftp-tmout code 4 = unsigned integer 8;
  option PXE.mtftp-delay code 5 = unsigned integer 8;

.. _RFC4578: https://tools.ietf.org/html/rfc4578
.. _MTFTP: https://tools.ietf.org/html/draft-henry-remote-boot-protocol-00

In the DHCP subnet section(s) define UEFI RFC4578_ or PXE (legacy) boot image types in the ``/tftpboot/uefi/`` subdirectory::

  # UEFI x86-64 boot (RFC4578 architecture types 7, 8 and 9)
  if option arch = 00:07 {          
        filename "uefi/BOOTX64.EFI";
  } else if option arch = 00:08 {
        filename "uefi/BOOTX64.EFI";
  } else if option arch = 00:09 {
        filename "uefi/BOOTX64.EFI";
  } else {                              
        # PXE boot
        filename "pxelinux.0";
  }

NOTES: 

* the ``BOOTX64.EFI`` file name seems to be upper case in the EL8 installation images.

* It seems that having the boot file in a subdirectory such as ``uefi/BOOTX64.EFI``
  will cause the client host PXE to download all further files also from that same ``uefi/`` subdirectory, so you need to place other files there.

* **Probably obsolete:** The ``shimx64.efi`` bootloader_ may be required in stead of ``BOOTX64.EFI`` in the above ``/etc/dhcpd.conf``.

Copy UEFI boot files
--------------------

We create a special directory for UEFI_ boot files on the TFTP server::

  mkdir /var/lib/tftpboot/uefi

which is also soft-linked as ``/tftpboot/uefi/``.

The OS installation ``*.efi`` files **must** be copied from the OS installation image,
since the versions contained in EL8 RPM packages seem to be buggy,
see for example https://forums.rockylinux.org/t/pxe-boot-uefi-mode/4852.
Symptoms may be that TFTP download of large ``vmlinuz`` or ``initrd.img`` files 
during Kickstart fail with a message *error: timeout reading ...*.

Download **all .efi files** from a mirror site, 
for example, https://mirror.fysik.dtu.dk/linux/almalinux/8.8/BaseOS/x86_64/kickstart/EFI/BOOT/
to the TFTP server's folder ``/tftpboot/uefi/``.

OBSOLETE: Copy .efi files from the OS RPMs
..............................................

**WARNING:** The .efi files from the OS RPMs seem to be buggy:
Large image files (vmlinuz, initrd.img) cannot be downloaded reliably by TFTP,
see for example https://forums.rockylinux.org/t/pxe-boot-uefi-mode/4852

We need to copy UEFI_ boot files from EL Linux and we need these RPMs::

  yum install grub2-efi-x64 shim-x64

The shim_ EFI application may be required.

.. _shim: https://github.com/rhboot/shim/

UEFI boot files may be located in different places depending on your distribution, for example in::

  /boot/efi/EFI/centos/
  /boot/efi/EFI/redhat/

Copy the boot files, for example::

  cp -p /boot/efi/EFI/centos/*.efi /var/lib/tftpboot/uefi/
  chmod 755 /var/lib/tftpboot/uefi/*.efi

*Alternatively* you can build your own using this RPM::

  yum install grub2-efi-x64-modules

Then build your own boot file ``BOOTX64.EFI`` by::

  grub2-mkstandalone -d /usr/lib/grub/x86_64-efi/ -O x86_64-efi --modules="tftp net efinet linux part_gpt efifwsetup" -o /var/lib/tftpboot/uefi/BOOTX64.EFI

The GRUB2_ modules are documented in https://www.linux.org/threads/understanding-the-various-grub-modules.11142/

Download Linux boot images
-----------------------------

For each EL Linux (and other OS) version you should copy Linux boot images to a separate directory on the TFTP server,
for example, for AlmaLinux 8.8::

  mkdir /var/lib/tftpboot/AlmaLinux-8.8-x86_64/

In this directory create the following ``Makefile``::

  OS=almalinux
  VERSION=8.8
  MIRROR=https://mirror.fysik.dtu.dk/linux
  default:
        @echo "NOTE: Boot images are from ${OS} version ${VERSION}"
        @wget --timestamping ${MIRROR}/${OS}/${VERSION}/BaseOS/x86_64/os/images/pxeboot/initrd.img
        @wget --timestamping ${MIRROR}/${OS}/${VERSION}/BaseOS/x86_64/os/images/pxeboot/vmlinuz

and run a ``make`` command to download the boot image files.
Other mirror sites may be used in stead of *mirror.fysik.dtu.dk*,
and other versions of ``OS`` and ``VERSION``.

Create grub.cfg file
--------------------

The ``uefi/BOOTX64.EFI`` boot file will be looking for a Grub_ configuration file ``uefi/grub.cfg`` in the same subdirectory.
Create ``/var/lib/tftpboot/uefi/grub.cfg`` with the contents::

  set default="0"
  function load_video {
    insmod efi_gop
    insmod efi_uga
    insmod video_bochs
    insmod video_cirrus
    insmod all_video
  }
  load_video
  set gfxpayload=keep
  insmod net
  insmod efinet
  insmod tftp
  insmod gzio
  insmod part_gpt
  insmod ext2
  set timeout=10
  search --no-floppy --set=root -l 'CentOS 7.9 x86_64'
  menuentry 'Install CentOS Linux 7.9' --class fedora --class gnu-linux --class gnu --class os {
    linuxefi (tftp)/CentOS-7.9.2009-x86_64/vmlinuz ip=dhcp inst.repo=http://mirror.centos.org/centos-7/7.9.2009/os/x86_64/
    initrdefi (tftp)/CentOS-7.9.2009-x86_64/initrd.img
  }


Other mirror sites may be used in stead of mirror.centos.org.

Additional menu entries may be appended to the above, for example::

  menuentry 'Install CentOS Linux 7.9 from NFS server' --class fedora --class gnu-linux --class gnu --class os {
    linuxefi (tftp)/CentOS-7.9.2009-x86_64/vmlinuz ip=dhcp inst.repo=nfs:ro,rsize=8192,wsize=8192,tcp,vers=3,nolock:nfs-server.example.com:/opt/centos79/os/x86_64
    initrdefi (tftp)/CentOS-7.9.2009-x86_64/initrd.img
  }

It is useful to have a ``grub.cfg`` menu item from the TFTP server which allows to boot the system from an existing OS installation on disk.
This should be the default menu item.
To boot a CentOS system with ``grubx64.efi`` (provided by the ``grub2-efi-x64`` package) in the 1st partition of the first disk hd0::

  menuentry 'Boot CentOS from local disk hd0' {
   set root=(hd0,1)
   chainloader /efi/centos/grubx64.efi
  }

The ``.efi`` files of other Linux distributions will be in different subdirectories of ``/boot/efi/EFI``.

If there are multiple disks in the server, Grub_ will label them as *hd0, hd1, hd2*, etc.
It seems that the numbering of such disks may vary, and if the OS installation is suddenly in disk *hd1* in stead of *hd0*,
it is useful to define a fallback_ boot menu item::

  set default=0
  set fallback=1
  menuentry 'Boot CentOS from local disk hd0' {
   set root=(hd0,1)
   chainloader /efi/centos/grubx64.efi
  }
  menuentry 'Boot CentOS from local disk hd1' {
   set root=(hd1,1)
   chainloader /efi/centos/grubx64.efi
  }

The following method has been suggested, however, it does not seem to work and only returns to a malfunctional BIOS boot menu (tested on a Dell PC)::

  menuentry 'Boot from local disk' {
   exit
  }

.. _Grub: https://en.wikipedia.org/wiki/GNU_GRUB
.. _fallback: https://www.gnu.org/software/grub/manual/grub/html_node/fallback.html

Configuring Kickstart automated install
=======================================

EL Linux installation with Kickstart
----------------------------------------

RHEL_ Linux and EL clones such as AlmaLinux_ or RockyLinux_, as well as Fedora_, can be installed using Kickstart_.
See a general description from the Fedora page:

* Many system administrators would prefer to use an automated installation method to install Fedora_ or Red Hat Enterprise Linux on their machines.
  To answer this need, Red Hat created the Kickstart_ installation method.
  Using Kickstart_, a system administrator can create a single file containing the answers to all the questions that would normally be asked during a typical installation.

* Kickstart_ files can be kept on a server system and read by individual computers during the installation.
  This installation method can support the use of a single Kickstart_file_ to install Fedora_ or Red Hat Enterprise Linux on multiple machines,
  making it ideal for network and system administrators.

There is documentation of the Kickstart_file_ syntax.

A Kickstart_ installation can be made using PXE-booting_ or PXE_and_UEFI_ network booting.

An example Kickstart_file_ is
:download:`ks-almalinux-8.8-minimal-x86_64.cfg <attachments/ks-almalinux-8.8-minimal-x86_64.cfg>`.

.. _Kickstart: https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html#chapter-1-introduction
.. _Kickstart_file: https://anaconda-installer.readthedocs.io/en/latest/kickstart.html
.. _RHEL: https://en.wikipedia.org/wiki/Red_Hat_Enterprise_Linux
.. _AlmaLinux: https://almalinux.org/
.. _RockyLinux: https://www.rockylinux.org
.. _Fedora: https://fedoraproject.org/

Automated installation using Anaconda_ is possible with UEFI as well as PXE legacy booting.
In the above ``grub.cfg`` file use:

* ``inst.ks=`` Gives the location of a Kickstart_ file to be used to automate the installation.

For example, the following menu item may be added to ``grub.cfg`` to download a Kickstart_ file ``ks-almalinux-8.8-minimal-x86_64.cfg``
from the NFS server at IP address ``<server-IP>``::

  menuentry 'AlmaLinux 8.8 minimal Kickstart' --class centos --class gnu-linux --class gnu --class os --unrestricted {
    linuxefi (tftp)/AlmaLinux-8.8-x86_64/vmlinuz ip=dhcp inst.ks=nfs:nfsvers=3:<server-IP>:/u/kickstart/ks-almalinux-8.8-minimal-x86_64.cfg
    initrdefi (tftp)/AlmaLinux-8.8-x86_64/initrd.img
  }

A Legacy PXE BIOS boot file ``/tftpboot/pxelinux.cfg/default`` example using the same Kickstart_ file is::

  label AlmaLinux8.8 minimal-x86_64
        menu label Clean AlmaLinux-8.8-x86_64, minimal install
        kernel AlmaLinux-8.8-x86_64/vmlinuz
        append load_ramdisk=1 initrd=AlmaLinux-8.8-x86_64/initrd.img network inst.ks=nfs:nfsvers=3:<server-IP>:/u/kickstart/ks-almalinux-8.8-minimal-x86_64.cfg vga=792

(Setting up an NFS server at ``<server-IP>`` is not discussed here.)

.. _Anaconda: https://fedoraproject.org/wiki/Anaconda

Bootloader command
------------------

The bootloader_ command (required) specifies how the boot loader should be installed.

You should always use a password to protect your boot loader. An unprotected boot loader can allow a potential attacker to modify the system’s boot options and gain unauthorized access to the system:

* --password=

  If using GRUB2_ as the boot loader, sets the boot loader password to the one specified with this option.
  This should be used to restrict access to the GRUB2_ shell, where arbitrary kernel options can be passed.
  If a password is specified, GRUB2_ will also ask for a user name.
  The user name is always **root**.

* --iscrypted

  Normally, when you specify a boot loader password using the --password= option, it will be stored in the Kickstart file in plain text.
  If you want to encrypt the password, use this option and an encrypted password.

  To generate an encrypted password, use the::

    grub2-mkpasswd-pbkdf2

  command, enter the password you want to use, and copy the command’s output (the hash starting with ``grub.pbkdf2``) into the Kickstart file.
  An example bootloader_ Kickstart entry with an encrypted password will look similar to the following::

    bootloader --iscrypted --password=grub.pbkdf2.sha512.10000.5520C6C9832F3AC3D149AC0B24BE69E2D4FB0DBEEDBD29CA1D30A044DE2645C4C7A291E585D4DC43F8A4D82479F8B95CA4BA4381F8550510B75E8E0BB2938990.C688B6F0EF935701FF9BD1A8EC7FE5BD2333799C98F28420C5CC8F1A2A233DE22C83705BB614EA17F3FDFDF4AC2161CEA3384E56EB38A2E39102F5334C47405E

Some systems require a special partition for installing the boot loader. The type and size of this partition depends on whether the disk you are installing the boot loader to uses the Master Boot Record (MBR) or a GUID Partition Table (GPT) schema. For more information, see Boot Loader Installation.

.. _bootloader: https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html#bootloader

Installation screen resolution
------------------------------

If you have an old server or PC where the VGA graphics adapter only supports screen resolutions up to 1024x768 or 1280x1024,
then the kernel in EL8 Linux may select a higher, unsupported screen resolution which gives a flickering monitor with no image!
See these pages:

* https://www.systutorials.com/configuration-of-linux-kernel-video-mode/
* https://cromwell-intl.com/open-source/grub-vga-modes.html
* http://pierre.baudu.in/other/grub.vga.modes.html

You can add a vga= directive to the kernel line in the GRUB file, something like the following::

  linuxefi /vmlinuz-X.Y.Z vga=792 

You will, of course, see something specific in place of X.Y.Z and you can use numbers other than 792, which gives 1024×768 with 65,536 possible colors. 
This is a partial list of GRUB VGA Modes::

  Colour depth	640x480	1024x768
  8 (256)	769	773
  15 (32K)	784	790
  16 (65K)	785	791
  24 (16M)	786	792

Linux kernel with 16-bit boot protocol
......................................

From https://www.systutorials.com/configuration-of-linux-kernel-video-mode/

Switching VESA modes of Linux kernel at boot time can be done by using the “vga=…“ kernel boot parameter. 
This parameter accept the decimal value of Linux video mode numbers instead of VESA video mode numbers. 

The video mode number of the Linux kernel is the VESA mode number plus 0×200::

  Linux_kernel_mode_number = VESA_mode_number + 0x200

So the table for the Kernel mode numbers are::

      | 640x480  800x600  1024x768 1280x1024
  ----+-------------------------------------
  256 |  0x301    0x303    0x305    0x307
  32k |  0x310    0x313    0x316    0x319
  64k |  0x311    0x314    0x317    0x31A
  16M |  0x312    0x315    0x318    0x31B

The decimal value of the Linux kernel video mode number can be passed to the kernel in the form “vga=YYY“, where YYY is the decimal value.

The parameter **vga=ask** is often mentioned, but is not supported by GRUB2_.

Last, calculate the decimal value of the Linux video mode number. 
This simple python command can be used to convert a hex-number 0xYYY::

  python -c "print 0xYYY"

Boot disk device selection
--------------------------

The server or PC computer may have multiple disk devices, and each device may have different bus interfaces to the system such as NVME_ or SATA_.

When the Kickstart_ installation starts up, the file given by *inst.ks* must select, format and partition the system boot disk.
However, you do not want to install the Linux OS on a large disk device which should be used for data storage!
Another problem is that NVME_ and SATA_ devices have different device names in the Linux kernel, for example:

* SATA_: /dev/sda 
* NVME_: /dev/nvme0n1

and the correct device name must be given to Kickstart_.

A nice and flexible solution to this issue is given in the thread https://access.redhat.com/discussions/3144131.
You configure an *%include* line where you normally partition the disk::

  # The file /tmp/part-include is created below in the %pre section
  %include /tmp/part-include
  %packages
  %end

Then you define a `pre-install <https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html#chapter-4-pre-installation-script>`_ 
section with *%pre*, here with a number of improvements::

  # Start of the %pre section with logging into /root/ks-pre.log
  %pre --log=/root/ks-pre.log
  # pick the first drive that is not removable and is over MINSIZE
  DIR="/sys/block"
  # minimum and maximum size of hard drive needed specified in GIGABYTES
  MINSIZE=100
  MAXSIZE=1200
  # The loop first checks NVME then SATA/SAS drives:
  for d in $DIR/nvme* $DIR/sd*
  do
    DEV=`basename "$d"`
    if [ -d $DIR/$DEV ]; then
      # Note: the removable file may have an incorrect value:
      if [[ "`cat $DIR/$DEV/removable`" = "0" ]]
      then
        # /sys/block/*/size is in 512 byte chunks
        GB=$((`cat $DIR/$DEV/size`/2**21))
        echo "Disk device $DEV has size $GB GB"
        if [ $GB -gt $MINSIZE -a $GB -lt $MAXSIZE -a -z "$ROOTDRIVE" ]
        then
          ROOTDRIVE=$DEV
          echo "Select ROOTDRIVE=$ROOTDRIVE"
        fi
      fi
    fi
  done
  
  if [ -z "$ROOTDRIVE" ]
  then
        echo "ERROR: ROOTDRIVE is undefined"
  else
        echo "ROOTDRIVE=$ROOTDRIVE"
        cat << EOF > /tmp/part-include
  zerombr
  clearpart --drives=$ROOTDRIVE --all --initlabel
  ignoredisk --only-use=$ROOTDRIVE
  reqpart --add-boot
  part swap --size 32768 --asprimary
  part pv.01 --fstype xfs --size=1 --grow --asprimary
  volgroup VolGroup00 pv.01
  logvol / --fstype xfs --name=lv_root --vgname=VolGroup00 --size=32768
  EOF
  fi
  %end

**WARNING:** We have some old Intel Xeon Nehalem servers with SATA disks where ``/sys/block/sda/removable`` contains an incorrect value of 1!

.. _NVME: https://en.wikipedia.org/wiki/NVM_Express
.. _SATA: https://en.wikipedia.org/wiki/Serial_ATA

Capture the %pre logfile
------------------------

The %pre command can create a logfile::

  # Start of the %pre section with logging into /root/ks-pre.log
  %pre --log=/root/ks-pre.log

but since this exists only in the memory file system, the logfile is lost after the system has rebooted.

There are methods to get a copy of the %pre logfile:

* https://unix.stackexchange.com/questions/78388/logging-pre-during-kickstart-logfile-doesnt-exist-after-boot

Disk partitions
---------------

With UEFI_ systems it is **required** to configure a special partition::

  /boot/efi

in your Kickstart_ file.
See also:

* https://access.redhat.com/solutions/1369253
* https://fedoraproject.org/wiki/Anaconda/Kickstart#bootloader

It is most convenient to configure boot partitions using reqpart_: 

* Automatically create partitions required by your hardware platform. These include a /boot/efi for x86_64 and Aarch64 systems with UEFI firmware, biosboot for x86_64 systems with BIOS firmware and GPT, and PRePBoot for IBM Power Systems.

.. _reqpart: https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html#reqpart

An example Kickstart_ file section about disk partitions and using reqpart_ may be::

  reqpart --add-boot
  part swap --size 50000 --asprimary
  part pv.01 --fstype xfs --size=1 --grow --asprimary
  volgroup VolGroup00 pv.01
  logvol / --fstype xfs --name=lv_root --vgname=VolGroup00 --size=32768

Disable Secure Boot in BIOS
---------------------------

If the PXE client system BIOS is configured for UEFI_ Secure_Boot_
then the PXE boot will fail with an error about an **invalid signature**.

As explained in `Installation of RHEL8 on UEFI system with Secure Boot enabled fails with error 'invalid signature' on vmlinuz <https://access.redhat.com/solutions/3771941>`_
RedHat is currently working on a solution for RHEL 8.

**Workaround:** Disable secureboot from BIOS settings.

.. _Secure_Boot: https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface#SECURE-BOOT

efibootmgr - manipulate the EFI Boot Manager
============================================

efibootmgr_ is a userspace application used to modify the Intel Extensible Firmware Interface (EFI) Boot Manager.  
This application can create and destroy boot entries, change the boot order, change the next running boot option, and more.

To show the current boot order::

  efibootmgr -v

Some useful command options (see the efibootmgr_ page)::

        -n | --bootnext XXXX   set BootNext to XXXX (hex)
        -N | --delete-bootnext delete BootNext
        -o | --bootorder XXXX,YYYY,ZZZZ,...     explicitly set BootOrder (hex)
        -O | --delete-bootorder   delete BootOrder

.. _efibootmgr: https://github.com/rhboot/efibootmgr

UEFI network boot process
=========================

When a client computer performs an UEFI network boot process, it will first be assigned an IP address and a bootfile name by the DHCP server as described above.

The network adapter will then attempt downloading boot files as well as ``grub.cfg`` files by TFTP.
However, the download process does not seem to be documented anywhere!

We have observed that the following TFTP file downloads are attempted by the UEFI boot code (rather similar to the BIOS download process):

1. Bootfile ``shimx64.efi`` (or similar).

Then download by TFTP of ``grub.cfg`` files are attempted in the following order:

2. MAC-address (**lower-case** hexadecimal numbers) file ``uefi/grub.cfg-01-ac-1f-6b-f5-a3-0e`` (for example)
3. IP-address (**UPPER-CASE** hexadecimal numbers) file ``uefi/grub.cfg-0A028215`` (for example)
4. IP-address stripping off the trailing digits in item 3 one at a time.
5. Finally ``uefi/grub.cfg``

The first match of a ``grub.cfg`` file will then be booted.

Hint: Use ``gethostip`` from the ``syslinux`` package to convert hostnames and IP-addresses to hexadecimal, for example::

  $ gethostip -f s001
  s001.(domainname) 10.2.130.21 0A028215
  $ gethostip -x s001
  0A028215
