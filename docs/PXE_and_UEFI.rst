.. _PXE_and_UEFI:

==================================
Install EL Linux via PXE and UEFI
==================================

.. Contents::

Overview
========

This *HowTo* guide documents how to install EL/RHEL_ Linux using PXE_ on a client host booting by UEFI_.
We will show how to support UEFI_ booting with PXE_, downloading files from your TFTP_ server.
See also our pages:

* :ref:`Kickstart_installation_of_EL_Linux_systems`.
* :ref:`PXE-booting` for Linux OS installation.

Other useful pages:

* https://www.gnu.org/software/grub/manual/grub/grub.html
* https://fedoraproject.org/wiki/GRUB_2
* https://help.ubuntu.com/community/Grub2/Passwords

UEFI security
-------------

There is an NSA Security Report
`UEFI DEFENSIVE PRACTICES GUIDANCE <https://media.defense.gov/2019/Jul/16/2002158107/-1/-1/0/CTR-UEFI-DEFENSIVE-PRACTICES-GUIDANCE.PDF>`_
with some recommendations:

* Machines running legacy BIOS_ or UEFI_ in compatibility mode should be migrated to UEFI_ native mode to take advantage of new features.
* UEFI_ should be secured using a set of administrator and user passwords appropriate for a device’s capabilities and intended use.
* Firmware comprising UEFI_ should be updated regularly and treated as importantly as Operating System (OS) updates.
* UEFI_ Secure Boot should be enabled and configured to audit firmware modules, expansion devices, and bootable OS images.
* *Trusted Platform Module* (TPM_) should be leveraged to check the integrity of UEFI_.

See also:

* `UEFI Secure Boot Customization <https://media.defense.gov/2023/Mar/20/2003182401/-1/-1/0/CTR-UEFI-SECURE-BOOT-CUSTOMIZATION-20230317.PDF>`_.
* `Hardware and Firmware Security Guidance <https://github.com/nsacyber/Hardware-and-Firmware-Security-Guidance>`_.

.. _PXE: https://en.wikipedia.org/wiki/Preboot_Execution_Environment
.. _TFTP: https://en.wikipedia.org/wiki/Trivial_File_Transfer_Protocol
.. _DHCP: https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol
.. _ISC_DHCP: http://www.isc.org/software/dhcp
.. _DHCP_Handbook: https://www.amazon.com/DHCP-Handbook-Ralph-Droms-Ph-D/dp/0672323273
.. _ISC_KEA: https://www.isc.org/kea/
.. _UEFI: https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface
.. _UEFI_specification: https://uefi.org/sites/default/files/resources/UEFI_Spec_Final_2.11.pdf
.. _BIOS: https://en.wikipedia.org/wiki/BIOS
.. _Legacy_BIOS_boot: https://en.wikipedia.org/wiki/Legacy_mode
.. _TPM: https://en.wikipedia.org/wiki/Trusted_Platform_Module
.. _GRUB2: https://fedoraproject.org/wiki/GRUB_2
.. _NFS: https://en.wikipedia.org/wiki/Network_File_System
.. _EPEL: https://fedoraproject.org/wiki/EPEL
.. _RHEL: https://en.wikipedia.org/wiki/Red_Hat_Enterprise_Linux
.. _AlmaLinux: https://almalinux.org/
.. _RockyLinux: https://www.rockylinux.org
.. _Fedora: https://fedoraproject.org/

=======================================================================================================

.. _UEFI_network_boot:

UEFI network boot process
=========================

In this section we describe how a computer doing an UEFI_ network PXE_ boot will download a bootloader_ image file
from the network's TFTP_ server and execute it.
For 64-bit UEFI_ systems with the x86-64_ architecture,
the boot file name by convention is ``BOOTX64.EFI``,
but other bootloader_ images such as ``shimx64.efi`` may be used in stead.
The bootloader_ image file is located in the folder ``/boot/efi/`` on a bootable drive.
Other CPU architectures than x86-64_ are listed in the UEFI_specification_ section 3.5.

