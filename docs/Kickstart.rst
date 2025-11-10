.. _Kickstart_installation_of_EL_Linux_systems:

============================================
Kickstart installation of EL Linux systems
============================================

.. contents::

Configuring Kickstart 
======================

Linux OS installation of RHEL_ Linux and *EL clones* (AlmaLinux_, RockyLinux_, and more),
as well as Fedora_,
can be made using the automated Kickstart_ method.
There is a general description from the Fedora_ page:

* Many system administrators would prefer to use an automated installation method to install Fedora_ or RHEL_ on their machines.
  To answer this need, Red Hat created the Kickstart_ installation method.
  Using Kickstart_, a system administrator can create a single file containing the answers to all the questions that would normally be asked during a typical installation.

* A Kickstart_file_ can be kept on a server system and read by individual computers during the installation.
  This installation method can support the use of a single Kickstart_file_ to install Fedora_ or RHEL_ on multiple machines,
  making it ideal for network and system administrators.

=======================================================================================================

Automated Kickstart installation
-----------------------------------

Automated installation with PXE_ and Anaconda_ is possible using either UEFI_ or legacy BIOS_ booting.
You can network boot by either of these methods:

1. Configure the node's **boot order** with PXE_ network booting as the first boot device, or

2. When powering up the client computer, PXE_ network booting can be selected using the console,
   typically by pressing the F12 or F10 Function_key_ as shown in the console.

If you have configured :ref:`Automated_network_installation_with_pxeconfig`,
you can use pxeconfig_ to setup the client boot process.
Then it is sufficient to power cycle and/or start up the client computer for an automatic installation.

The :ref:`UEFI_network_boot` ensures that:

* Kickstart_ OS installation will be performed automatically.
* The installation process can be viewed in the node's console (physically or in the BMC_ web browser window).
* The Kickstart_ method described above therefore provides a **totally automatic and hands-free** Linux OS installation of nodes,
  suitable for a large Linux cluster and other scenarios.

.. _Kickstart: https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html#chapter-1-introduction
.. _Kickstart_file: https://anaconda-installer.readthedocs.io/en/latest/kickstart.html
.. _pxeconfig_toolkit: https://gitlab.com/surfsara/pxeconfig
.. _pxeconfig: https://gitlab.com/surfsara/pxeconfig/-/blob/master/src/pxeconfig.py
.. _Grub: https://en.wikipedia.org/wiki/GNU_GRUB
.. _RHEL: https://en.wikipedia.org/wiki/Red_Hat_Enterprise_Linux
.. _AlmaLinux: https://almalinux.org/
.. _RockyLinux: https://www.rockylinux.org
.. _Fedora: https://fedoraproject.org/
.. _BMC: https://en.wikipedia.org/wiki/Intelligent_Platform_Management_Interface#Baseboard_management_controller
.. _Function_key: https://en.wikipedia.org/wiki/Function_key

=======================================================================================================

Creating a Kickstart file
-------------------------------

A Kickstart_file_ is required for configuration of the installation process.
In the following sections we discuss this file.

The :ref:`UEFI_network_boot` involves a file ``grub.cfg``.
In this file you can use the inst.ks_ parameter to specify the location
(on the network, for example) of the Kickstart_file_ that you want to use.
As an example, the following menu item may be added to the ``grub.cfg`` file 
to download a Kickstart_file_ named ``ks-almalinux-8.10-minimal-x86_64.cfg``
from the NFS_ (version 3) server at IP address ``10.10.10.3``::

  menuentry 'AlmaLinux 8.10 minimal Kickstart' --class centos --class gnu-linux --class gnu --class os --unrestricted {
    linuxefi (tftp)/AlmaLinux-8.10-x86_64/vmlinuz ip=dhcp inst.ks=nfs:nfsvers=3:10.10.10.3:/u/kickstart/ks-almalinux-8.10-minimal-x86_64.cfg
    initrdefi (tftp)/AlmaLinux-8.10-x86_64/initrd.img
  }

Setting up an NFS_ server is not discussed here, however.
Additional example files can be found in https://github.com/OleHolmNielsen/ansible/tree/master/roles/pxeconfigd/files

