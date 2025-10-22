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
* SMM2_ management module SMM2_Users_Guide_.
* SMM2_ functions and IPMI commands.
* SMM2_Messages_ and events.

.. _Lenovo_Neptune: https://www.lenovo.com/us/en/servers-storage/neptune/
.. _DW612S: https://pubs.lenovo.com/dw612s_neptune_enclosure/
.. _DW612S_documents: https://pubs.lenovo.com/dw612s_neptune_enclosure/pdf_files
.. _DW612S_User_Guide: https://pubs.lenovo.com/dw612s_neptune_enclosure/dw612s_user_guide.pdf
.. _SMM2: https://pubs.lenovo.com/mgt_tools_smm2/
.. _SMM2_Users_Guide: https://pubs.lenovo.com/mgt_tools_smm2/smm2_users_guide.pdf
.. _SMM2_Messages: https://pubs.lenovo.com/dw612s_neptune_enclosure/messages_introduction

Configuration of the DW612S System Management Module 2 (SMM2_)
---------------------------------------------------------------

Add the SMM2_ Ethernet MAC address to the DHCP server, then go to the SMM2_ login page.
The default administrator username may be *admin* or *USERID*,
and the password may be the default *PASSW0RD* or something else configured by Lenovo.

After logging in to the SMM2_ Web Gui click on the *Configuration* tab:

* **Account Security**: Change *Minimum password length* and *Minimum password reuse cycle* as needed.
* **User account**: Change the login name (if desired), and/or add and enable your site's login username/password with **Administrator** priviledges.
* **Network Configuration**:

  - Define the SMM2_'s DNS ``Host Name`` and ``DNS Domain Name``.
  - You should leave IPv6_ as enabled for future management access.
  - Click on **Advanced Settings** network ``eth0`` name and define:

    o **IPv4 method:** Obtain IP from DHCP
    o Check the box **Use DHCP to obtain DNS server addresses**
    o Click ``Apply`` (you will be logged out and have to login again)
    o Return to this page and check that the ``Preferred DNS Server`` IP-address is correct.

* Check the Date and time in **Time settings**.
* **NTP**: Set your site's NTP server and your Timezone.
  Click ``Apply`` and ``Sync Time Now``.
* In **SMTP** define E-mail alerts:

  * Sender Information (for example, admin@smm.<domain>).
  * Destination Email Addresses for alert recipients.
  * SMTP (email) Server Settings.
  * Test SMTP by ``Send Alert 1`` (correct network DNS server configuration is required)

.. _IPv6: http://en.wikipedia.org/wiki/Ipv6

SMM2_ ipmitool commands
------------------------

The SMM2_ ipmi_command_list_ page lists IPMItool_ IPMI_ commands that can get or set SMM2_ parameters.

Some example commands are::

  ipmitool -I lanplus -H <SMM2-hostname> -U $IPMI_USER -P $IPMI_PASSWORD raw 0x32 <options>

.. _ipmi_command_list: https://pubs.lenovo.com/mgt_tools_smm2/ipmi_command_list
.. _IPMI: https://en.wikipedia.org/wiki/Intelligent_Platform_Management_Interface
.. _IPMItool: https://github.com/ipmitool/ipmitool

SMM2_ firmware updates
------------------------

* Locate the enclosure's *Serial Number* in the *System Information->Enclorure VPD* window.
* Locate the SMM2_ firmware version in the *Summary->Enclosure Rear View* window.

Using the Serial Number, 

In the Data_Center_Support_ page search for the Serial Number.
Download firmware from the *Software&Drivers* menu.
Download the *payload* firmware zip file (for example, `lnvgy_fw_smm2_umsm12o-1.16_anyos_noarch.zip`)
and unzip it.
The required firmware file is the .rom file (for example, ``lnvgy_fw_smm2_umsm12o-1.16_anyos_noarch.rom``).

After logging in to the SMM2_ Web Gui click on the *Configuration* tab and select *Firmware update*.
Here you browse for the .rom file and upload it for the firmware update to start.
**Important**: Make sure that ``Preserve Settings`` is selected.

.. _Data_Center_Support: https://datacentersupport.lenovo.com/us/en

