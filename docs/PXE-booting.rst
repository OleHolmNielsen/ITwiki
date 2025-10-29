.. _PXE-booting:

============================================
PXE network booting of legacy BIOS computers
============================================

.. Contents::

This page describes the installation of a Linux OS on a **Legacy BIOS computer**
by means of PXE_ (*Preboot Execution Environment*) booting.
See also our page on:

* PXE_and_UEFI_ network booting.

.. _BIOS: https://en.wikipedia.org/wiki/BIOS
.. _PXE: https://en.wikipedia.org/wiki/Preboot_Execution_Environment
.. _PXE_and_UEFI: https://wiki.fysik.dtu.dk/ITwiki/PXE_and_UEFI
.. _UEFI: https://en.wikipedia.org/wiki/UEFI

SYSLINUX and PXELINUX
==========================

`PXE network booting <https://en.wikipedia.org/wiki/Preboot_Execution_Environment>`_
from Linux servers uses the `SYSLINUX <https://syslinux.zytor.com/>`_ and 
`PXELINUX <https://syslinux.zytor.com/pxe.php>`_ utilities
(see also this `Wikipedia article <https://en.wikipedia.org/wiki/Syslinux>`_).
Read the documentation on these pages to get an understanding of the process.
The `SYSLINUX source code <https://www.kernel.org/pub/linux/utils/boot/syslinux/>`_ has
additional very useful documentation which we have copied here: :ref:`syslinux.doc` and :ref:`pxelinux.doc`.

There is a `SYSLINUX mailing list <https://www.zytor.com/mailman/listinfo/syslinux>`_
as well as a `SYSLINUX Wiki <https://syslinux.zytor.com/wiki/index.php/Main_Page>`_.

.. toctree::
   :maxdepth: 1
   :caption: SYSLINUX documentation

   README.menu
   pxelinux.doc
   syslinux.doc

Boot process summary
--------------------

When a client computer performs a PXE_ network boot, the Linux DHCP_ server assigns the client an IP-address 
and further information including a TFTP-server address (DHCP_ ``next-server`` option)
and a boot image file name ``pxelinux.0`` (DHCP_ ``filename`` option).
The client retrieves the file ``pxelinux.0`` from the TFTP_ server and executes it.


The ``pxelinux.0`` PXELINUX boot image then attempts to download configurations files from the TFTP_ server
in the boot process `explained here <pxelinux.doc#how-to-configure-pxelinux>`_.
To summarize: The PXE/network client will use TFTP_ to download a PXELINUX configuration file
from the server's ``/tftpboot/pxelinux.cfg/`` directory
whose name is usually either:

 1) the client's hexadecimally encoded IP-address (such as ``0A018219``), or 
 2) the file named ``default``.

With `newer versions of SYSLINUX <https://www.kernel.org/pub/linux/utils/boot/syslinux/>`_
it is also possible to PXE-boot into the
`SYSLINUX menu systems <https://syslinux.zytor.com/menu.php>`_ where many booting options can be configured.
This is a very flexible way to boot, for example, diskette images with BIOS_ upgrades, hardware testers, or
Kickstart_ installation, etc.

.. _TFTP: https://en.wikipedia.org/wiki/Trivial_File_Transfer_Protocol
.. _DHCP: https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol
.. _Kickstart: https://anaconda-installer.readthedocs.io/en/latest/kickstart.html

Installing the SYSLINUX tools
-----------------------------

Although your Linux machine may already have some of the SYSLINUX tools installed, 
it is recommended that you get the latest `version of SYSLINUX <https://www.kernel.org/pub/linux/utils/boot/syslinux/>`_.

Unpack the tar-ball and copy the following SYSLINUX files to the ``/tftpboot`` directory on the DHCP_/TFTP_ server::

  tar xzvf syslinux-4.02.tar.gz
  cd syslinux-4.02
  cp core/pxelinux.0 memdisk/memdisk com32/modules/chain.c32 com32/menu/menu.c32 /tftpboot/

(version 4.02 is used in this example). 
Additional com32/\*/\*.c32 modules might be needed if further features from SYSLINUX will be used. 

