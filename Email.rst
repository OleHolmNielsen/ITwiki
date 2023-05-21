.. _Email:

=========================
E-mail at DTU 
=========================

**Note:** Since May 2023 DTU users' mailboxes have been migrated to the Azure cloud service.
Users must configure their Office365 DTU account, and using Azure_MFA_ is required for access.

.. _Azure_MFA: https://learn.microsoft.com/en-us/azure/active-directory/authentication/concept-mfa-howitworks

DTU webmail service
==========================

For web browser access to your DTU mail please use the DTU webmail service at https://mail.dtu.dk.

AIT guides on setting up an E-mail client
==============================================

In general AIT only supports Microsoft's Outlook E-mail clients.
Please see AIT's Mail_FAQ_ on *Inside*:

* AIT/DTU `Office 365 <https://www.inside.dtu.dk/da/medarbejder/it-og-telefoni/it-support-og-kontakt/guides/software/office365>`_.
* `Mobile phones <https://www.inside.dtu.dk/en/medarbejder/it-og-telefoni/it-support-og-kontakt/it-systemer-og-vaerktoejer/it-systemer-ait/email/faq/mobil>`_.
* `Mac <https://www.inside.dtu.dk/en/medarbejder/it-og-telefoni/it-support-og-kontakt/it-systemer-og-vaerktoejer/it-systemer-ait/email/faq/mac>`_.
* `Mozilla Thunderbird <https://www.inside.dtu.dk/en/medarbejder/it-og-telefoni/it-support-og-kontakt/it-systemer-og-vaerktoejer/it-systemer-ait/email/faq/thunderbird>`_.

.. _Mail_FAQ: https://www.inside.dtu.dk/en/medarbejder/it-og-telefoni/it-support-og-kontakt/it-systemer-og-vaerktoejer/it-systemer-ait/email/faq

Non-Microsoft Email clients
================================

In general AIT only supports Microsoft's Outlook E-mail clients.
Therefore we have to look elsewhere for guides.

**Note:** The Office365 mailboxes require OAuth2_ authentification using Azure_MFA_ and the Microsoft_Authenticator_ app on your smartphone.
Everyone will have to connect to this Azure mail server for IMAP_ (incoming mail) as well as SMTP_ (outgoing mail)::

  outlook.office365.com

.. _OAuth2: https://en.wikipedia.org/wiki/OAuth
.. _Microsoft_Authenticator: https://www.microsoft.com/en-us/security/mobile-authenticator-app
.. _IMAP: https://en.wikipedia.org/wiki/Internet_Message_Access_Protocol
.. _SMTP: https://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol

Apple E-mail clients
-----------------------------

If you use an Apple device the following pages may be helpful:

* `Set up an Outlook account on the iOS Mail app <https://support.microsoft.com/en-us/office/set-up-an-outlook-account-on-the-ios-mail-app-7e5b180f-bc8f-45cc-8da1-5cefc1e633d1>`_.

* `How to Configure Office 365 in Mail on macOS <https://wikis.utexas.edu/display/cnsoitpublic/How+to+Configure+Office+365+in+Mail+on+macOS>`_.


Linux E-mail clients
-----------------------------

* `Thunderbird <https://kb.wisc.edu/helpdesk/page.php?id=102005>`_.
* `GNOME Evolution <https://oit.duke.edu/help/articles/kb0032012>`_.

In all IMAP/SMTP mail clients the following server settings must be used:

* Incoming server (IMAP)::

    Hostname: outlook.office365.com
    Port: 993
    Connection security: SSL/TLS
    Authentication Method: OAuth2
    Username: <DTU-initials>@dtu.dk

* Outgoing server (SMTP)::

    Hostname: outlook.office365.com
    Port: 587
    Connection security: STARTTLS
    Authentication Method: OAuth2
    Username: <DTU-initials>@dtu.dk

Authentication of your login will proceed with Azure_MFA_ and the Microsoft_Authenticator_ app on your smartphone.

Calendar client setup at DTU
==================================

For **configuring calendar client software on your PC** we offer the following advice:

* Microsoft `Outlook <http://en.wikipedia.org/wiki/Microsoft_Outlook>`_ users have built-in calendar functions.
* Microsoft `Outlook Web Access <http://en.wikipedia.org/wiki/Outlook_Web_App>`_ (OWA): You simply log in to the `DTU Outlook Web Access server <https://mail.win.dtu.dk/>`_ using a web browser.
