.. _VirtualBox:

==========================
Oracle VirtualBox on Linux
==========================

.. Contents::

Install VirtualBox
========================

The VirtualBox.org_ application has a GPL license.
The VirtualBox Extension Pack is available for personal and educational use on this page under the PUEL_ license.
The VirtualBox Extension Pack is also available under commercial or enterprise terms.

Please see the `VirtualBox documentation <https://www.virtualbox.org/wiki/Documentation>`_
and `Download VirtualBox for Linux Hosts <https://www.virtualbox.org/wiki/Linux_Downloads>`_.
It is most convenient to install VirtualBox using the Yum repository::

  cd /etc/yum.repos.d
  wget https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo
  dnf install VirtualBox-7.2

You will want to install *Dynamic Kernel Module Support* (DKMS_) to ensure that the VirtualBox host kernel modules (vboxdrv, vboxnetflt and vboxnetadp) are properly updated if the linux kernel version changes during the next kernel update.

First you must enable the EPEL_ repository, then::

  dnf install dkms

.. _VirtualBox.org: https://www.virtualbox.org
.. _PUEL: https://www.virtualbox.org/wiki/VirtualBox_PUEL
.. _EPEL: https://fedoraproject.org/wiki/EPEL
.. _DKMS: https://en.wikipedia.org/wiki/Dynamic_Kernel_Module_Support

UEFI Secure Boot and signed kernel modules
---------------------------------------------

* `Installing Virtualbox and Secure Boot / Kernel Signing <https://forums.virtualbox.org/viewtopic.php?t=113162>`_.

When you enable `Secure Boot`_ in the system UEFI_/BIOS,
any kernel modules will by default be rejected because they are unsigned in the UEFI_/BIOS.

You will need to take some actions.
Please see the :ref:`DKMS_Kernel_Module_Support` page for further details on configuration.

.. _X509: https://en.wikipedia.org/wiki/X.509
.. _DER: https://www.ssl.com/guide/pem-der-crt-and-cer-x-509-encodings-and-conversions/
.. _Secure Boot: https://en.wikipedia.org/wiki/UEFI#Secure_Boot
.. _UEFI: https://en.wikipedia.org/wiki/UEFI
.. _shim: https://github.com/rhboot/shim/blob/main/README.md
.. _MOK: https://www.baeldung.com/linux/mok-machine-owner-key

Test builds
===========

For the latest kernels, for example for CentOS 8 Stream, it may be necessary to install the VirtualBox.org_ `Test builds version <https://www.virtualbox.org/wiki/Testbuilds>`_.

VirtualBox Extension Pack
=========================

For support of USB devices, RDP and more within the Virtual Machine, you must first install the *Oracle VM VirtualBox Extension Pack*, see the page:

* https://www.virtualbox.org/wiki/Downloads.

You may use the *File Manager* to open the downloaded file (will open it using VirtualBox),
or you can use the command line, see https://www.virtualbox.org/manual/ch08.html#vboxmanage-extpack::

  wget http://download.virtualbox.org/virtualbox/XXX/Oracle_VM_VirtualBox_Extension_Pack-xxx.vbox-extpack
  VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-xxx.vbox-extpack

You may have to add your shell (/bin/bash, for example) to the ``/etc/shells`` file.lBox_Extension_Pack-xxx.vbox-extpack

You may have to add your shell (``/bin/bash``, for example) to the ``/etc/shells`` file.

To list or uninstall Extension Packs see the VBoxManage_ extpack_ documentation::

  VBoxManage list extpacks
  VBoxManage extpack uninstall "Oracle VM VirtualBox Extension Pack"

USB devices on the host are enabled as explained in https://www.virtualbox.org/manual/ch03.html#settings-usb.

**Important:** Make sure to add the desktop user to the *vboxusers* group::

  usermod -a -G vboxusers <username>

and check the current groups in another GUI window::

  groups

.. _VBoxManage: https://www.virtualbox.org/manual/ch08.html
.. _extpack: https://www.virtualbox.org/manual/ch08.html#vboxmanage-extpack

Managing VirtualBox users
=========================

**Important:** 
Make sure to add the desktop user to the *vboxusers* group::

  usermod -a -G vboxusers <username>

The user must re-login to become a member of the *vboxusers* UNIX group.
Then open VirtualBox, go to *Settings->USB* and enable the USB 2.0 controller.
There should **not** be any error messages about missing USB support!

Resize virtual disk
===================

See `How to resize a Virtual Drive <https://forums.virtualbox.org/viewtopic.php?f=35&t=50661>`_.
For VirtualBox 6.0.x and later:

* Select the ``File->Tools`` menu and click on ``Virtual Media Manager``.
* Find your VDI, make sure the "Properties" is enabled in the toolbar, select the "Attributes" on the bottom part.
* There is a slider and a numeric control there, that you can use to adjust the VDI size.

Now you have to resize the file system inside the guest OS using its storage management tool.
For Windows 10:

* Right-click the start button and select *Disk management*.

* Right-click on the C: drive and select *Extend volume*.

* In the *Extend Volume Wizard* select how much you want to extend the disk.

Potential problems:

* If the *Extend volume* menu item is greyed out, there is probably not free space immediately following the disk (C:) you are trying to extend.
  You have to delete or move the volume allocated right after the disk.

* The *Recovery partition* may be deleted using **diskpart**, see https://www.diskpart.com/articles/delete-recovery-partition.html
