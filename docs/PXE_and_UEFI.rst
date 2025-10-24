.. _PXE_and_UEFI:

==================================
Install EL Linux via PXE and UEFI
==================================

.. Contents::

Overview
========

This *HowTo* guide documents how to install EL/RHEL_ Linux using PXE_ on a client host booting by UEFI_.

We will show how to support UEFI_ booting with PXE_, downloading files from your TFTP_ server.
See also our network :ref:`PXE-booting` page for Linux OS installation, and also these useful pages:

* https://www.gnu.org/software/grub/manual/grub/grub.html
* https://fedoraproject.org/wiki/GRUB_2
* https://help.ubuntu.com/community/Grub2/Passwords
* https://wiki.fogproject.org/wiki/index.php/BIOS_and_UEFI_Co-Existence
* https://github.com/quattor/aii/issues/216
* UEFI security: `UEFI DEFENSIVE PRACTICES GUIDANCE <https://www.nsa.gov/portals/75/documents/what-we-do/cybersecurity/professional-resources/ctr-uefi-defensive-practices-guidance.pdf>`_.

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
.. _PXE-booting: https://wiki.fysik.dtu.dk/niflheim/PXE-booting
.. _GRUB2: https://fedoraproject.org/wiki/GRUB_2
.. _NFS: https://en.wikipedia.org/wiki/Network_File_System
.. _EPEL: https://fedoraproject.org/wiki/EPEL

=======================================================================================================

.. _UEFI_network_boot:

UEFI network boot process
=========================

In this section we describe how a computer doing an UEFI_ network PXE_ boot will download a bootloader_ image file
from the network's TFTP_ server and execute it.
For 64-bit UEFI_ systems with the x86-64_ architecture,
the boot file name convention is ``BOOTX64.EFI``.
This file is located in the folder ``/boot/efi/`` on a bootable drive.
Other CPU architectures than x86-64_ are listed in the UEFI_specification_ section 3.5.

The Linux boot process is explained in detail in
`Guide to the Boot Process of a Linux System <https://www.baeldung.com/linux/boot-process>`_
and `Differences between grubx64 and shimx64 <https://www.baeldung.com/linux/grubx64-vs-shimx64>`_.

When you :ref:`DHCP_server_UEFI_configuration` the client computer will download 
the PXE_ bootloader_ image ``BOOTX64.EFI``.
This image is executed in the client computer's UEFI_ capable NIC_ adapter,
and it will subsequently download another image ``grubx64.efi`` from the TFTP_ server.

The ``grubx64.efi`` image will now attempt to download GRUB2_ configuration files in order using the following rules,
where the appended value corresponds to a value on the client machine::

  (FWPATH)/grub.cfg-(UUID OF NIC)
  (FWPATH)/grub.cfg-(MAC ADDRESS OF NIC)
  (FWPATH)/grub.cfg-(IPv4 OR IPv6 ADDRESS)
  (FWPATH)/grub.cfg

- Note that this GRUB2_ information has been copied from the local Linux ``grub.html`` manual's `Network` section in ``/usr/share/doc/grub2-common/grub.html``
  because the `original manual <https://www.gnu.org/software/grub/manual/grub/html_node/Network.html>`_ from `gnu.org` is frequently inaccessible.
  Make sure that the package containing the ``grub.html`` file has been installed on your PC by ``dnf install grub2-common``.

- The ``grub.cfg`` file is placed in the same directory as the path output by ``grub-mknetdir`` hereafter referred to as ``(FWPATH)``.
  Note: Our setup uses ``FWPATH=/tftpboot/uefi``.

The client will only attempt to look up an IPv6_ address config once, however, it will try the IPv4_ address multiple times.
The first file in this list which can be downloaded successfully will be used for network booting.
The concrete example below shows what would happen under the IPv4_ case:

* UUID_: 7726a678-7fc0-4853-a4f6-c85ac36a120a
* MAC_address_:  52:54:00:ec:33:81
* IP_address_: 10.0.0.130 (Hexadecimal_ digits: 0A000082, see :ref:`hexadecimal_ip-address`)

The GRUB2_ bootloader_ will attempt TFTP_ download of this list of configuration files in order::

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
.. _NIC: https://en.wikipedia.org/wiki/Network_interface_controller
.. _MAC_address: https://en.wikipedia.org/wiki/MAC_address
.. _UUID: https://en.wikipedia.org/wiki/Universally_unique_identifier
.. _Hexadecimal: https://en.wikipedia.org/wiki/Hexadecimal
.. _syslinux: https://en.wikipedia.org/wiki/SYSLINUX

=====================================================================================================

Configure your network installation server
===============================================

