.. _PXE_booting:

=======================
PXE booting of machines
=======================

Most PCs and servers may use *PXE network booting* 
(`Preboot Execution Environment <http://en.wikipedia.org/wiki/Preboot_Execution_Environment>`_)
as a boot device.

PXELINUX
========

Network booting Linux for network installation etc. uses the `SYSLINUX <http://syslinux.zytor.com/>`_ and 
`PXELINUX <http://syslinux.zytor.com/pxe.php>`_ utilities. 
Read the documentation on these pages to get an understanding of the process.

With PXELINUX the node should boot by DHCP and download (by TFTP) the file ``/tftpboot/pxelinux.0``
which will subsequently download configuration files from ``/tftpboot/pxelinux.cfg/`` on the DHCP server.

SYSLINUX Menu systems
---------------------

With newer versions of SYSLINUX it is possible to PXE-boot into the
`SYSLINUX menu systems <http://syslinux.zytor.com/menu.php>`_ where many booting options can be configured.

One should build the SYSLINUX software and copy these files to ``/tftpboot``::

  pxelinux.0
  com32/modules/*.c32

The file ``README.menu`` explains how to configure the SYSLINUX menu systems.

The menu system must be configured, a simple ``default.menu`` file in ``/tftpboot/pxelinux.cfg/`` is::

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

  label CentOS-4.4-i386
        menu label Installation of CentOS-4.4-i386, no kickstart
        kernel CentOS-4.4/vmlinuz
        append load_ramdisk=1 initrd=CentOS-4.4/initrd.img network


Pxeconfig toolkit
=================

The pxeconfig_ toolkit written by Bas van der Vlies automates the reinstallation of a node ``nodename``,
which is easily performed by configuring the DHCP server using ``pxeconfig``::

  pxeconfig nodename
    (select one of the available pxe configuration files)

Some more information is in https://wiki.fysik.dtu.dk/Niflheim_system/

.. _pxeconfig: https://gitlab.com/surfsara/pxeconfig