The Linux boot process is explained in detail in
`Guide to the Boot Process of a Linux System <https://www.baeldung.com/linux/boot-process>`_
and `Booting process of Linux <https://en.wikipedia.org/wiki/Booting_process_of_Linux>`_.
When powering up the client computer, PXE_ network booting can be selected using the console,
typically by pressing the F12 or F10 Function_key_.

When you :ref:`DHCP_server_UEFI_configuration`,
and subsequently network boot the client computer,
it will first download the bootloader_ image.
This image is executed in the client computer's UEFI_ capable NIC_ adapter,
and it will subsequently download the main bootloader_ image ``grubx64.efi`` from the TFTP_ server,
which loads the installation Linux_kernel_ and initrd_
(see the *Kernel* section in `Booting process of Linux <https://en.wikipedia.org/wiki/Booting_process_of_Linux>`_).

The ``grubx64.efi`` image will now attempt to download GRUB2_ configuration files in order using the following rules,
where the appended value ``-(something)`` corresponds to a property or address of the client machine::

  (FWPATH)/grub.cfg-(UUID OF NIC)
  (FWPATH)/grub.cfg-01-(MAC ADDRESS OF NIC)
  (FWPATH)/grub.cfg-(IPv4 OR IPv6 ADDRESS)
  (FWPATH)/grub.cfg

- Note that this GRUB2_ information has been copied from the local Linux ``grub.html`` manual's `Network` section in ``/usr/share/doc/grub2-common/grub.html``
  because the `original manual <https://www.gnu.org/software/grub/manual/grub/html_node/Network.html>`_ from `gnu.org` is frequently inaccessible.
  Make sure that the package containing the ``grub.html`` file has been installed on your PC by ``dnf install grub2-common``.

- The ``grub.cfg`` file is placed in the same directory as the path output by ``grub-mknetdir`` hereafter referred to as ``(FWPATH)``.
  Note: Our setup uses ``FWPATH=/tftpboot/uefi``.

- For the ``MAC ADDRESS OF NIC`` value the ``grub.html`` manual is missing a leading ``-01`` which we have added here.

The client will only attempt to look up an IPv6_ address value once, however,
it will try the smaller and smaller parts of IPv4_ address multiple times as shown below.
The first file in this list which can be downloaded successfully will be used for network booting.
This gives flexibility when configuring multiple client computers.

The concrete example below shows what would happen under the IPv4_ case:

* UUID_: 7726a678-7fc0-4853-a4f6-c85ac36a120a
* MAC_address_:  52:54:00:ec:33:81
* IP_address_: 10.0.0.130 (Hexadecimal_ digits: 0A000082, see :ref:`hexadecimal_ip-address`)

The GRUB2_ bootloader_ will attempt TFTP_ download of this list of configuration files in sequential order::

  (FWPATH)/grub.cfg-7726a678-7fc0-4853-a4f6-c85ac36a120a
  (FWPATH)/grub.cfg-01-52-54-00-ec-33-81        # Note the leading "-01" which is missing in the documentation
  (FWPATH)/grub.cfg-0A000082
  (FWPATH)/grub.cfg-0A00008
  (FWPATH)/grub.cfg-0A0000
  (FWPATH)/grub.cfg-0A000
  (FWPATH)/grub.cfg-0A00
  (FWPATH)/grub.cfg-0A0
  (FWPATH)/grub.cfg-0A
  (FWPATH)/grub.cfg-0
  (FWPATH)/grub.cfg

After GRUB2_ has started, files on the TFTP_ server will be accessible via the ``(tftp)`` device.

The TFTP_ server IP_address_ can be controlled by changing the ``(tftp)`` device name to ``(tftp,server-ip)``.
Note that this should be changed both in the prefix and in any references to the device name in the configuration file.

