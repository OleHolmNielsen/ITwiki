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

See also our network :ref:`PXE-booting` page for Linux OS installation, and also these useful pages:

* https://www.gnu.org/software/grub/manual/grub/grub.html
* https://fedoraproject.org/wiki/GRUB_2
* https://help.ubuntu.com/community/Grub2/Passwords
* https://wiki.fogproject.org/wiki/index.php/BIOS_and_UEFI_Co-Existence
* https://github.com/quattor/aii/issues/216
* UEFI security: `UEFI DEFENSIVE PRACTICES GUIDANCE <https://www.nsa.gov/portals/75/documents/what-we-do/cybersecurity/professional-resources/ctr-uefi-defensive-practices-guidance.pdf>`_.

.. _CentOS: https://www.centos.org/
.. _PXE: https://en.wikipedia.org/wiki/Preboot_Execution_Environment
.. _TFTP: https://en.wikipedia.org/wiki/Trivial_File_Transfer_Protocol
.. _DHCP: https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol
.. _UEFI: https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface
.. _Legacy_BIOS_boot: https://en.wikipedia.org/wiki/Legacy_mode
.. _PXE-booting: https://wiki.fysik.dtu.dk/niflheim/PXE-booting
.. _GRUB2: https://fedoraproject.org/wiki/GRUB_2

Setting up the DHCP and PXE server
==================================

Enable UEFI support in the DHCP server
--------------------------------------

We assume that you have a Linux DHCP_ server.
Add the following to the configuration file ``/etc/dhcp/dhcpd.conf`` in the top (global) section::

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

In the DHCP_ subnet section(s) define UEFI_ RFC4578_ or PXE_ (legacy) boot image types in the ``/tftpboot/uefi/`` subdirectory::

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
  will cause the client host PXE_ to download all further files also from that same ``uefi/`` subdirectory, so you need to place other files there.

* **Probably obsolete:** The ``shimx64.efi`` bootloader_ may be required in stead of ``BOOTX64.EFI`` in the above ``/etc/dhcp/dhcpd.conf``.

Copy UEFI boot files
--------------------

We create a special directory for UEFI_ boot files on the TFTP_ server::

  mkdir /var/lib/tftpboot/uefi
  ln -s /var/lib/tftpboot/uefi /tftpboot/uefi

The OS installation ``*.efi`` files **must** be copied from the OS installation image,
since the versions contained in EL8 RPM packages seem to be buggy,
see for example https://forums.rockylinux.org/t/pxe-boot-uefi-mode/4852.
Symptoms may be that TFTP_ download of large ``vmlinuz`` or ``initrd.img`` files 
during Kickstart fail with a message *error: timeout reading ...*.

Download **all .efi files** from a mirror site, 
for example the AlmaLinux_ mirror at https://mirror.fysik.dtu.dk/linux/almalinux/8/BaseOS/x86_64/kickstart/EFI/BOOT/
to the TFTP_ server's folder ``/tftpboot/uefi/``.

Download Linux boot images
-----------------------------

For each EL Linux (and other OS) version you should copy Linux boot images to a separate directory on the TFTP_ server,
for example, for AlmaLinux_ 8.10::

  mkdir /var/lib/tftpboot/AlmaLinux-8.10-x86_64/

In this directory create the following ``Makefile``::

  OS=almalinux
  VERSION=8.10
  MIRROR=https://mirror.fysik.dtu.dk/linux
  default:
        @echo "NOTE: Boot images are from ${OS} version ${VERSION}"
        @wget --timestamping ${MIRROR}/${OS}/${VERSION}/BaseOS/x86_64/os/images/pxeboot/initrd.img
        @wget --timestamping ${MIRROR}/${OS}/${VERSION}/BaseOS/x86_64/os/images/pxeboot/vmlinuz

and run a ``make`` command to download the boot image files.
Other mirror sites may be used in stead of *mirror.fysik.dtu.dk*,
and other versions of ``OS`` and ``VERSION``.

Create a grub.cfg file
-----------------------------

The ``uefi/BOOTX64.EFI`` boot file will be looking for a GRUB2_/Grub_ configuration file ``uefi/grub.cfg`` in the same subdirectory.
Create the file ``/var/lib/tftpboot/uefi/grub.cfg`` with the contents::

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
  set timeout=60
  menuentry 'AlmaLinux 8.10 minimal Kickstart' --class centos --class gnu-linux --class gnu --class os --unrestricted {
    # Note: IPv6 disable during initial boot:
    linuxefi (tftp)/AlmaLinux-8.10-x86_64/vmlinuz ip=dhcp inst.ks=nfs:nfsvers=3:130.225.86.3:/u/kickstart/ks-rockylinux-8-minimal-x86_64.cfg ipv6.disable=1
    initrdefi (tftp)/AlmaLinux-8.10-x86_64/initrd.img
  }

