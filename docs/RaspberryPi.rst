.. _RaspberryPi_devices:

===================
RaspberryPi devices
===================

This page describes how to install RaspberryPi_ devices.

.. _RaspberryPi: https://www.raspberrypi.com

OS download
===========

Download an appropriate Raspberry_Pi_OS_ image.
Read about the `Legacy version <https://www.raspberrypi.com/news/new-old-functionality-with-raspberry-pi-os-legacy/>`_
of the Raspberry_Pi_OS_ based on the Debian Buster release.

.. _Raspberry_Pi_OS: https://www.raspberrypi.com/software/operating-systems/

Write OS to an SD card
======================

A computer with an SD_card_ writer is required, see https://www.raspberrypi.com/software/

The *sudo* password or root superuser password will be required to write to disk devices.

.. _SD_card: https://en.wikipedia.org/wiki/SD_card

On a Linux computer there are several tools:

* The GNOME_disks_ GUI tool, start from CLI by::

    gnome-disks &

  Use the menu item *Restore Disk Image...*.
  This tool can unzip compressed images on-the-fly.

.. _GNOME_disks: https://wiki.gnome.org/Apps/Disks


* The `CLI procedure <https://www.xmodulo.com/write-raspberry-pi-image-sd-card.html>`_ can also used:

  * First identify the SD_card_ block device::

      lsblk

    For example, the SD_card_ device may be ``/dev/sdb``.

  * If the SD_card_ already contains data, erase the card::

      sudo dd bs=4M if=/dev/zero of=/dev/sdb oflag=sync status=progress

    This can take several minutes.

  * Unzip the image file with ``unxz``, for example::

      unxz 2022-04-04-raspios-buster-armhf-lite.img.xz

  * Write the image file to the SD_card_::

      sudo dd bs=4M if=/path/to/image of=/dev/sdb oflag=sync status=progress

    This can take several minutes.

OS updates
==========

After booting the OS, update the Debian OS by::

  sudo apt upgrade

Raspbian configuration
======================

Several settings must be updated:

* Keyboard layout
* Date and NTP
* Timezone
* SSH server

In the *Desktop* version edit the *Preferences*.  In the *Lite* version::

  sudo raspi-config

SSH server
----------

The SSH server is enabled in ``raspi-config`` under *Interface options*.

NTP client
----------

The NTP configuration from DHCP is ignored.
You have to configure the NTP server IP-address -in ``/etc/systemd/timesyncd.conf``, for example::

  NTP=192.38.82.136

and restart the service::

  systemctl restart systemd-timesyncd

Apache web server
-----------------

Install this package::

  apt install apache2

This will start the web server on port 80 (HTTP).

**Warning:** Older versions of the Apache web server has critical security issues!
Apache should be version 2.4.53 or newer, see https://httpd.apache.org/security/vulnerabilities_24.html.
The Raspbian versions have these versions:

* Bullseye: Apache version 2.4.53
* Buster: Apache version 2.4.38 (insecure)
