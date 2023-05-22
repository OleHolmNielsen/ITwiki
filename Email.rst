.. _Email:

=========================
E-mail at DTU 
=========================

**Note:** Since May 2023 DTU users' mailboxes have been migrated to the Azure cloud service.
Users must configure their Office365_ DTU account, and using Azure_MFA_ is required for access.

.. _Office365: https://en.wikipedia.org/wiki/Microsoft_365
.. _Azure_MFA: https://learn.microsoft.com/en-us/azure/active-directory/authentication/concept-mfa-howitworks

DTU webmail service
==========================

For web browser access to your DTU mailbox please use the Office365_ OWA_ webmail service:

  https://outlook.office365.com

or:

  https://outlook.office.com

This is documented in this `Inside page <https://www.inside.dtu.dk/en/medarbejder/it-og-telefoni/it-support-og-kontakt/guides/adgang-til-webmail>`_.

The previous OWA_ site https://mail.dtu.dk **does not work** reliably for login to the Office365_ mailboxes.

.. _OWA: https://www.microsoft.com/en-us/microsoft-365/outlook/web-email-login-for-outlook

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
Therefore we have to look elsewhere for guides for non_Microsoft clients.

**Note:** The Office365_ mailboxes require the so-called *Modern Authentication* (OAuth2_) using Azure_MFA_ and the Microsoft_Authenticator_ app on your smartphone.
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

Thunderbird calendar and address book client
------------------------------------------------

Thunderbird can use the Office365_ Global Address Book and Calendar,
see the document Using-Thunderbird-with-O365_ from `University of Canterbury <https://www.canterbury.ac.nz>`_:

* We need to add a couple of extensions to Thunderbird.
  Click on the ``Menu`` icon at the top right of the Thunderbird window and choose ``Addons and Themes`` from the menu.
  A new tab will open with a search bar at the top labelled ``Find more add-ons``.
* Search for TBSync_ which should be the first result of your search. Click and follow the prompts to install it.
* You may have noticed on the search results another add-on called Provider_for_Exchange_ActiveSync_.
  Install this too as TBSync_ requires it.

Now configure the TBSync_ plugin:

* Return to your ``Inbox`` tab and then click on the TBSync_ icon in the top right corner, next to the ``Menu`` icon.
* The TBSync_ window will open where you can add a new account.
  At the bottom left of the window you’ll see a drop down menu labelled ``Account actions``.
  Click on this and add a new ``Exchange ActiveSync account``.
* A new window will open asking you to choose a server configuration.
  Select ``Microsoft Office 365``.
* Then specify an account name that’s relevant to you.
  It’s just a label so it can be anything.
  Underneath that you need to enter your email address.
  Click ``Add account``.
* Another window may open, from Microsoft, asking for your password.
  If you indicated during your email account setup that you wanted to stay signed in then this part may be skipped.
  Otherwise proceed here just as you did when you setup your email account for the first time.
* Assuming all went well with your password you should be returned to the TBSync_ setup window with an entry for your newly created account on the left side of the window.
* You may notice though that synchronisation is disabled.
  Turn this on by choosing the ``Enable and synchronize this account``.
  At that moment a list of available resources is displayed.
* Select the options you’d like to have synchronised, and change the periodic synchronisation time to something suitable.
* Select ``Synchronize now`` to start synchronisation for the first time.

.. _Using-Thunderbird-with-O365: https://www.canterbury.ac.nz/media/documents/its/Using-Thunderbird-with-O365.pdf
.. _TBSync: https://addons.thunderbird.net/en-us/thunderbird/addon/tbsync/
.. _Provider_for_Exchange_ActiveSync: https://github.com/jobisoft/EAS-4-TbSync/