.. _IPv4: http://en.wikipedia.org/wiki/Ipv4
.. _IPv6: http://en.wikipedia.org/wiki/Ipv6
.. _IP_address: https://en.wikipedia.org/wiki/IP_address
.. _Ethernet: https://en.wikipedia.org/wiki/Ethernet
.. _NIC: https://en.wikipedia.org/wiki/Network_interface_controller
.. _MAC_address: https://en.wikipedia.org/wiki/MAC_address
.. _UUID: https://en.wikipedia.org/wiki/Universally_unique_identifier
.. _Hexadecimal: https://en.wikipedia.org/wiki/Hexadecimal
.. _syslinux: https://en.wikipedia.org/wiki/SYSLINUX
.. _Linux_kernel: https://en.wikipedia.org/wiki/Linux_kernel
.. _initrd: https://en.wikipedia.org/wiki/Initial_ramdisk
.. _bootloader: https://en.wikipedia.org/wiki/Bootloader
.. _Function_key: https://en.wikipedia.org/wiki/Function_key

=====================================================================================================

Configuring Secure Boot in client setup
=======================================

If the PXE_ client system is configured for UEFI_ Secure_Boot_
then the PXE_ boot may likely fail with an error about an **invalid signature**.
See `What is UEFI Secure Boot and how it works? <https://access.redhat.com/articles/5254641>`_
and `Installation of RHEL8 on UEFI system with Secure Boot enabled fails with error 'invalid signature' on vmlinuz <https://access.redhat.com/solutions/3771941>`_.

If you install third party Linux_kernel_ driver modules the Secure_Boot_ may block these modules:

* VirtualBox_: See `Installing Virtualbox and Secure Boot / Kernel Signing <https://forums.virtualbox.org/viewtopic.php?t=113162>`_.

* NVIDIA_drivers_: `NVIDIA drivers not working while Secure Boot <https://forums.developer.nvidia.com/t/nvidia-drivers-not-working-while-secure-boot-is-enabled-after-updating-to-ubuntu-24-04/305351>`_.

* MLNX_OFED_ Infiniband: Enrolling NVIDIA's x.509 Public Key On your Systems <https://docs.nvidia.com/networking/display/mlnxofedv24010331/uefi+secure+boot>`_

**Workaround:** Disable Secure_Boot_ from UEFI_ or BIOS_ settings.
After the OS installation has completed, Secure_Boot_ may be reenabled and the OS should boot correctly in this mode,
unless you build your own custom Linux_kernel_ due to special device drivers etc.

In some cases it is actually possible to make a successful PXE_ Secure_Boot_ installation,
see the section on DHCP_server_UEFI_configuration_.

You can determine on a running system whether Secure_Boot_ is enabled or not::

  $ mokutil --sb-state

.. _VirtualBox: https://www.virtualbox.org/
.. _NVIDIA_drivers: https://www.nvidia.com/en-in/drivers/
.. _MLNX_OFED: https://network.nvidia.com/products/infiniband-drivers/linux/mlnx_ofed/

efibootmgr - manipulate the UEFI Boot Manager
===============================================

efibootmgr_ is a userspace application used to modify the UEFI_ Boot Manager.  
This application can create and destroy boot entries, change the boot order, change the next running boot option, and more.

To show the current boot order::

  efibootmgr -v

Some useful command options (see the efibootmgr_ page)::

        -n | --bootnext XXXX   set BootNext to XXXX (hex)
        -N | --delete-bootnext delete BootNext
        -o | --bootorder XXXX,YYYY,ZZZZ,...     explicitly set BootOrder (hex)
        -O | --delete-bootorder   delete BootOrder

.. _efibootmgr: https://github.com/rhboot/efibootmgr

=====================================================================================================

Configure your network installation server
===============================================

.. _Install_bootloader_images:

Install the bootloader image files
----------------------------------------

Install the boot-image packages on your network installation server::

  dnf install grub2-efi-x64 shim-x64

