.. _RHEL_installation:

==================================
Installation of RHEL and clones
==================================

Note: This page is somewhat outdated, but most tasks are still relevant. (OHN, Jan-2023)

.. Contents::

Hardware considerations
============================

UEFI boot with PXE
------------------

See the page https://wiki.fysik.dtu.dk/ITwiki/PXE_and_UEFI

Disks over 2 TB with GPT
------------------------

If the machine's boot disk is 2 TB or larger, it will have a *GUID Partition Table* (GPT_).
BIOS based machines will in this case require an extra biosboot_ partition, see https://lists.centos.org/pipermail/centos/2016-August/160561.html

In the :ref:`Kickstart` file you may define an extra first partition::

  part biosboot --fstype=biosboot --size=1

However, a better method is using reqpart_::

  reqpart --add-boot

The reqpart_ Automatically creates partitions required by your hardware platform.
These include a ``/boot/efi`` partition for systems with UEFI firmware, a biosboot_ partition for systems with BIOS firmware and GPT.

The ``--add-boot`` creates a separate ``/boot`` partition, so you should **not** specify the ``/boot`` partition yourself.

.. _GPT: https://en.wikipedia.org/wiki/GUID_Partition_Table
.. _biosboot: https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Installation_Guide/sect-disk-partitioning-setup-x86.html
.. _reqpart: http://pykickstart.readthedocs.io/en/latest/kickstart-docs.html#reqpart

Automatic installation
===========================

Fysik Linux Workstations are installed using :ref:`Kickstart` booting from the
network with PXE_ (*Preboot Execution Environment*).
In this way we are able to make an automated and fast setup on different types of hardware.

.. _Kickstart: https://docs.fedoraproject.org/en-US/fedora/latest/install-guide/advanced/Kickstart_Installations/

.. warning::
   Do not try to remember any of these steps, always follow the guide step by step! If your disagree with the guide, change the guide, but do not stray from the path of the guide. Missing a step leads to inconsistency, inconsistency leads to insecurity, insecurity leads to suffering...

.. _PXE: https://en.wikipedia.org/wiki/Preboot_Execution_Environment

Preparation
-----------

The hostname to ip address is controlled on the DNS name server where en entry should be added to the domain in ``/etc/named/``.
Please put the entries in numerical order.
Do not forget to restart the service::

  systemctl restart named

The installation is performed by PXE_ booting the computer.
This means the DHCP_ server needs to assign a well known ip address to the machine.
You can make a copy of a skeleton host entry in the the ``dhcpd.conf`` and add the unknown MAC_address_ to this entry.
Please put the entries in alphabetical order. Do not forget to::

  systemctl restart dhcpd

.. _MAC_address: https://en.wikipedia.org/wiki/MAC_address

Installation procedure
============================

Boot the machine and watch it load the Anaconda_ installer from the network, then find something else to do for the next fifteen minutes - to one hour.

You may need to enable booting from the net in the BIOS (on some of our machines you must enable *Network Service Boot* or similar).

When the installation has finished, the computer will reboot.

.. _Anaconda: https://en.wikipedia.org/wiki/Anaconda_(installer)

Enabling NFS exports
--------------------

This host must be able to NFS mount the */home/camp* from the servcamd fileserver, and */home/rpm* (read-only) from the intra fileserver.
You must verify that the hostname is listed in ``servcamd:/etc/exports`` and ``intra:/etc/exports``; otherwise add it like the other hostnames and run::

  exportfs -a

In addition to standard packages we need the following packages::

  yum install sendmail-cf

The following packages cannot be added during installation, they must be installed after the system is up and running::

  yum install autofs yum-cron

Add package repositories
============================

EPEL repository
---------------

You may wish to add the EPEL_ package repository with extra packages.
Install the newest version of *epel-release*:

  * CentOS8::

      dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

  * CentOS7::

      yum install epel-release

  * RHEL7: See https://fedoraproject.org/wiki/EPEL
    Install the RPM::

      yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

.. _EPEL: https://fedoraproject.org/wiki/EPEL

You may wish to install some packages from EPEL_::

  yum install Lmod git-all python34-pip python2-pip

RPM Fusion repository
---------------------

Some RPMs are not in CentOS or EPEL, so you can enable the RPM_Fusion_ repository::

  yum install https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm

.. _RPM_Fusion: https://rpmfusion.org/Configuration/
