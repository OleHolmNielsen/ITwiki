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
* DKMS_ `Module signing <https://github.com/dkms-project/dkms#module-signing>`_.
  See also the file ``/etc/dkms/framework.conf``.

This procedure for signing kernel modules may work:

1. Generate an X509_ key pair (with a lifetime of 100 years) to the ``/var/lib/shim-signed/mok`` folder::

     openssl req -nodes -new -x509 -newkey rsa:2048 -outform DER -addext "extendedKeyUsage=codeSigning" -keyout /var/lib/shim-signed/mok/MOK.priv -out /var/lib/shim-signed/mok/MOK.der -days 36500 -subj "/CN=LOCALMOK/"
     openssl x509 -inform DER -in /var/lib/shim-signed/mok/MOK.der -text -noout

2. Collect the following files and form an enrolling request to shim. The files must be in DER_ format::

     mokutil --import /var/lib/shim-signed/mok/MOK.der

3. Reboot the server.
   During startup the server's UEFI_ menu will start, allowing to enroll keys to UEFI_,
   see `Machine Owner Key Enrollment <https://docs.fedoraproject.org/en-US/quick-docs/mok-enrollment/>`_.

   Security Implications:
   Note that the enrolled machine owner key will be used to sign any future updates to the module or 
   any other module you will decide to install and they will be implicitly trusted.
   All future updates will happen transparently with no interaction and/or authorization.
   Therefore, it’s recommended to delete the machine owner key when it’s no longer needed.

4. The following script will sign the VirtualBox.org_ kernel modules::

     #!/bin/bash
     readonly dir=/var/lib/shim-signed/mok
     readonly key="$dir/MOK.priv"
     readonly x509="$dir/MOK.der"
     readonly hash_algo="sha256"
     [ -z "${KBUILD_SIGN_PIN}" ] && read -sp "Passphrase for ${key}: " KBUILD_SIGN_PIN
     export KBUILD_SIGN_PIN
     sign_file="/usr/src/kernels/$(uname -r)/scripts/sign-file"
     libdir="/usr/lib/modules/$(uname -r)/misc"
     echo "Files are:"
     ls -la $sign_file $libdir
     $sign_file "${hash_algo}" "${key}" "${x509}" "$libdir/vboxdrv.ko"
     $sign_file "${hash_algo}" "${key}" "${x509}" "$libdir/vboxnetflt.ko"
     $sign_file "${hash_algo}" "${key}" "${x509}" "$libdir/vboxnetadp.ko"
     echo "Loading modules:"
     modprobe vboxdrv
     modprobe vboxnetflt
     modprobe vboxnetadp
     echo "Verify modules:"
     lsmod | grep vbox

DKMS MOK keys
..................

An alternative for DKMS_ may be to generate keys::

  # dkms generate_mok
  Signing key: /var/lib/dkms/mok.key
  Public certificate (MOK): /var/lib/dkms/mok.pub

Enroll the keys as described in the DKMS_ `Secure Boot <https://github.com/dkms-project/dkms#secure-boot>`_ page.

.. _UEFI: https://en.wikipedia.org/wiki/UEFI
.. _X509: https://en.wikipedia.org/wiki/X.509
.. _DER: https://www.ssl.com/guide/pem-der-crt-and-cer-x-509-encodings-and-conversions/

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