:ref:`Configure_TFTP_service` and create a special directory for UEFI_ bootloader_ files::

  mkdir /var/lib/tftpboot/uefi
  ln -s /var/lib/tftpboot /tftpboot

Determine the OS family name for the subfolder in ``/boot/efi/EFI/`` by::

  $ grep '^ID=' /etc/os-release
  ID="almalinux"        # Or "rocky", "rhel", "centos" or something else

Copy the boot image files from the packages installed above (remember to change their permissions)::

  cp -p /boot/efi/EFI/BOOT/BOOTX64.EFI /tftpboot/uefi/
  cp -p /boot/efi/EFI/<insert OS ID here>/grubx64.efi /tftpboot/uefi/
  cp -p /boot/efi/EFI/<insert OS ID here>/shimx64.efi /tftpboot/uefi/
  chmod 644 /tftpboot/uefi/BOOTX64.EFI /tftpboot/uefi/grubx64.efi /tftpboot/uefi/shimx86.efi

The shim bootloader
.........................

According to the `Cambridge Dictionary <https://dictionary.cambridge.org/dictionary/english/shim>`_ **shim** is 
*a small object or piece of material used between two parts of something to make them fit together*.

The ``shimx64.efi`` is an EFI application that functions as a first-stage bootloader for systems with Secure_Boot_ enabled.
Additionally, ``shimx64.efi`` works within the constraints of Secure_Boot_,
which requires all bootloaders and kernels to be signed with a trusted Microsoft key.
It allows the user to individually trust keys provided by various Linux distributions.
Further information:

* `Debian SecureBoot <https://wiki.debian.org/SecureBoot>`_ page.
* The article grubx64_versus_shimx64_.
* The shim_ source homepage.
* The section Secure_Boot_ in the UEFI_ page on Wikipedia.

.. _grubx64_versus_shimx64: https://www.baeldung.com/linux/grubx64-vs-shimx64
.. _shim: https://github.com/rhboot/shim/blob/main/README.md
.. _Secure_Boot: https://en.wikipedia.org/wiki/UEFI#Secure_Boot

.. _Verify_signatures:

Verify secure boot image signature
...................................

This is only **optional**:
You can verify the signature of UEFI_ secure boot images using the ``sbverify`` UEFI_ secure boot verification tool.
First enable the repository:

* AlmaLinux 8: ``dnf install almalinux-release-devel``
* RockyLinux 8: Download https://dl.rockylinux.org/pub/sig/8/core/x86_64/core-infra/Packages/s/sbsigntools-0.9.5-2.el8.core.x86_64.rpm
* All EL9 or EL10: ``dnf install epel-release``

Install the package::

  $ dnf install sbsigntools

Some examples of signatures are:

* Any Linux ``shimx64.efi``::

    sbverify --list /boot/efi/EFI/rocky/shimx64.efi
    warning: data remaining[832368 vs 959224]: gaps between PE/COFF sections?
    signature 1
    image signature issuers:
     - /C=US/ST=Washington/L=Redmond/O=Microsoft Corporation/CN=Microsoft Corporation UEFI CA 2011
    image signature certificates:
     - subject: /C=US/ST=Washington/L=Redmond/O=Microsoft Corporation/CN=Microsoft Windows UEFI Driver Publisher
       issuer:  /C=US/ST=Washington/L=Redmond/O=Microsoft Corporation/CN=Microsoft Corporation UEFI CA 2011
     - subject: /C=US/ST=Washington/L=Redmond/O=Microsoft Corporation/CN=Microsoft Corporation UEFI CA 2011
       issuer:  /C=US/ST=Washington/L=Redmond/O=Microsoft Corporation/CN=Microsoft Corporation Third Party Marketplace Root