Additional menu entries may be appended to the above, for example::

  menuentry 'AlmaLinux 9.6 minimal Kickstart' --class centos --class gnu-linux --class gnu --class os --unrestricted {
    linuxefi (tftp)/AlmaLinux-9.6-x86_64/vmlinuz ip=dhcp inst.ks=nfs:nfsvers=3:130.225.86.3:/u/kickstart/ks-rockylinux-9-minimal-x86_64.cfg ipv6.disable=1
    initrdefi (tftp)/AlmaLinux-9.6-x86_64/initrd.img
  }

It is useful to have a ``grub.cfg`` menu item from the TFTP_ server which allows to boot the system from an existing OS installation on disk.
This should be the default menu item.
To boot a CentOS system with ``grubx64.efi`` (provided by the ``grub2-efi-x64`` package) in the 1st partition of the first disk hd0::

  menuentry 'Useless: Boot from local disk' {
    # Undocumented "exit" command.  Returns to BIOS boot menu on Dell 9020
    exit
  }

The ``.efi`` files of other Linux distributions will be in different subdirectories of ``/boot/efi/EFI``.

If there are multiple disks in the server, Grub_ will label them as *hd0, hd1, hd2*, etc.
It seems that the numbering of such disks may vary, and if the OS installation is suddenly in disk *hd1* in stead of *hd0*,
it is useful to define a fallback_ boot menu item as in this example::

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

.. _Grub: https://en.wikipedia.org/wiki/GNU_GRUB
.. _fallback: https://www.gnu.org/software/grub/manual/grub/html_node/fallback.html

=======================================================================================================

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

A Kickstart_ installation can be made using :ref:`PXE-booting` or PXE_and_UEFI_ network booting.

.. _Kickstart: https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html#chapter-1-introduction
.. _Kickstart_file: https://anaconda-installer.readthedocs.io/en/latest/kickstart.html
.. _RHEL: https://en.wikipedia.org/wiki/Red_Hat_Enterprise_Linux
.. _AlmaLinux: https://almalinux.org/
.. _RockyLinux: https://www.rockylinux.org
.. _Fedora: https://fedoraproject.org/

Automated installation using Anaconda_ is possible with UEFI_ as well as PXE_ legacy booting.
In the above ``grub.cfg`` file use:

* ``inst.ks=`` Gives the location of a Kickstart_ file to be used to automate the installation.

For example, the following menu item may be added to ``grub.cfg`` to download a Kickstart_ file ``ks-almalinux-8.10-minimal-x86_64.cfg``
from the NFS server at IP address ``<server-IP>``::

  menuentry 'AlmaLinux 8.10 minimal Kickstart' --class centos --class gnu-linux --class gnu --class os --unrestricted {
    linuxefi (tftp)/AlmaLinux-8.10-x86_64/vmlinuz ip=dhcp inst.ks=nfs:nfsvers=3:<server-IP>:/u/kickstart/ks-almalinux-8.10-minimal-x86_64.cfg
    initrdefi (tftp)/AlmaLinux-8.10-x86_64/initrd.img
  }

A Legacy PXE_ BIOS boot file ``/tftpboot/pxelinux.cfg/default`` example using the same Kickstart_ file is::

  label AlmaLinux8.10 minimal-x86_64
        menu label Clean AlmaLinux-8.10-x86_64, minimal install
        kernel AlmaLinux-8.10-x86_64/vmlinuz
        append load_ramdisk=1 initrd=AlmaLinux-8.10-x86_64/initrd.img network inst.ks=nfs:nfsvers=3:<server-IP>:/u/kickstart/ks-almalinux-8.10-minimal-x86_64.cfg vga=792

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
* https://pierre.baudu.in/other/grub.vga.modes.html

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

From https://www.systutorials.com/configuration-of-linux-kernel-video-mode/ we see:

* Switching VESA modes of Linux kernel at boot time can be done by using the “vga=…“ kernel boot parameter. 
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

The parameter ``vga=ask`` is often mentioned, but is not supported by GRUB2_.

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

**WARNING:** We have some old Intel Xeon Nehalem_ servers with SATA disks where ``/sys/block/sda/removable`` contains an incorrect value of 1!

.. _NVME: https://en.wikipedia.org/wiki/NVM_Express
.. _SATA: https://en.wikipedia.org/wiki/Serial_ATA
.. _Nehalem: https://en.wikipedia.org/wiki/Nehalem_(microarchitecture)

Capture the %pre logfile
------------------------

The ``%pre`` command can create a logfile::

  # Start of the %pre section with logging into /root/ks-pre.log
  %pre --log=/root/ks-pre.log

