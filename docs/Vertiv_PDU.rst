#########################
Vertiv PDUs
#########################

This page contains information about Vertiv PDUs as delivered by Lenovo.

* Lenovo_PDU_ power distribution units.
* Vertiv `User Documentation for Lenovo <https://www.vertiv.com/en-us/support/avocent-support-lenovo/>`_.

.. _Lenovo_PDU: https://lenovopress.lenovo.com/lp1556-lenovo-1u-switched-monitored-3-phase-pdu
 
Login to PDU
============

Click ``Log In`` in the upper right hand corner of the web page.

PDUs delivered by Lenovo may have the default **USERID/PASSW0RD** login credentials.

In the **System** *Users* menu it is possible to edit or add users.
Apparently, these PDUs reject adding the ``root`` username with a message ``Error! Not authorized``,
probably because ``root`` is used internally in the system?

Configuration
==============

In the **System** menu make the following configurations:

* **Network:** Set an appropriate *Hostname* for the PDU.

* **Web Server:** In the *HTTP Interface* select *Redirected to HTTPS*.

* **Time:** Select the timezone ``Europe/Copenhaven``.

* **Email:** Select our local SMTP server name.
  Configure a suitable *"From" Email Address*.
  Configure a *Target Email address* for recipients of mails.

* **Admin:** Set *System Label* to an appropriate system name.

* **Locale:** Select *Temperature Units: Celsius*.

PDU firmware upgrades
==========================

PDU `firmware downloads <https://www.vertiv.com/en-us/support/software-download/power-distribution/geist-upgradeable-series-v6-firmware/>`_.
Unpack the zip-file and see the file ``readme.txt``.

The firmware update sub-menu is in the **System->Utilities** page.
Select the firmware file (for example, `geist-i03-6_1_2.firmware`), upload it and click ``Submit``.
After about 10 minutes the PDU will be running the new firmware.