* Any Linux ``BOOTX64.EFI``::
  
    $ sbverify --list /boot/efi/EFI/BOOT/BOOTX64.EFI
    signature 1
    image signature issuers:
     - /C=US/ST=Washington/L=Redmond/O=Microsoft Corporation/CN=Microsoft Corporation UEFI CA 2011
    image signature certificates:
     - subject: /C=US/ST=Washington/L=Redmond/O=Microsoft Corporation/CN=Microsoft Windows UEFI Driver Publisher
       issuer:  /C=US/ST=Washington/L=Redmond/O=Microsoft Corporation/CN=Microsoft Corporation UEFI CA 2011
     - subject: /C=US/ST=Washington/L=Redmond/O=Microsoft Corporation/CN=Microsoft Corporation UEFI CA 2011
       issuer:  /C=US/ST=Washington/L=Redmond/O=Microsoft Corporation/CN=Microsoft Corporation Third Party Marketplace Root

* AlmaLinux system ``grubx64.efi``::
  
    $ sbverify --list /boot/efi/EFI/almalinux/grubx64.efi
    signature 1
    image signature issuers:
     - /emailAddress=security@almalinux.org/O=AlmaLinux OS Foundation/CN=AlmaLinux Secure Boot CA
    image signature certificates:
     - subject: /emailAddress=security@almalinux.com/O=AlmaLinux OS Foundation/CN=AlmaLinux Secure Boot Signing
       issuer:  /emailAddress=security@almalinux.org/O=AlmaLinux OS Foundation/CN=AlmaLinux Secure Boot CA
     - subject: /emailAddress=security@almalinux.org/O=AlmaLinux OS Foundation/CN=AlmaLinux Secure Boot CA
       issuer:  /emailAddress=security@almalinux.org/O=AlmaLinux OS Foundation/CN=AlmaLinux Secure Boot CA

* RockyLinux system ``grubx64.efi``::

    $ sbverify --list /boot/efi/EFI/rocky/grubx64.efi 
    signature 1
    image signature issuers:
     - /C=US/ST=Delaware/L=Dover/O=Rocky Enterprise Software Foundation/OU=Release engineering team/CN=Rocky Linux Secure Boot Root CA
    image signature certificates:
     - subject: /C=US/ST=Delaware/L=Dover/O=Rocky Enterprise Software Foundation/OU=Release engineering team/CN=Rocky Linux Grub2 Signing Cert 101
       issuer:  /C=US/ST=Delaware/L=Dover/O=Rocky Enterprise Software Foundation/OU=Release engineering team/CN=Rocky Linux Secure Boot Root CA

  

=====================================================================================================

Setting up the DHCP, TFTP and PXE services
================================================

.. _DHCP_server_UEFI_configuration:

Enable UEFI support in the DHCP server
--------------------------------------

We use an ISC_DHCP_ Linux server on EL/RHEL_ Linux.
The ISC_DHCP_ server has actually been superceded by the ISC_KEA_ server, but we do not consider it here.
On EL Linux ISC_KEA_ can be installed (in EL8/EL9 from EPEL_) with ``dnf install kea kea-hooks kea-doc kea-keama``.

Install the ISC_DHCP_ packages::

  dnf install dhcp-server dhcp-common 

To get started with configuration the packages contain an example file ``/usr/share/doc/dhcp-server/dhcpd.conf.example``.
It is also recommended to consult examples on the internet,
or to read the DHCP_Handbook_ for complete coverage of the ISC_DHCP_ server.

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

.. _RFC4578: https://datatracker.ietf.org/doc/html/rfc4578#section-2.1
.. _MTFTP: https://datatracker.ietf.org/doc/html/draft-henry-remote-boot-protocol-00

In the ``dhcpd.conf`` subnet section(s) define the desired UEFI_ RFC4578_ or PXE_ (legacy)
bootloader_ image types in the ``/tftpboot/uefi/`` subdirectory.

