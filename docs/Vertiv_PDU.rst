#########################
Vertiv PDUs
#########################

.. toctree::
   :maxdepth: 1

This page contains information about Vertiv PDUs as delivered by Lenovo.

* Lenovo_PDU_ power distribution units.
* Vertiv `User Documentation for Lenovo <https://www.vertiv.com/en-us/support/avocent-support-lenovo/>`_.

.. _Lenovo_PDU: https://lenovopress.lenovo.com/lp1556-lenovo-1u-switched-monitored-3-phase-pdu
 
Login to PDU
============

Click ``Log In`` in the upper right hand corner of the PDU's web page.

PDUs delivered by Lenovo may have the default **USERID/PASSW0RD** login credentials.

In the **System** *Users* menu it is possible to edit or add users.
These PDUs reject adding the ``root`` username with a message ``Error! Not authorized``,
because the ``root`` user is used internally by the PDU's Linux OS (confirmed by Vertiv support September 2024):

* You should create a local administrator username, for example ``admin``.

SSH logins are possible but the PDU doesn't accept the most modern SSH keys::

  ssh USERID@<PDU-address>
  Received disconnect from <IP> port 22:2: Too many authentication failures

As a workaround use the ``ssh`` command and specify one specific (RSA) SSH key::

  ssh -i ~/.ssh/id_rsa.pub USERID@<PDU-address>

Using the CLI interface is not obvious since the (undocumented) HELP command only displays::

  USERID > help
  Usage: COMMAND PATH [= ARGUMENT]
  COMMAND
    [get, set, logout, add, delete, control, ack, sendTest, reset, reboot, help]
  PATH
    The API path (excluding "api" and separated by spaces) to which COMMAND will be applied.
  ARGUMENT
    The "data" field for the API request formatted as either JSON or YAML.

Configuration
==============

In the **System** menu make the following configurations:

* **Network:** Set an appropriate *Hostname* for the PDU.

* **Web Server:** In the *HTTP Interface* select *Redirected to HTTPS*.

* **Users:** Create a local administrator username, for example ``admin`` with *Admin* rights (``root`` is not an authorized username).

* **Time:** Select the timezone ``Europe/Copenhaven``.

* **Email:** Select our local SMTP server name.
  Configure a suitable *"From" Email Address*.
  Configure a *Target Email address* for recipients of mails.

* **Admin:** Set *System Label* to an appropriate system name, for example, the hostname.

* **Locale:** Select *Temperature Units: Celsius*.

PDU firmware upgrades
==========================

PDU `firmware downloads <https://www.vertiv.com/en-us/support/software-download/power-distribution/geist-upgradeable-series-v6-firmware/>`_.
Unpack the zip-file and see the file ``readme.txt``.

The firmware update sub-menu is in the **System->Utilities** page.
Select the firmware file (for example, `geist-i03-6_1_2.firmware`), upload it and click ``Submit``.
After about 10 minutes the PDU will be running the new firmware.
