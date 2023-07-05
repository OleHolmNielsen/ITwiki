.. _PXE_booting:

=======================
PXE booting of machines
=======================

Most PCs and servers may use the *PXE network booting* Preboot_Execution_Environment_ as a boot device.

.. _Preboot_Execution_Environment: http://en.wikipedia.org/wiki/Preboot_Execution_Environment

PXELINUX
========

Network booting Linux for network installation etc. uses the SYSLINUX_ and PXELINUX_ utilities. 
Read the documentation on these pages to get an understanding of the process.

With PXELINUX_ the node should boot by DHCP and download (by TFTP) the file ``/tftpboot/pxelinux.0``
which will subsequently download configuration files from ``/tftpboot/pxelinux.cfg/`` on the DHCP server.

.. _SYSLINUX: https://wiki.syslinux.org/wiki/index.php?title=The_Syslinux_Project
.. _SYSLINUX_menu: https://wiki.syslinux.org/wiki/index.php?title=Menu
.. _PXELINUX: https://wiki.syslinux.org/wiki/index.php?title=PXELINUX

Install SYSLINUX
=================

On EL8 systems install these packages::

  dnf install syslinux syslinux-tftpboot 

SYSLINUX Menu systems
---------------------

With newer versions of SYSLINUX_ it is possible to PXE-boot into the SYSLINUX_menu_ where many booting options can be configured.

The SYSLINUX_menu_ system must be configured, and a simple ``default.menu`` file in ``/tftpboot/pxelinux.cfg/`` is::

  DEFAULT vesamenu.c32
  PROMPT 0
  
  MENU TITLE Menu from intra2
  MENU BACKGROUND Logo.jpg
  
  label harddisk
        menu label Boot from local harddisk
        kernel chain.c32
        append hd0

  label memtest86
        menu label Memtest86 memory tester
        kernel memtest86

  label AlmaLinux-8.7-x86_64
        menu label Installation of AlmaLinux-8.7-x86_64, no kickstart
        kernel AlmaLinux-8.7/vmlinuz
        append load_ramdisk=1 initrd=AlmaLinux-8.7/initrd.img network


Pxeconfig toolkit
=================

The pxeconfig_ toolkit written by Bas van der Vlies automates the reinstallation of a node ``nodename``,
which is easily performed by configuring the DHCP server using ``pxeconfig``::

  pxeconfig nodename
    (select one of the available pxe configuration files)

Some more information is in https://wiki.fysik.dtu.dk/Niflheim_system/

.. _pxeconfig: https://gitlab.com/surfsara/pxeconfig