.. _Install_bootloader_images:

Install the BOOTX64.EFI and other bootloader files
-------------------------------------------------------

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

.. _Verify_signatures:

Verify secure boot image signature
...................................

This is only optional:
You can verify the signature of UEFI_ secure boot images using the ``sbverify`` command
which is located in the Linux distrubition's *Devel* repository
(which should not be enabled by default!),
for example::

  # AlmaLinux only: dnf install almalinux-release-devel
  $ dnf install sbsigntools
  $ sbverify --list /boot/efi/EFI/BOOT/BOOTX64.EFI
  signature 1
  image signature issuers:
   - /C=US/ST=Washington/L=Redmond/O=Microsoft Corporation/CN=Microsoft Corporation UEFI CA 2011
  image signature certificates:
   - subject: /C=US/ST=Washington/L=Redmond/O=Microsoft Corporation/CN=Microsoft Windows UEFI Driver Publisher
     issuer:  /C=US/ST=Washington/L=Redmond/O=Microsoft Corporation/CN=Microsoft Corporation UEFI CA 2011
   - subject: /C=US/ST=Washington/L=Redmond/O=Microsoft Corporation/CN=Microsoft Corporation UEFI CA 2011
     issuer:  /C=US/ST=Washington/L=Redmond/O=Microsoft Corporation/CN=Microsoft Corporation Third Party Marketplace Root
  $ sbverify --list /boot/efi/EFI/almalinux/grubx64.efi
  signature 1
  image signature issuers:
   - /emailAddress=security@almalinux.org/O=AlmaLinux OS Foundation/CN=AlmaLinux Secure Boot CA
  image signature certificates:
   - subject: /emailAddress=security@almalinux.com/O=AlmaLinux OS Foundation/CN=AlmaLinux Secure Boot Signing
     issuer:  /emailAddress=security@almalinux.org/O=AlmaLinux OS Foundation/CN=AlmaLinux Secure Boot CA
   - subject: /emailAddress=security@almalinux.org/O=AlmaLinux OS Foundation/CN=AlmaLinux Secure Boot CA
     issuer:  /emailAddress=security@almalinux.org/O=AlmaLinux OS Foundation/CN=AlmaLinux Secure Boot CA

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

In the ``dhcpd.conf`` subnet section(s) define UEFI_ RFC4578_ or PXE_ (legacy) bootloader_ image types in the ``/tftpboot/uefi/`` subdirectory,
such as ``BOOTX64.EFI``::

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

Other CPU architectures than x86-64_ are listed in the UEFI_specification_ section 3.5.

Remember also to :ref:`Install_bootloader_images`.
For Secure_Boot_ you can alternatively serve the ``shimx64.efi`` boot image in stead of the usual ``BOOTX64.EFI``,
see the :ref:`Secure_Boot_Setup` section,
by configuring::

  filename "uefi/shimx64.efi";

Placing the boot-image file in a subdirectory of the TFTP_ server's ``/tftpboot`` folder,
for example ``/tftpboot/uefi/BOOTX64.EFI``,
will cause the client host PXE_ boot process to download all further files also from that same ``uefi/`` subdirectory,
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

The ``uefi/BOOTX64.EFI`` boot file will be looking for a GRUB2_ or Grub_ configuration file ``uefi/grub.cfg`` in the same subdirectory.
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
To boot a system with ``grubx64.efi`` (provided by the ``grub2-efi-x64`` package) in the 1st partition of the first disk hd0::

  menuentry 'Useless: Boot from local disk' {
    # Undocumented "exit" command.  Returns to BIOS boot menu on Dell 9020
    exit
  }

If there are multiple disks in the server, Grub_ will name them as *hd0, hd1, hd2*, etc.
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

=======================================================================================================

Configuring Kickstart installation of EL Linux systems
================================================================

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

A Kickstart_ installation can be made using PXE_and_UEFI_ network booting.

.. _Secure_Boot_Setup:

Disable Secure Boot in client setup
----------------------------------------

If the PXE_ client system is configured for UEFI_ Secure_Boot_
then the PXE_ boot may likely fail with an error about an **invalid signature**.
See `What is UEFI Secure Boot and how it works? <https://access.redhat.com/articles/5254641>`_
and `Installation of RHEL8 on UEFI system with Secure Boot enabled fails with error 'invalid signature' on vmlinuz <https://access.redhat.com/solutions/3771941>`_.

**Workaround:** Disable Secure_Boot_ from UEFI_ or BIOS_ settings.
After the OS installation has completed, Secure_Boot_ may be reenabled and the OS should boot correctly in this mode,
unless you build your own custom kernel due to special device drivers etc.

