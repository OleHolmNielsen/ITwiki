.. _Lenovo_DW612S:

========================
Lenovo DW612S enclosure
========================

.. Contents::

This page contains information about the Lenovo DW612S_ enclosure.

The DW612S_ is based upon Lenovo_Neptune_ liquid cooling technology.

Documentation
------------------

* The DW612S_ 6U enclosure.
* DW612S_documents_.
* DW612S_User_Guide_.

.. _Lenovo_Neptune: https://www.lenovo.com/us/en/servers-storage/neptune/
.. _DW612S: https://pubs.lenovo.com/dw612s_neptune_enclosure/
.. _DW612S_documents: https://pubs.lenovo.com/dw612s_neptune_enclosure/pdf_files
.. _DW612S_User_Guide: https://pubs.lenovo.com/dw612s_neptune_enclosure/dw612s_user_guide.pdf

Configuration of the DW612S System Management Module (SMM)
------------------------------------------------------------

Add the SMM Ethernet MAC address to the DHCP server, then go to the SMM login page.
The default administrator username may be *admin* or *USERID*,
and the password may be the default *PASSW0RD* or something else configured by Lenovo.

After logging in to the SMM Web Gui click on the *Configuration* tab:

* **Account Security**: Change *Minimum password length* and *Minimum password reuse cycle* as needed.
* **User account**: Change the login name (if desired), and/or add and enable your site's login username/password with **Administrator** priviledges.
* **Network Configuration**: Define the SMM's DNS hostname and domainname.
  You should leave IPv6 as enabled for future management access.
* Check the Date and time in **Time settings**.
* **NTP**: Set your site's NTP server and your Timezone.
* In **SMTP** define E-mail alerts:

  * Sender Information (for example, admin@smm.<domain>).
  * Destination Email Addresses for alert recipients.
  * SMTP (email) Server Settings.

SMM firmware updates
------------------------

* Locate the enclosure's *Serial Number* in the *System Information->Enclorure VPD* window.
* Locate the SMM firmware version in the *Summary->Enclosure Rear View* window.

Using the Serial Number, 

In the Data_Center_Support_ page search for the Serial Number.
Download firmware from the *Software&Drivers* menu.
Download the *payload* firmware zip file (for example, `lnvgy_fw_smm2_umsm12o-1.16_anyos_noarch.zip`)
and unzip it.
The required firmware file is the .rom file (for example, ``lnvgy_fw_smm2_umsm12o-1.16_anyos_noarch.rom``).

After logging in to the SMM Web Gui click on the *Configuration* tab and select *Firmware update*.
Here you browse for the .rom file and upload it for the firmware update to start.

.. _Data_Center_Support: https://datacentersupport.lenovo.com/us/en

