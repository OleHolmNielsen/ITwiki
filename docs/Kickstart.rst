.. _Kickstart:

======================
Kickstart installation
======================

.. contents::


Introduction
=============
The kickstart installation method provides a way to do automated installations of RedHat Linux and derivatives, while allowing the Anaconda installer to make decision about hardware support and packages dependencies.
For documentation see http://fedoraproject.org/wiki/Anaconda/Kickstart.

Using kickstart
===============

Kickstart is not "used" as such, it is more of a method for installation preparation. It uses a script (`ks.cfg`) to describes the steps necessary for installing Linux. The script and installation files are then provided through standard services like a CD/DVD, dhcp+tftp or a floppy disk.

RedHat provides a tool `system-config-kickstart`
for setting up a kickstart installation, which handles the creation of the `ks.cfg` file.

PXE configuration
=================

Network booting by
`PXE` (`Preboot Execution Environment <http://en.wikipedia.org/wiki/Preboot_Execution_Environment>`_) 
uses the `/tftpboot` directory for downloading files by `TFTP <http://en.wikipedia.org/wiki/Trivial_File_Transfer_Protocol>`_. 
In order to boot a machine into a Linux environment, the `PXELINUX <http://syslinux.zytor.com/pxe.php>`_ software is used.

The PXE/TFTP directory ``/tftpboot`` is organized with the following subdirectories:

 * ``pxelinux.cfg/``: Contains PXE *default.XXX* boot files, as well as soft links corresponding to 
   IP-addresses to be installed by PXE.

 * ``CentOS-4.X/`` (X=3,4): Contains the two files ``vmlinuz`` (kernel) and ``initrd.img`` (RAM-disk).

The *default.XXX* files refer to the actual kickstart files in ``/u/rpm/kickstart/``:: 

   ks-centos-4-clean.cfg  
   ks-centos-4-preserve-scratch.cfg

One of the options defined by these files are the choice of 
nfs install, via the nfs exported directory (u/rpm) on intra5::

   #Use NFS installation Media
   nfs --server=130.225.86.6  --dir=/u/rpm/iso/CentOS-4.4-i386

For a new release a new directory `/u/rpm/iso/CentOS-4.X` should be added 
and the ISO files placed in this directory, and the kickstart files should be modified accordingly.  
The ISO files should be downloaded from a Centos mirror site 
such as http://mirrors.fysik.dtu.dk/linux/centos/.

PXE boot parameters
-------------------

The PXE booting is controlled by a number of parameters in the PXE configuration file, for example::

  label CentOS5 clean-i386
        menu label Clean CentOS-5-i386, kickstart
        kernel CentOS-5-i386/vmlinuz
        append load_ramdisk=1 initrd=CentOS-5-i386/initrd.img network ks=nfs:130.225.86.4:/u/rpm/kickstart/ks-centos-5-clean-i386.cfg

Here the *append* parameters are documented in http://fedoraproject.org/wiki/Anaconda_Boot_Options.
The *Kickstart file* is controlled by the *ks=...* parameter which can use several types of resources such as nfs, http or ftp.
Please note that for RHEL6/CentOS6 that NFS defaults to **NFS version 4**, however, the *ks=* parameter also permits NFS mount options such as::

  ks=nfs:nfsvers=3:130.225.86.4:xxx

vmlinuz and initrd.img
----------------------

The boot kernel and initial file system used by *PXE* are the *vmlinuz* mini-kernel
and the *initrd* initial RAM-disk,  respectively.
These should be downloaded from a Centos mirror site 
in the ``centos/X/os/x86_64/isolinux/`` directory (replace X by actual version).

On the *intra5* DHCP/PXE server they are placed in ``/tftpboot/CentOS-X.Y`` directory for Centos version X.Y.
  
The PXE boot files in the ``/tftpboot/pxelinux.cfg`` directory must contain 
*default.XXX* files such as ``default.install-centos-4.4-clean`` which contain a reference to the new versions 
of `vmlinuz` and  `initrd` in ``/tftpboot/CentOS-X.Y``.

dhcpd.conf
----------

The following entry in ``/etc/dhcpd.conf`` enables PXE boot
by means of the `PXELINUX <http://syslinux.zytor.com/pxe.php>`_ software:: 

        # TFTP download from intra5:
        next-server 130.225.86.6;
        # Start up PXELINUX:
        filename "pxelinux.bin";

These lines are added to ``/etc/dhcpd.conf`` on the DHCP servers. 

Further reading
===============

Kickstart is described in the manuals on http://www.redhat.com/docs/manuals/:

* `RHEL5 Kickstart manual <http://www.redhat.com/docs/en-US/Red_Hat_Enterprise_Linux/5/html/Installation_Guide/ch-kickstart2.html>`_

* `RHEL4 Kickstart manual <http://www.redhat.com/docs/manuals/enterprise/RHEL-4-Manual/en-US/System_Administration_Guide_/Kickstart_Installations.html>`_