Remember also to :ref:`Install_bootloader_images`.
If you have any PXE boot clients with Secure_Boot_ enabled,
you **must** serve the ``shimx64.efi`` first-stage bootloader image
in stead of the often-cited ``BOOTX64.EFI``, see the :ref:`Secure_Boot_Setup` section.
See also the article grubx64_versus_shimx64_ and the shim_ homepage.

You should therefore always serve the ``shimx64.efi`` first-stage bootloader image::

  # UEFI x86-64 boot (RFC4578 architecture types 7, 8 and 9)
  if option arch = 00:07 {          
        filename "uefi/shimx64.efi";
  } else if option arch = 00:08 {
        filename "uefi/shimx64.efi";
  } else if option arch = 00:09 {
        filename "uefi/shimx64.efi";
  } else {                              
        # PXE boot
        filename "pxelinux.0";
  }

Note: Other CPU architectures besides x86-64_ are listed in the UEFI_specification_ section 3.5.

The ``shimx64.efi`` chainloads ``grubx64.efi`` after the Verify_signatures_ step,
and this also works seemlessly on clients that have disabled the Secure_Boot_ feature.

**IMPORTANT:**:
The ``shimx64.efi`` and ``grubx64.efi`` bootloader_ images must be copied from the
**same Linux OS version** as the OS you are trying to install on the client,
i.e., the PXE_ installation Linux_kernel_ ``vmlinuz`` (see below) **must** have the same signature.

We have not been able to find a way to support multiple OS versions with Secure_Boot_ clients.
Any signature mismatch will cause the installation to fail,
since different OS images cannot verify the image signatures of other OSes,
for example RHEL_ versus AlmaLinux_ versus RockyLinux_.

Placing the boot-image file in a subdirectory of the TFTP_ server's ``/tftpboot`` folder such as ``/tftpboot/uefi/``,
will cause the client host PXE_ boot process to download all further files also from that same subdirectory,
so you need to place any other files there.

When you have completed configuring the ``dhcpd.conf`` file, open the firewall for DHCP_ (port 67)::

  firewall-cmd --add-service=dhcp --permanent
  firewall-cmd --reload

and start the DHCP_ service::

  systemctl enable dhcpd
  systemctl restart dhcpd

.. _x86-64: https://en.wikipedia.org/wiki/X86-64

.. _Configure_TFTP_service:

Configure the TFTP service
---------------------------

Your DHCP_ server should also run a TFTP_ service for file downloads.
Install these packages::

  dnf install tftp-server tftp 

Copy the service file to make local customizations::

  cp /usr/lib/systemd/system/tftp.service /etc/systemd/system/tftp.service

Edit the file ``/etc/systemd/system/tftp.service`` to add the in.tftpd_ options ``--secure --ipv4``::

  ExecStart=/usr/sbin/in.tftpd -v --secure --ipv4 /var/lib/tftpboot

Open the firewall for TFTP_ (port 69)::

  firewall-cmd --add-service=tftp --permanent
  firewall-cmd --reload

and start the service::

  systemctl enable tftp
  systemctl restart tftp

.. _in.tftpd: https://linux.die.net/man/8/in.tftpd

Download Linux OS boot images
-----------------------------

For each EL/RHEL_ Linux (and other OS) version you should copy Linux boot images to a separate directory on the TFTP_ server,
for example, for AlmaLinux_ 8.10::

  mkdir /var/lib/tftpboot/AlmaLinux-8.10-x86_64/

In this directory create the following ``Makefile``::

  OS=almalinux
  VERSION=8.10
  MIRROR=<your-favorite-mirror>
  default:
        @echo "NOTE: Boot images are from ${OS} version ${VERSION}"
        @wget --timestamping ${MIRROR}/${OS}/${VERSION}/BaseOS/x86_64/os/images/pxeboot/initrd.img
        @wget --timestamping ${MIRROR}/${OS}/${VERSION}/BaseOS/x86_64/os/images/pxeboot/vmlinuz

and run a ``make`` command to download the boot image files.

