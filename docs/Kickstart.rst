.. _Kickstart:

======================
Kickstart installation
======================

.. contents::


Introduction
=============

The ``Kickstart`` installation method provides a way to do automated installations of RedHat Linux and derivatives.
For documentation see the Pykickstart_ page.
See also our :ref:`PXE-booting` and :ref:`PXE_and_UEFI` pages.

.. _Pykickstart: https://pykickstart.readthedocs.io/en/latest/
.. _PXE: https://en.wikipedia.org/wiki/Preboot_Execution_Environment
.. _TFTP: https://en.wikipedia.org/wiki/Trivial_File_Transfer_Protocol
.. _PXELINUX: https://wiki.syslinux.org/wiki/index.php?title=PXELINUX
.. _DHCP: https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol

Using Kickstart
===============

``Kickstart`` is a method for Linux installation preparation,
and it uses a ``Kickstart`` script ``ks.cfg`` to describe the steps necessary for installing Linux.
The script as well as installation files are then provided through standard services like DHCP_ and PXE_ and TFTP_
(or possibly using a DVD disk, even though this may be outdated).

PXE configuration
=================

Network booting by PXE_ (*Preboot Execution Environment*)
provides the ``/tftpboot`` directory on a boot server for downloading files by the TFTP_ protocol.
The PXE_ network booting protocol is implemented in hardware/firmware by every Ethernet_ chip.
In order to boot a machine into a Linux installation environment,
the client computer boots the PXELINUX_ software from the boot server.

The boot server's PXE_/TFTP_ directory ``/tftpboot`` is organized into the following subdirectories:

 * ``/tftpboot/pxelinux.cfg/``: Contains PXE_ boot files named as ``default.XXX``,
   as well as soft links corresponding to IP-addresses (see the PXELINUX_ page *Configuration* section)
   to be downloaded and installed using PXE_.

 * An OS-specific folder (for example, ``/tftpboot/CentOS-7.9/``) containing two files ``vmlinuz`` (a mini-kernel for PXE_ booting)
   and ``initrd.img`` (an Initial RAM-disk_ file system).

The PXE_ network booting is controlled by a number of parameters in a PXE_ configuration file.
For example, a file ``default.centos7`` for installing CentOS 7 might contain::

  label CentOS7.9.2009 minimal-x86_64
        menu label Clean CentOS-7.9.2009-x86_64, minimal install
        kernel CentOS-7.9.2009-x86_64/vmlinuz
        append load_ramdisk=1 initrd=CentOS-7.9.2009-x86_64/initrd.img network ks=nfs:130.225.86.11:/u/kickstart/ks-centos-7.9.2009-minimal-x86_64.cfg

Here the ``append`` parameters are documented in Anaconda_Boot_Options_.
The name of the ``Kickstart`` file is configured by the ``ks=...`` parameter,
which can in addition use several types of network resources such as NFS_, HTTP_, or FTP_.

Possibly obsolete:
For NFS_ installs please note that RHEL/CentOS defaults to the NFS_ version``NFSv4``.
However, the ``ks=`` parameter also permits specifying an NFS_ mount option ``nfsvers=3``::

  ks=nfs:nfsvers=3:130.225.86.11:ks.cfg

.. _Ethernet: https://en.wikipedia.org/wiki/Ethernet
.. _RAM-disk: https://en.wikipedia.org/wiki/RAM_drive
.. _NFS: https://en.wikipedia.org/wiki/Network_File_System
.. _HTTP: https://en.wikipedia.org/wiki/HTTP
.. _FTP: https://en.wikipedia.org/wiki/File_Transfer_Protocol
.. _Anaconda_Boot_Options: https://anaconda-installer.readthedocs.io/en/latest/boot-options.html

vmlinuz and initrd.img
----------------------

The PXE_ boot kernel and initial file system are the ``vmlinuz`` mini-kernel and the ``initrd`` Initial RAM-disk_,  respectively.
These should be downloaded to the installation server from a mirror site, for example https://mirror.fysik.dtu.dk/linux/.
It is **required** to download the specially configured **Kickstart images** and not the regular OS boot images, for example from
https://mirror.fysik.dtu.dk/linux/almalinux/8/BaseOS/x86_64/kickstart/images/ for AlmaLinux_.

On our internal DHCP_/PXE_ server these PXE_ files are placed in, for example,
the ``/tftpboot/AlmaLinux-8.8-x86_64/`` directory for installation of AlmaLinux_ version 8.8.
  
The PXE_ boot files in the ``/tftpboot/pxelinux.cfg`` directory must contain 
``default.XXX`` files such as ``default.install-centos-4.4-clean`` which contain a reference to the new versions 
of `vmlinuz` and  `initrd` in ``/tftpboot/CentOS-X.Y``.

.. _AlmaLinux: https://almalinux.org/

DHCP configuration file dhcpd.conf
==================================

The following entry in ``/etc/dhcpd.conf`` enables PXE_ boot by means of the PXELINUX_ software::

  # TFTP download from intra5:
  next-server 130.225.86.6;
  # Start up PXELINUX:
  filename "pxelinux.bin";

These lines are added to ``/etc/dhcpd.conf`` on the DHCP_ servers. 
