.. _ZFS_filesystems:

===============
ZFS filesystems
===============

.. Contents::

The ZFS_ filesystem is an alternative to XFS.
It has a ZFS_on_Linux_ port.
See also the OpenZFS_ developers page.

.. _ZFS: https://en.wikipedia.org/wiki/ZFS
.. _ZFS_on_Linux: https://zfsonlinux.org/
.. _OpenZFS: https://openzfs.org/wiki/Main_Page

ZFS documentation
============================

* Getting_Started_ with ZFS_ including an RHEL-based-distro_ guide.

* First time OpenZFS users are encouraged to check out Aaron_Toponce_ ’s excellent documentation.

* OpenZFS_Newcomers_ documentation.

* `ZFS Basic Concepts <https://openzfs.github.io/openzfs-docs/Basic%20Concepts/index.html>`_.

* `ZFS man-pages <https://openzfs.github.io/openzfs-docs/man/index.html>`_.

* Lustre_ and ZFS_:

  - Lustre_ uses ZFS_, see https://wiki.lustre.org/ZFS.
  - A `ZFS setup for Lustre <https://github.com/ucphhpc/storage/blob/main/zfs/docs/zfs.rst>`_.
  - A `JBOD Setup <https://github.com/ucphhpc/storage/blob/main/jbod/doc/jbod.rst>`_ page.

* `Zpool Concepts <https://openzfs.github.io/openzfs-docs/man/7/zpoolconcepts.7.html>`_.

.. _Getting_Started: https://openzfs.github.io/openzfs-docs/Getting%20Started/index.html
.. _RHEL-based-distro: https://openzfs.github.io/openzfs-docs/Getting%20Started/RHEL-based%20distro/index.html
.. _Aaron_Toponce: https://pthree.org/2012/12/04/zfs-administration-part-i-vdevs/
.. _OpenZFS_Newcomers: https://openzfs.org/wiki/Newcomers
.. _Lustre: https://wiki.lustre.org/Main_Page

Installation of ZFS
=========================

We assume an EL8_ OS in this page.
Following the RHEL-based-distro_ guide, enable the *zfs-release* repo from ZFS_on_Linux_::

  dnf install https://zfsonlinux.org/epel/zfs-release-2-2$(rpm --eval "%{dist}").noarch.rpm

(The ``rpm --eval "%{dist}"`` command simply prints ``.el8`` or similar for your OS).

Use the DKMS_ kernel module installation method::

  dnf install epel-release
  dnf install kernel-devel
  dnf install zfs

The alternative *kABI-tracking kmod* installation method may break the ZFS_on_Linux_ software after kernel upgrades.

.. _DKMS: https://en.wikipedia.org/wiki/Dynamic_Kernel_Module_Support
.. _EL8: https://en.wikipedia.org/wiki/Red_Hat_Enterprise_Linux_derivatives

Trying out ZFS
====================

Aaron_Toponce_ 's page has some initial examples.

Create a simple zpool_ named *tank* with 4 unused drives (sde sdf sdg sdh)::

  zpool create tank sde sdf sdg sdh
  zpool status tank
  df -Ph /tank

Destroy the testing zpool_::

  zpool destroy tank

A mirrored pool where all data are mirrored 4 times::

  zpool create tank mirror sde sdf sdg sdh

A RAID 0+1 pool::

  zpool create tank mirror sde sdf mirror sdg sdh

.. _zpool: https://openzfs.github.io/openzfs-docs/man/8/zpool.8.html