.. _create_grub.cfg:

Create a grub.cfg file in /tftpboot/uefi/
---------------------------------------------

Please consult the :ref:`Kickstart_installation_of_EL_Linux_systems` page for a description of automated Linux OS installation.

The ``uefi/grubx64.efi`` (or the ``uefi/BOOTX64.EFI``) boot file will be looking for a
GRUB2_ or Grub_ configuration file ``uefi/grub.cfg`` in the same subdirectory.
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
    linuxefi (tftp)/AlmaLinux-8.10-x86_64/vmlinuz ip=dhcp inst.ks=nfs:nfsvers=3:10.10.10.3:/u/kickstart/ks-rockylinux-8-minimal-x86_64.cfg ipv6.disable=1
    initrdefi (tftp)/AlmaLinux-8.10-x86_64/initrd.img
  }

**Note:** Change the IP address ``10.10.10.3`` to that of your local NFS_ server.

Additional menu entries may be appended to the above, for example::

  menuentry 'AlmaLinux 9.6 minimal Kickstart' --class centos --class gnu-linux --class gnu --class os --unrestricted {
    linuxefi (tftp)/AlmaLinux-9.6-x86_64/vmlinuz ip=dhcp inst.ks=nfs:nfsvers=3:10.10.10.3:/u/kickstart/ks-rockylinux-9-minimal-x86_64.cfg ipv6.disable=1
    initrdefi (tftp)/AlmaLinux-9.6-x86_64/initrd.img
  }

It is useful to have a ``grub.cfg`` menu item from the TFTP_ server which allows to boot the system from an existing OS installation on disk.
This should be the default menu item.
To boot a system with ``grubx64.efi`` (provided by the ``grub2-efi-x64`` package) in the 1st partition of the first disk hd0::

  menuentry 'Useless: Boot from local disk' {
    # Undocumented "exit" command.  Returns to BIOS boot menu on Dell 9020
    exit
  }

If there are multiple disks in the client computer, Grub_ will name them as *hd0, hd1, hd2*, etc.
It seems that the numbering of such disks may vary, and if the OS installation is suddenly in disk *hd1* in stead of *hd0*,
it is useful to define a fallback_ boot menu item as in this example::

  set default=0
  set fallback=1
  menuentry 'Boot from local disk hd0' {
   set root=(hd0,1)
   chainloader /efi/centos/grubx64.efi
  }
  menuentry 'Boot from local disk hd1' {
   set root=(hd1,1)
   chainloader /efi/centos/grubx64.efi
  }

.. _Grub: https://en.wikipedia.org/wiki/GNU_GRUB
.. _fallback: https://www.gnu.org/software/grub/manual/grub/html_node/fallback.html

=======================================================================================================

.. _Automated_network_installation_with_pxeconfig:

Automated network installation with pxeconfig
=============================================

You can automate the PXE_ network booting process completely using the pxeconfig_toolkit_ written by Bas van der Vlies.
Download the pxeconfig_toolkit_ and read the pxeconfig_installation_ page.

**NOTE:** We assume throughout the use of client UEFI_ booting,
since the old BIOS_ booting is more or less deprecated.

.. _pxeconfig_installation: https://gitlab.com/surfsara/pxeconfig/-/wikis/installation

Installation of pxeconfig on EL Linux
-----------------------------------------

See the pxeconfig_installation_ page.
Configure the default boot method to be UEFI_ in ``/usr/local/etc/pxeconfig.conf``::

  [DEFAULT]
  boot_method=uefi

This configures the pxeconfig_ command to create ``grub.cfg`` files in the ``/tftpboot/uefi/`` directory
which was created in the :ref:`create_grub.cfg` section.

Having added the port 6611 pxeconfigd_ service to the services_ file ``/etc/services``,
you must also open port 6611 in the firewall::

  firewall-cmd --permanent --zone=public --add-port=6611/tcp --reload