In some cases it is actually possible to make a successful PXE_ Secure_Boot_ installation,
provided these conditions are fulfilled:

* In :ref:`DHCP_server_UEFI_configuration` serve the ``shimx64.efi`` boot image from ``dhcpd.conf``
  in stead of the usual ``BOOTX64.EFI``::

    filename "uefi/shimx64.efi";

* The ``shimx64.efi`` boot image must originate from the **same Linux OS version** as the OS you are trying to install.
  Note: You may :ref:`Verify_signatures` if necessary.

In this case the client's Secure_Boot_ of ``shimx64.efi`` will accept the signature of the ``grubx64.efi`` boot image
as well as the signature of the Linux installation kernel when it gets loaded.
For example, if all boot images are from the same ``RockyLinux 9.6`` OS, 
then the image signatures will be verified correctly by the UEFI_ Secure_Boot_ in the client.

Any signature mismatch will cause the installation to fail,
since different OS images cannot verify the image signatures of other OSes,
for example ``RHEL`` versus ``AlmaLinux`` versus ``RockyLinux``.

.. _Secure_Boot: https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface#SECURE-BOOT
.. _SHIM: https://github.com/rhboot/shim/blob/main/README.md

Automated Kickstart installation
-----------------------------------

Automated installation with PXE_ and Anaconda_ is possible using either UEFI_ or legacy BIOS_ booting.

If the node's **boot order** has been configured with PXE_ network booting as the first boot device,
and you have also installed the above pxeconfig_toolkit_ and used pxeconfig_ to setup the client boot process,
then it is sufficient to power cycle and/or start up the server.
The :ref:`_UEFI_network_boot` ensures that:

* Kickstart_ OS installation will be performed automatically without any user intervention.
* The installation process can be viewed in the node's console (physically or in the BMC_ web browser window).
* The Kickstart_ method described above therefore provides a **totally automatic and hands-free** Linux OS installation of nodes,
  suitable for a large Linux cluster and other scenarios.

Alternatively, when powering up the server, PXE_ network boot can be selected from the console,
typically by pressing the F12 or F10 button as shown in the console.

.. _Kickstart: https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html#chapter-1-introduction
.. _Kickstart_file: https://anaconda-installer.readthedocs.io/en/latest/kickstart.html
.. _RHEL: https://en.wikipedia.org/wiki/Red_Hat_Enterprise_Linux
.. _AlmaLinux: https://almalinux.org/
.. _RockyLinux: https://www.rockylinux.org
.. _Fedora: https://fedoraproject.org/
.. _BMC: https://en.wikipedia.org/wiki/Intelligent_Platform_Management_Interface#Baseboard_management_controller

Creating a Kickstart_file_
-------------------------------

In the following sections we discuss relevant sections of the Kickstart_file_.

In the ``grub.cfg`` file you can use the inst.ks_ parameter to specify the location
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

Bootloader command
------------------

The Kickstart_file_ bootloader_ command (required) specifies how the bootloader_ should be installed.

You should always use a password to protect your bootloader_.
An unprotected bootloader_ can allow a potential attacker to modify the system’s boot options and gain unauthorized access to the system:

* ``--password`` 
  If using GRUB2_ as the bootloader_, this sets the bootloader_ password to the one specified.
  This should be used to restrict access to the GRUB2_ shell, where arbitrary kernel options can be passed.
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

.. _bootloader: https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html#bootloader

Automatic boot disk device selection 
---------------------------------------

The server or PC computer may have multiple disk devices, and each device may have different bus interfaces to the system such as NVME_ or SATA_.

When the Kickstart_ installation starts up, the file given by inst.ks_ must select, format and partition the system boot disk.
However, you do not want to install the Linux OS on a large disk device which might be used only for data storage!
Another problem is that NVME_ and SATA_ devices have different device names in the Linux kernel, for example:

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
then the kernel in EL8 Linux may select a higher, unsupported screen resolution which gives a flickering monitor with no image!
See these pages:

* https://www.systutorials.com/configuration-of-linux-kernel-video-mode/
* https://cromwell-intl.com/open-source/grub-vga-modes.html
* https://pierre.baudu.in/other/grub.vga.modes.html

You can add a vga= directive to the kernel line in the GRUB file, something like the following::

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

* Switching VESA_ modes of Linux kernel at boot time can be done by using the “vga=…“ kernel boot parameter. 
  This parameter accept the decimal value of Linux video mode numbers instead of VESA_ video mode numbers. 

The video mode number of the Linux kernel is the VESA_ mode number plus 0×200::

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

.. _VESA: https://en.wikipedia.org/wiki/VESA_BIOS_Extensions

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