A Legacy PXE_ BIOS_ boot file ``/tftpboot/pxelinux.cfg/default`` example using the same Kickstart_file_ is::

  label AlmaLinux8.10 minimal-x86_64
        menu label Clean AlmaLinux-8.10-x86_64, minimal install
        kernel AlmaLinux-8.10-x86_64/vmlinuz
        append load_ramdisk=1 initrd=AlmaLinux-8.10-x86_64/initrd.img network inst.ks=nfs:nfsvers=3:<server-IP>:/u/kickstart/ks-almalinux-8.10-minimal-x86_64.cfg vga=792

.. _Anaconda: https://fedoraproject.org/wiki/Anaconda
.. _inst.ks: https://docs.fedoraproject.org/en-US/fedora/f36/install-guide/advanced/Boot_Options/#sect-boot-options-kickstart
.. _NFS: https://en.wikipedia.org/wiki/Network_File_System
.. _PXE: https://en.wikipedia.org/wiki/Preboot_Execution_Environment
.. _BIOS: https://en.wikipedia.org/wiki/BIOS
.. _UEFI: https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface
.. _bootloader: https://en.wikipedia.org/wiki/Bootloader
.. _GRUB2: https://fedoraproject.org/wiki/GRUB_2
.. _Linux_kernel: https://en.wikipedia.org/wiki/Linux_kernel

Bootloader command
------------------

The Kickstart_file_ bootloader_command_ (required) specifies how the bootloader_ should be installed.

You should always use a password to protect your bootloader_.
An unprotected bootloader_ can allow a potential attacker to modify the system’s boot options and gain unauthorized access to the system:

* ``--password`` 
  If using GRUB2_ as the bootloader_, this sets the bootloader_ password to the one specified.
  This should be used to restrict access to the GRUB2_ shell, where arbitrary Linux_kernel_ options can be passed.
  If a password is specified, GRUB2_ will also ask for a user name, and that user name is always ``root``.

* ``--iscrypted`` 
  Normally, when you specify a bootloader_ password using the ``--password=`` option,
  it will be stored in the Kickstart_file_ in plain text,
  but you may use this option to specify an encrypted password.
  To generate an encrypted password use the command::

    grub2-mkpasswd-pbkdf2

  Enter the password you want to use, and copy the command’s output (the hash starting with ``grub.pbkdf2``) into the Kickstart_file_.
  An example bootloader_ Kickstart_ entry with an encrypted password will look similar to the following::

    bootloader --iscrypted --password=grub.pbkdf2.sha512.10000.5520C6C9832F3AC3D149AC0B24BE69E2D4FB0DBEEDBD29CA1D30A044DE2645C4C7A291E585D4DC43F8A4D82479F8B95CA4BA4381F8550510B75E8E0BB2938990.C688B6F0EF935701FF9BD1A8EC7FE5BD2333799C98F28420C5CC8F1A2A233DE22C83705BB614EA17F3FDFDF4AC2161CEA3384E56EB38A2E39102F5334C47405E

Some systems require a special partition for installing the bootloader_.
The type and size of this partition depends on whether the disk you are installing the bootloader_ to uses the Master Boot Record (MBR) or a GUID Partition Table (GPT) schema.
For more information, see the bootloader_ page.

.. _bootloader_command: https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html#bootloader

Automatic boot disk device selection 
---------------------------------------

The client computer may have multiple disk devices, and each device may have different bus interfaces to the system such as NVME_ or SATA_.

When the Kickstart_ installation starts up, the file given by inst.ks_ must select, format and partition the system boot disk.
However, you do not want to install the Linux OS on a large disk device which might be used only for data storage!
Another problem is that NVME_ and SATA_ devices have different device names in the Linux_kernel_, for example:

* SATA_: /dev/sda 
* NVME_: /dev/nvme0n1

and the correct device name must be given to Kickstart_.

A nice and flexible solution to this issue is given in the thread https://access.redhat.com/discussions/3144131.
You configure a Kickstart_file_ ``%include`` line where you would traditionally partition the disk::

  # The file /tmp/part-include is created below in the %pre section
  %include /tmp/part-include
  %packages
  %end