Setup the pxeconfigd_ service with Systemd_.
Note that it is ``pxeconfigd.socket`` which handles the pxeconfigd_ service,
similar to the normal telnet_ service, and not the ``.service`` file.
Remember to set the SELinux_ context::

  restorecon -v /usr/local/sbin/pxeconfigd

.. _pxeconfig_toolkit: https://gitlab.com/surfsara/pxeconfig
.. _pxeconfigd: https://gitlab.com/surfsara/pxeconfig/-/blob/master/src/pxeconfigd.py
.. _pxeconfig: https://gitlab.com/surfsara/pxeconfig/-/blob/master/src/pxeconfig.py
.. _hexls: https://gitlab.com/surfsara/pxeconfig/-/blob/master/src/hexls.in
.. _services: https://man7.org/linux/man-pages/man5/services.5.html
.. _telnet: https://en.wikipedia.org/wiki/Telnet
.. _Systemd: https://en.wikipedia.org/wiki/Systemd
.. _SELinux: https://en.wikipedia.org/wiki/Security-Enhanced_Linux

.. _hexadecimal_ip-address:

Hexadecimally encoded IP-addresses
---------------------------------------

To understand the client's hexadecimally encoded IP-address, 
which the pxeconfig_toolkit_ manipulates in the server's ``/tftpboot/uefi/`` directory,
we show some examples::

  0A018219 decodes as 10.1.130.25

You can use the gethostip_ command from the ``syslinux`` package to convert hostnames and IP-addresses to hexadecimal, for example::

  $ gethostip -f s001
  s001.(domainname) 10.2.130.21 0A028215
  $ gethostip -x s001
  0A028215

.. _gethostip: https://linux.die.net/man/1/gethostip

The pxeconfig command
---------------------

To use pxeconfig_ you should create any number of configuration files named ``default.<something>``
which contain different PXELINUX commands that perform the desired actions, for example,
BIOS_ updates, firmware updates, hardware diagnostics, or network installation.
See the above :ref:`create_grub.cfg` section.

Use the pxeconfig_ command to configure those client nodes that you wish to install 
(the remaining nodes will simply boot from their hard disk).
An example is::

  $ pxeconfig c150
  Which pxe config file must we use: ?
  1 : default.rockylinux-8-sr850v3-x86_64
  2 : default.rockylinux-8-x86_64

The pxeconfig_ command creates soft-links in the ``/tftpboot/uefi/`` directory named as 
the hexadecimally encoded IP-address of the clients, pointing to one of the files ``default.*``. 
As designed, the PXE_ network booting process will download the file given by the hexadecimal IP-address, 
and hence network installation of the node will take place.

If desired you can remove the soft-link::

  $ pxeconfig -r c150

The hexls command
-----------------

To list the soft links created by pxeconfig_ use the tool hexls_ and look for the IP-addresses and/or hostnames.  
An example output is::

  $ hexls /tftpboot/uefi/ 
  default.rockylinux-8-x86_64
  grub.cfg
  grub.cfg-0A028396 => 10.2.131.150 => c150.nifl.fysik.dtu.dk -> default.rockylinux-8-x86_64

The pxeconfigd service
------------------------

The pxeconfigd_ service will remove the hexadecimally encoded IP-address soft-link on the server when contacted on port 6611 by the client node. 
In order for this to happen, you must create the client's post-install script to make an action such as this example::

  #!/bin/sh
  # To be used with the pxeconfigd service:
  # Remove the <hex_ipaddr> file from the pxelinux.cfg directory so the client will boot from disk.
  telnet <IMAGESERVER> 6611
  sleep 1
  exit 0

When this script is executed on the node in the post-install phase,
the telnet_ command connects to the pxeconfigd_ service on the image server,
and this daemon will remove the hexadecimally encoded IP-address soft-link in ``/tftpboot/uefi/``
corresponding to the client IP-address which did the telnet_ connection.
