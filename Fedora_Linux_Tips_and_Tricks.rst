.. _Fedora_Linux_Tips_and_Tricks:

============================
Fedora Linux Tips and Tricks
============================

.. Contents::

Fedora Linux
============

The Fedora Linux homepage is http://fedoraproject.org/

Tips and tricks
---------------

* GNOME Shell features: https://live.gnome.org/GnomeShell/CheatSheet
* GNOME instruction videos: http://www.youtube.com/watch?v=t4fhsgZbgKk&feature=endscreen

GNOME-fallback
==============

The new gnome offers basic functionality with the left menu bar for storing common application shortcuts,
and the "microsoft windows" key on they keyboard for showing the separate desktops.

If you really want to get the old look of the desktop, follow http://www.itadmintools.com/2011/12/setup-gnome-classic-on-fedora-16.html :

- install::

    yum install dconf-editor

- launch dconf-editor and navigate to: Applications > System Tools -> org -> gnome -> desktop -> session.
  Change session-name to **gnome-fallback**

In order to be able to store icons/shortcuts on the desktop follow
http://www.zdnet.co.uk/blogs/the-open-source-revolution-10014902/thoughts-on-gnome-3-and-fedora-16-linux-10025216/ :

- launch dconf editor and navigate to: Applications > System Tools -> org -> gnome -> desktop -> background.
  Check **show-desktop-icons**.

GNOME multiple desktops
=======================

If you want to use multiple desktops to group your windows, this is possible by deffault in GNOME 3.
Please watch this video: http://www.youtube.com/watch?v=bRHAio98n-g.

Basically you press the keyboard *Windows* button to see the window overview.
Just drag a window to the desktop list on the right, and new desktops will be created dynamically.

GNOME extensions
================

This is an alternative way the the section above.

The `GNOME <http://www.gnome.org>`_ desktop version 3.2 is default in Fedora 16.
Here we collect some usability tips and tricks for GNOME 3.2.

Control of GNOME extensions may be controlled by the GNOME *Applications->Advanced Settings* tool, a tool to customize advanced GNOME 3 options..
This tool may be installed (by root)::

  yum install gnome-tweak-tool

Normal users want to use this tool for configurations::

  gnome-tweak-tool

In *gnome-tweak-tool* users may want to look at:

* *Windows->Windows focus mode* to configure *focus follow mouse*, for example.

Multiple desktop extension
--------------------------

**Obsolete:** You can use GNOME 3 to handle multiple desktops.

To make GNOME 3.2 look more like GNOME 2 with separate desktops you can install these *GNOME extensions* using the *Firefox* browser:

* `Frippery Static Workspaces <https://extensions.gnome.org/extension/12/static-workspaces/>`_
* `Frippery Bottom Panel <https://extensions.gnome.org/extension/3/bottom-panel/>`_

In *Firefox* select the **ON** button (next to the OFF button) on the above pages to activate these two extensions.

Controlling desktops and windows
--------------------------------

The `wmctrl <http://www.sweb.cz/tripie/utils/wmctrl/>`_ (*interact with a EWMH/NetWM compatible X Window Manager*) tool controls the desktops and windows.
Install this tool by::

  yum install wmctrl

Usage of wmctrl is shown by ``wmctrl`` without arguments or in the man-page.


Limit Alt-Tab to the current workspace
--------------------------------------

Restore the Gnome 2 behaviour:
https://ask.fedoraproject.org/question/28819/is-there-a-way-to-make-alttab-only-see-the-current-workspace/


Lock Screen
===========

On Fedora 19 there is no lock screen button, nor does the usual Ctrl+Alt+L shortcut work.
This may be a bug in GNOME 3.

In order to restore the Ctrl+Alt+L shortcut (but *not* the lock screen button) for user **user**::

  yum install gnome-screensaver  # as root
  su - user
  mkdir -p .config/autostart
  cp /etc/xdg/autostart/gnome-screensaver.desktop  .config/autostart
  sed -i '/AutostartCondition/d' ~/.config/autostart/gnome-screensaver.desktop  # Remove line with AutostartCondition

The problem is mentioned here https://bugs.launchpad.net/ubuntu/+source/gnome-screensaver/+bug/1120126
and http://www.osvdb.org/show/osvdb/91260.
Solution is suggested where???

Serial port (outgoing)
======================

To use the PC serial port (if any) for outgoing connections (for example, connection to a network switch serial management port), install the *minicom* package::

  yum install minicom

You may check the serial port device::

  # file /dev/ttyS0
  /dev/ttyS0: character special

and change permissions if non-root users are allowed to use it::

  root# chmod 666 /dev/ttyS0

Connect to the serial port::

  minicom -D /dev/ttyS0

Read the *minicom* man-page to learn more about setup and usage.
Use *Control-A* to access menus.
Some useful options are:

* Exit the serial session: *Control-A X*
* Communication parameters: *Control-A P*
* Serial port setup: *Control-A O* (configuration), then select *Serial port setup*.
  Use this for configuring `Flow control <http://en.wikipedia.org/wiki/Flow_control_%28data%29>`_.


Virtual Machine applications
============================

There are several possibilities for installing Virtual Machine applications:

Oracle VirtualBox on Fedora
---------------------------

The VirtualBox_ application has a GPL license.
You can download Fedora RPMs from the `VirtualBox Linux download <https://www.virtualbox.org/wiki/Linux_Downloads>`_ page.

.. _VirtualBox: https://www.virtualbox.org

Please see the `VirtualBox documentation <https://www.virtualbox.org/wiki/Documentation>`_.
You probably want to install *Dynamic Kernel Module Support (DKMS)*::

  yum install dkms

For support of USB devices, RDP and more within the Virtual Machine, you must first install the *Oracle VM VirtualBox Extension Pack*, see the page https://www.virtualbox.org/wiki/Downloads.
You may use the *File Manager* to open the downloaded file (will open it using VirtualBox),
or you can use the command line, see https://www.virtualbox.org/manual/ch08.html#vboxmanage-extpack::

  VBoxManage extpack install <.vbox-extpack>

You may have to add your shell to the ``/etc/shells`` file if you get an error message about this file.

USB devices on the host are enabled as explained in https://www.virtualbox.org/manual/ch03.html#settings-usb.
One may need to follow the procedure in http://www.kernelhardware.org/fedora-virtualbox-usb-working/.
Note that the correct entry in /etc/fstab is::

  echo none /vbusbf usbfs rw,devgid=501,devmode=664 0 0 >> /etc/fstab

with 501 replaced by GID of the *vboxusers* group in /etc/group.
Make sure to add the desktop user to the *vboxusers* group::

  usermod -a -G vboxusers <username>

Now reboot the PC!
Then open VirtualBox, go to *Settings->USB* and enable the USB 2.0 controller.
There should **not** be any error messages about missing USB support!

Adobe Flashplayer
=================

Adobe Flash Player::

  ## Adobe Repository 32-bit x86 ##
  yum install http://linuxdownload.adobe.com/adobe-release/adobe-release-i386-1.0-1.noarch.rpm
 
  ## Adobe Repository 64-bit x86_64 ##
  yum install http://linuxdownload.adobe.com/adobe-release/adobe-release-x86_64-1.0-1.noarch.rpm

Update Repositories::

  yum check-update

Install Adobe Flash Player::

  yum install flash-plugin

This advice was from this site: http://www.if-not-true-then-false.com/2010/install-adobe-flash-player-10-on-fedora-centos-red-hat-rhel/