Then you define a pre-install_ section with ``%pre``, here adding a number of improvements::

  # Start of the %pre section with logging into /root/ks-pre.log
  %pre --log=/root/ks-pre.log
  # pick the first drive that is not removable and is over MINSIZE
  DIR="/sys/block"
  # minimum and maximum size of hard drive needed specified in GIGABYTES
  MINSIZE=100
  MAXSIZE=1999
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
.. _pre-install: https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html#chapter-4-pre-installation-script
.. _Nehalem: https://en.wikipedia.org/wiki/Nehalem_(microarchitecture)

Disk partitions
---------------

With UEFI_ systems it is **required** to configure a special ``/boot/efi`` partition in your Kickstart_file_,
see also:

* https://access.redhat.com/solutions/1369253
* https://fedoraproject.org/wiki/Anaconda/Kickstart#bootloader

It is most convenient to configure boot partitions using reqpart_: 

* Automatically create partitions required by your hardware platform.
  These include a ``/boot/efi`` for x86_64 and Aarch64 systems with UEFI_ firmware,
  ``biosboot`` for x86_64 systems with BIOS_ firmware and GPT, and ``PRePBoot`` for IBM Power Systems.

An example Kickstart_file_ section specifying disk partitions and using reqpart_ may be::

  reqpart --add-boot
  part swap --size 50000 --asprimary
  part pv.01 --fstype xfs --size=1 --grow --asprimary
  volgroup VolGroup00 pv.01
  logvol / --fstype xfs --name=lv_root --vgname=VolGroup00 --size=32768

.. _reqpart: https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html#reqpart

Capture the %pre logfile
------------------------

The Kickstart_file_ ``%pre`` command can create a logfile::

  # Start of the %pre section with logging into /root/ks-pre.log
  %pre --log=/root/ks-pre.log

However, this file exists **only in the memory file system** during installation,
and the logfile will be lost after the system has rebooted.

There are methods to get a copy of the ``%pre`` logfile:

* https://unix.stackexchange.com/questions/78388/logging-pre-during-kickstart-logfile-doesnt-exist-after-boot

Installation screen resolution
------------------------------

If you have an old server or PC where the VGA_ graphics adapter only supports screen resolutions up to 1024x768 or 1280x1024,
then the Linux_kernel_ EL8 may select a higher, unsupported screen resolution which gives a flickering monitor with no image!
See these pages:

* https://www.systutorials.com/configuration-of-linux-kernel-video-mode/
* https://cromwell-intl.com/open-source/grub-vga-modes.html
* https://pierre.baudu.in/other/grub.vga.modes.html

You can add a vga= directive to the Linux_kernel_ line in the GRUB file, something like the following::

  linuxefi /vmlinuz-X.Y.Z vga=792 

(X.Y.Z is your version)
and you can use numbers other than ``792`` which would give a resolution of 1024×768 with 65,536 possible colors. 
This is a partial list of the GRUB_ VGA_ Modes::

  Colour depth	640x480	1024x768
  8 (256)	769	773
  15 (32K)	784	790
  16 (65K)	785	791
  24 (16M)	786	792

.. _VGA: https://en.wikipedia.org/wiki/Video_Graphics_Array

Linux kernel with 16-bit boot protocol
......................................

From https://www.systutorials.com/configuration-of-linux-kernel-video-mode/ we see:

* Switching VESA_ modes of Linux_kernel_ at boot time can be done by using the “vga=…“ Linux_kernel_ parameter. 
  This parameter accept the decimal value of Linux video mode numbers instead of VESA_ video mode numbers. 

The video mode number of the Linux_kernel_ is the VESA_ mode number plus 0×200::

  Linux_kernel_mode_number = VESA_mode_number + 0x200

So the table for the Kernel mode numbers are::

      | 640x480  800x600  1024x768 1280x1024
  ----+-------------------------------------
  256 |  0x301    0x303    0x305    0x307
  32k |  0x310    0x313    0x316    0x319
  64k |  0x311    0x314    0x317    0x31A
  16M |  0x312    0x315    0x318    0x31B

The decimal value of the Linux_kernel_ video mode number can be passed to the kernel in the form “vga=YYY“, where YYY is the decimal value.

The parameter ``vga=ask`` is often mentioned, but is not supported by GRUB2_.

Last, calculate the decimal value of the Linux video mode number. 
This simple python command can be used to convert a hex-number 0xYYY::

  python -c "print 0xYYY"

.. _VESA: https://en.wikipedia.org/wiki/VESA_BIOS_Extensions
