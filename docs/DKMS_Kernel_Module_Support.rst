.. _DKMS_Kernel_Module_Support:

===============================================
Dynamic Kernel Module Support (DKMS) for Linux
===============================================

.. Contents::

DKMS concepts
=====================

*Dynamic Kernel Module Support* (DKMS_) is a program/framework that enables generating Linux kernel modules whose sources generally reside outside the kernel source tree.
The concept is to have DKMS_ modules automatically rebuilt when a new kernel is installed.

Dynamic Kernel Modules are typically used for:

* GPU drivers
* ZFS filesystems
* Infiniband network adapters

Secure Boot and DKMS
=======================

When you enable `Secure Boot`_ in the system BIOS for the first time, 
any DKMS_ kernel modules will by default be rejected because they are unsigned in the BIOS.
As described in the `DKMS project`_ page,
on an UEFI_ system with `Secure Boot`_ enabled, modules require signing before they can be loaded,
and the firmware of the system must know the correct public certificate to verify the module signature.

The DKMS_ software installation (``dkms generate_mok``)
creates a DKMS_ signing key ``/var/lib/dkms/mok.pub`` which can be imported into the BIOS.
The article `OpenZFS work with secure boot <https://www.reddit.com/r/zfs/comments/1y06xmb/need_help_making_openzfs_work_with_secure_boot_on/>`_
explains how to check whether the DKMS_ key is actually enrolled and loaded in UEFI_/BIOS::

  mokutil --sb-state
  mokutil --test-key /var/lib/dkms/mok.pub
  sudo keyctl list %:.machine
  sudo keyctl list %:.platform

You can list the enrolled certificate with the mokutil_ command::

  mokutil --list-enrolled | grep DKMS

You should see the DKMS_ module signing key in one of the two keyrings.
If not, use mokutil_ to make a MOK_ key import request to the UEFI_/BIOS::

  sudo mokutil --import /var/lib/dkms/mok.pub 

A (temporary) password for the key must be input,
and it will be required for the `MokManager` screen below.

Reboot the server.
You can enable `Secure Boot`_ in the BIOS at this point.

When the OS is booting, the BIOS will present a blue `MokManager` (*shim UEFI key manager*) screen
to ``Enroll MOK`` for the DKMS_ module imported above.

Quickly press the ``Enroll MOK`` item, then press to enroll the DKMS_ key where you have to enter the above password.
When the import is complete, `MokManager` requests a reboot of the server.

Notes:

* `MokManager` is a UEFI_ utility launched by the Linux shim_ bootloader to manage *Machine Owner Keys* (MOK_)
  and binary hashes when UEFI_ `Secure Boot`_ is enabled.

* The `MokManager` tool has a timeout of 10 seconds, and if the timeout is exceeded
  the server boots normally 
  Then you must repeat the above MOK_ key import request process.

When the server has been booted, the DKMS_ kernel modules will be loaded correctly.
You can use the above ``mokutil`` and ``keyctl`` commands to verify the keys.

.. _DKMS: https://en.wikipedia.org/wiki/Dynamic_Kernel_Module_Support
.. _Secure Boot: https://en.wikipedia.org/wiki/UEFI#Secure_Boot
.. _UEFI: https://en.wikipedia.org/wiki/UEFI
.. _shim: https://github.com/rhboot/shim/blob/main/README.md
.. _MOK: https://www.baeldung.com/linux/mok-machine-owner-key
.. _mokutil: https://man.archlinux.org/man/extra/mokutil/mokutil.1.en
.. _DKMS project: https://github.com/dkms-project/dkms/blob/main/README.md#secure-boot