but since this exists only in the memory file system, the logfile is lost after the system has rebooted.

There are methods to get a copy of the ``%pre`` logfile:

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

* Automatically create partitions required by your hardware platform.
  These include a /boot/efi for x86_64 and Aarch64 systems with UEFI_ firmware,
  biosboot for x86_64 systems with BIOS firmware and GPT, and PRePBoot for IBM Power Systems.

.. _reqpart: https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html#reqpart

An example Kickstart_ file section about disk partitions and using reqpart_ may be::

  reqpart --add-boot
  part swap --size 50000 --asprimary
  part pv.01 --fstype xfs --size=1 --grow --asprimary
  volgroup VolGroup00 pv.01
  logvol / --fstype xfs --name=lv_root --vgname=VolGroup00 --size=32768

Disable Secure Boot in BIOS
---------------------------

If the PXE_ client system BIOS is configured for UEFI_ Secure_Boot_
then the PXE_ boot will fail with an error about an **invalid signature**.

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

=======================================================================================================

UEFI network boot process
=========================

In this section we describe how a computer doing an UEFI_ PXE_ boot will download a GRUB2_ bootfile
from the network server and execute it.
Please note:

- This GRUB2_ information has been copied from the local Linux ``grub.html`` manual's `Network` section in ``/usr/share/doc/grub2-common/grub.html``
  because the `original manual <https://www.gnu.org/software/grub/manual/grub/html_node/Network.html>`_ from `gnu.org` is frequently inaccessible.
  Make sure that the package ``grub2-common`` containing the ``grub.html`` file has been installed on your PC.

- The ``grub.cfg`` file is placed in the same directory as the path output by ``grub-mknetdir`` hereafter referred to as ``(FWPATH)``.
  Note: Our setup uses ``FWPATH=/tftpboot/uefi``.

The PXE_ bootloader image ``/tftpboot/uefi/BOOTX64.EFI`` executing in the computer's Ethernet_ NIC adapter
will search for GRUB2_ configuration files in order using the following rules,
where the appended value corresponds to a value on the client machine::

  (FWPATH)/grub.cfg-(UUID OF NIC)
  (FWPATH)/grub.cfg-(MAC ADDRESS OF NIC)
  (FWPATH)/grub.cfg-(IPv4 OR IPv6 ADDRESS)
  (FWPATH)/grub.cfg

Hint: Use the ``gethostip`` command from the syslinux_ RPM package to convert hostnames and IP-addresses to hexadecimal, for example::

  $ gethostip -f s001
  s001.(domainname) 10.2.130.21 0A028215
  $ gethostip -x s001
  0A028215

The client will only attempt to look up an IPv6_ address config once, however, it will try the IPv4_ address multiple times.
The first file in this list which can be downloaded successfully will be used for network booting.
The concrete example below shows what would happen under the IPv4_ case:

* UUID_: 7726a678-7fc0-4853-a4f6-c85ac36a120a
* MAC_address_:  52:54:00:ec:33:81
* IP_address_: 10.0.0.130 (Hexadecimal_ digits: 0A000082)

The GRUB2_ bootloader will attempt TFTP_ download of this list of configuration files in order::

  (FWPATH)/grub.cfg-7726a678-7fc0-4853-a4f6-c85ac36a120a
  (FWPATH)/grub.cfg-52-54-00-ec-33-81
  (FWPATH)/grub.cfg-0A000082
  (FWPATH)/grub.cfg-0A00008
  (FWPATH)/grub.cfg-0A0000
  (FWPATH)/grub.cfg-0A000
  (FWPATH)/grub.cfg-0A00
  (FWPATH)/grub.cfg-0A0
  (FWPATH)/grub.cfg-0A
  (FWPATH)/grub.cfg-0
  (FWPATH)/grub.cfg

After GRUB2_ has started, files on the TFTP server will be accessible via the ``(tftp)`` device.

The server IP_address_ can be controlled by changing the ``(tftp)`` device name to ``(tftp,server-ip)``.
Note that this should be changed both in the prefix and in any references to the device name in the configuration file.

.. _IPv4: http://en.wikipedia.org/wiki/Ipv4
.. _IPv6: http://en.wikipedia.org/wiki/Ipv6
.. _IP_address: https://en.wikipedia.org/wiki/IP_address
.. _Ethernet: https://en.wikipedia.org/wiki/Ethernet
.. _MAC_address: https://en.wikipedia.org/wiki/MAC_address
.. _UUID: https://en.wikipedia.org/wiki/Universally_unique_identifier
.. _Hexadecimal: https://en.wikipedia.org/wiki/Hexadecimal
.. _syslinux: https://en.wikipedia.org/wiki/SYSLINUX
