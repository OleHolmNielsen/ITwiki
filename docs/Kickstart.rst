.. _Kickstart:

======================
Kickstart installation
======================

.. contents::


Introduction
=============

The ``Kickstart`` installation method provides a way to do automated installations of RedHat Linux and derivatives.
For documentation see the Pykickstart_ page.

.. _Pykickstart: https://pykickstart.readthedocs.io/en/latest/
.. _PXE: https://en.wikipedia.org/wiki/Preboot_Execution_Environment
.. _TFTP: https://en.wikipedia.org/wiki/Trivial_File_Transfer_Protocol
.. _PXELINUX: https://wiki.syslinux.org/wiki/index.php?title=PXELINUX
.. _DHCP: https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol

Using Kickstart
===============

``Kickstart`` is not "used" as such, it is more of a method for installation preparation.
It uses a script ``ks.cfg`` to describe the steps necessary for installing Linux.
The script and installation files are then provided through standard services like a CD/DVD, with DHCP_ and TFTP_, or a floppy disk.

RedHat provides a tool `system-config-kickstart` for setting up a kickstart installation, which creates the ``ks.cfg`` file.

PXE configuration
=================

Network booting by PXE_ (*Preboot Execution Environment*)
uses the ``/tftpboot`` directory for downloading files by TFTP_.
In order to boot a machine into a Linux environment, the PXELINUX_ software is used.
See also our :ref:`PXE-booting` page.

The PXE_/TFTP_ directory ``/tftpboot`` is organized into the following subdirectories:

 * ``pxelinux.cfg/``: Contains PXE_ ``default.XXX`` boot files, as well as soft links corresponding to IP-addresses to be installed by PXE_.

 * An OS-specific folder (for example, ``CentOS-7.9/``) containing just two files ``vmlinuz`` (kernel) and ``initrd.img`` (RAM-disk).

The PXE_ booting is controlled by a number of parameters in the PXE_ configuration file, for example::

  label CentOS7 clean-x86_64
        menu label Clean CentOS-7-x86_64, kickstart
        kernel CentOS-7-x86_64/vmlinuz
        append load_ramdisk=1 initrd=CentOS-7-x86_64/initrd.img network ks=nfs:130.225.86.4:/u/rpm/kickstart/ks-centos-7-clean-x86_64.cfg

Here the ``append`` parameters are documented in Anaconda_Boot_Options_.
The ``Kickstart`` file is configured by the ``ks=...`` parameter,
which can use several types of network resources such as ``nfs, http or ftp``.
For NFS_ installs please note that RHEL/CentOS defaults to ``NFS version 4``, however, the ``ks=`` parameter also permits NFS_ mount options such as::

  ks=nfs:nfsvers=3:130.225.86.4:xxx

.. _NFS: https://en.wikipedia.org/wiki/Network_File_System
.. _Anaconda_Boot_Options: https://anaconda-installer.readthedocs.io/en/latest/boot-options.html

vmlinuz and initrd.img
----------------------

The boot kernel and initial file system used by PXE_ are the ``vmlinuz`` mini-kernel and the ``initrd`` initial RAM-disk,  respectively.
These should be downloaded from a RHEL/CentOS mirror site.
On the ``intra5`` DHCP_/PXE_ server these files are placed in ``/tftpboot/CentOS-X.Y`` directory for Centos version X.Y, for example.
  
The PXE_ boot files in the ``/tftpboot/pxelinux.cfg`` directory must contain 
``default.XXX`` files such as ``default.install-centos-4.4-clean`` which contain a reference to the new versions 
of `vmlinuz` and  `initrd` in ``/tftpboot/CentOS-X.Y``.

dhcpd.conf
----------

The following entry in ``/etc/dhcpd.conf`` enables PXE_ boot by means of the PXELINUX_ software::

  # TFTP download from intra5:
  next-server 130.225.86.6;
  # Start up PXELINUX:
  filename "pxelinux.bin";

These lines are added to ``/etc/dhcpd.conf`` on the DHCP_ servers. 