For the older SYSLINUX version 3.x the locations of files differ a bit, so do::

  tar xzvf syslinux-3.51.tar.gz
  cd syslinux-3.51
  cp pxelinux.0 memdisk/memdisk com32/modules/*.c32 /tftpboot/


If for some reason you must rebuild SYSLINUX, first verify that you have the ``nasm`` package installed::

  rpm -q nasm

Then build SYSLINUX in the top-level directory by doing simply ``make``.  
See also the file ``distrib.doc`` for further details.

The default file
----------------

You must also create a default PXE boot file ``/tftpboot/pxelinux.cfg/default`` instructing the
node how to boot in case there is no hexadecimally encoded IP-address file.
Probably the most sensible default boot method is *local hard disk* which is configured as follows:

We assume that you have installed the SYSLINUX tools as shown above, in particular the `chain.c32 <https://syslinux.zytor.com/wiki/index.php/Comboot/chain.c32>`_ tool.
Then create the file named ``default`` containing these lines::

  default harddisk
  label harddisk
    kernel chain.c32
    append hd0

For comparison, in many places you will find the following recipe for the default file::

  default harddisk
  label harddisk
    localboot 0

This recipe can be error-prone and actually means *boot from the next device in the BIOS boot order*,
rather than booting from the hard disk as you would be led to believe.
For more information read this `article from the SYSLINUX mailing list <https://syslinux.zytor.com/archives/2006-August/007131.html>`_
(look at the bottom of the article).

Etherboot/gPXE
--------------

Something to consider for the future is the `Etherboot/gPXE project <https://www.etherboot.org/wiki/start>`_
which permits a larger set of boot media, includign also HTTP-servers.
For PXE-booting into gPXE see `PXE chainloading <https://www.etherboot.org/wiki/pxechaining>`_.

Linux and Windows deployment (WDS)
----------------------------------

A Microsoft *Windows Deployment Service* WDS_ takes over PXE_ booting of any PXE_ clients it has configured, thus the clients will ignore the Linux PXE_ boot server.

.. _WDS: https://en.wikipedia.org/wiki/Windows_Deployment_Services

For a solution, see `Linux and Windows deployment <https://www.syslinux.org/wiki/index.php/Linux_and_Windows_deployment>`_:

* This covers the setup and deployment of a PXE_ boot solution consisting of 2 pxe servers and one dhcp server. 
  The 2 PXE_ servers are linux and windows - the former running pxelinux and tftp and the latter one running WDS (Windows Deployment Services), with a linux server providing DHCP_ services.

See also `Peaceful Coexistence: WDS and Linux PXE Servers <https://www.vcritical.com/2011/06/peaceful-coexistence-wds-and-linux-pxe-servers/>`_:

* As it turns out, thanks to the lesser-known pxechain utility, it is possible to seamlessly jump from one PXE host to another.
  With a few tweaks to your WDS server, you can continue to use it for Windows OS installs and bounce over to a Linux host for Linux, ESXi, or rescue-CD purposes.

SYSLINUX Menu systems
=====================

With `newer versions of SYSLINUX <https://www.kernel.org/pub/linux/utils/boot/syslinux/>`_
it is possible to PXE-boot into the
`SYSLINUX menu systems <https://syslinux.zytor.com/menu.php>`_ where many booting options can be configured.
This is a very flexible way to boot, for example, diskette images with BIOS_ upgrades, hardware testers, or
Kickstart_ installation, etc.

Please consult the :ref:`README.menu` from the  SYSLINUX source.

One must first install SYSLINUX files to ``/tftpboot`` on the DHCP_/TFTP_ server as shown in `Installing the SYSLINUX tools`_.

Secondly, for each client machine that should use the SYSLINUX menu systems a hexadecimally encoded IP-address file
must be created in ``/tftpboot/pxelinux.cfg/``, pointing to the menu configuration file.
This can conveniently be done with the ``pxeconfig`` command discussed below.

An example ``default.menu`` SYSLINUX menu file in ``/tftpboot/pxelinux.cfg/`` is::

  DEFAULT menu.c32
  PROMPT 0
  
  MENU TITLE Menu from TFTP server

  label AlmaLinux8.8 minimal-x86_64
        menu label Clean AlmaLinux-8.8-x86_64, minimal install
        kernel AlmaLinux-8.8-x86_64/vmlinuz
        append load_ramdisk=1 initrd=AlmaLinux-8.8-x86_64/initrd.img network inst.ks=nfs:<some-IP-address>:/u/kickstart/ks-almalinux-8.8-minimal-x86_64.cfg vga=792

  label harddisk
        menu label Boot from local harddisk
        kernel chain.c32
        append hd0

This configuration will display a menu with 4 items, each performing a different task
as described in the ``menu label`` lines.

Password protection of PXELINUX menu items
------------------------------------------

It is possible to password protect a PXELINUX menu item in recent versions of PXELINUX, see https://www.syslinux.org/wiki/index.php/Menu#MENU_PASSWD.
For example, a menu item may have a line::

  menu passwd <password-hash>

To generate the MD5 or SHA1 password hash, make sure you have a recent version of syslinux, or download the code from https://www.kernel.org/pub/linux/utils/boot/syslinux/.
Locate the scripts ``sha1pass`` and ``md5pass`` (subdirectory ``utils/`` in the source).
Also, install this prerequisite::

  yum install perl-Crypt-PasswdMD5

Then you can execute ``sha1pass`` or ``md5pass`` to generate password hashes.

Alternatively, you can use the command ``/sbin/grub-md5-crypt`` (MD5 passwords only), or find some web-based tools.

Commandline key strokes
-----------------------

The command line prompt supports the following keystrokes (see :ref:`syslinux.doc`)::

  <Enter>         boot specified command line
  <BackSpace>     erase one character
  <Ctrl-U>        erase the whole line
  <Ctrl-V>        display the current SYSLINUX version
  <Ctrl-W>        erase one word
  <Ctrl-X>        force text mode
  <F1>..<F10>     help screens (if configured)
  <Ctrl-F><digit> equivalent to F1..F10
  <Ctrl-C>        interrupt boot in progress
  <Esc>           interrupt boot in progress
