.. _Email:

=========================
E-mail at DTU 
=========================

**Note:** Since May 2023 DTU users' mailboxes have been migrated to the Azure cloud service Office365_.
Users must configure their Office365_ DTU account, and using Azure_MFA_ is required for access.
See the DTU Inside page `Outlook mailboxes will be moved to the Cloud (Exchange Online) <https://www.inside.dtu.dk/en/medarbejder/it-og-telefoni/it-service-generelt/mailmigrering-foraar-2023>`_
including links to guides.
There is an internal `DTU Multifactor Authentication (MFA) guide <https://www.inside.dtu.dk/en/medarbejder/it-og-telefoni/it-support-og-kontakt/guides/mfa>`_.

In general Office365_ only supports Microsoft's Outlook_ E-mail clients, see AIT's Guides_for_Outlook_.

AIT's Outlook_FAQ_ covers a number of questions about Office365_.

.. _Office365: https://en.wikipedia.org/wiki/Microsoft_365
.. _Azure_MFA: https://learn.microsoft.com/en-us/azure/active-directory/authentication/concept-mfa-howitworks
.. _Guides_for_Outlook: https://www.inside.dtu.dk/en/medarbejder/it-og-telefoni/it-support-og-kontakt/guides/outlook
.. _Outlook_FAQ: https://www.inside.dtu.dk/en/medarbejder/it-og-telefoni/it-service-generelt/mailmigrering-foraar-2023/outlookfaq

Outlook app on DTU Windows PCs
==================================

If you use a DTU Windows PC and the Outlook_ app from Microsoft Office,
E-mail should work as before without any issues.
A restart of the PC is recommended if anything is not working quite right.

DTU webmail service
==========================

For web browser access to your DTU mailbox please use the Office365_ OWA_ webmail service:

* https://outlook.office365.com or the alias https://outlook.office.com

The changed web-site is documented in this `Inside page <https://www.inside.dtu.dk/en/medarbejder/it-og-telefoni/it-support-og-kontakt/guides/adgang-til-webmail>`_.
The previous OWA_ site https://mail.dtu.dk **does not work** correctly for login to the Office365_ mailboxes with certain web browsers.

.. _OWA: https://www.microsoft.com/en-us/microsoft-365/outlook/web-email-login-for-outlook

Non-Microsoft Email clients
================================

In general AIT only supports Microsoft's Outlook_ E-mail clients.
We have found some guides for non-Microsoft clients as shown below.
Please note the following points:

* If you already had configured DTU E-mail in an Outlook_ app on Apple or Android devices,
  you probably have to **delete the old DTU account** in the app before adding your DTU account.

* The Office365_ mailboxes require the so-called *Modern Authentication* (OAuth2_) using Azure_MFA_ and the Microsoft_Authenticator_ app on your smartphone.
  Everyone will have to connect to this Azure mail server for IMAP_ (incoming mail) as well as SMTP_ (outgoing mail)::

    outlook.office365.com

.. _OAuth2: https://en.wikipedia.org/wiki/OAuth
.. _Microsoft_Authenticator: https://www.microsoft.com/en-us/security/mobile-authenticator-app
.. _IMAP: https://en.wikipedia.org/wiki/Internet_Message_Access_Protocol
.. _SMTP: https://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol

iPhone/iPad E-mail clients
-----------------------------

AIT offers a number of Guides_for_Outlook_ including ``Setting up Outlook on an Iphone``.
You need to install the `Microsoft Outlook app for iPhone <https://apps.apple.com/us/app/microsoft-outlook/id951937596>`_.
According to the Outlook_FAQ_ you need to install the Microsoft_Authenticator_ app on iPhones.

Note: ``Keyboard apps`` on the iPhone seem to be blocked by the Outlook_ app, possibly due to a DTU security policy(?).

In addition the following pages may be helpful:

* See the Microsoft guide `Set up the Outlook app for iOS <https://support.microsoft.com/en-us/office/set-up-the-outlook-app-for-ios-b2de2161-cc1d-49ef-9ef9-81acd1c8e234>`_.

* If you previously had a ``DTU Exchange`` account defined in iOS, you should delete it now because it will not work with Office365_.
  See the guide `Deleting Office 365 Exchange Account from IOS Mail App <https://support.ucsd.edu/services?id=kb_article_view&sysparm_article=KB0033472>`_.
  This page also gives the following good advice::

    When having trouble with your email account,
    deleting your account and re-adding it can solve the issue.

.. _Microsoft_Authenticator: https://www.microsoft.com/en-us/security/mobile-authenticator-app

Mac E-mail clients
-----------------------------

On Mac computers the Apple_Mail_ app works correctly with Office365_ mail and calendar.
First you have to delete any pre-existing Exchange account,
then you create a new ``Exchange account`` with your username ``<DTU-initials>@dtu.dk``.

AIT offers a number of Guides_for_Outlook_ including ``Setting up DTU email in Outlook on MAC``.

In addition the following pages may be helpful:

* `How to Configure Office 365 in Mail on macOS <https://wikis.utexas.edu/display/cnsoitpublic/How+to+Configure+Office+365+in+Mail+on+macOS>`_.

.. _Apple_Mail: https://en.wikipedia.org/wiki/Apple_Mail

Android E-mail clients
-----------------------------

AIT offers a number of Guides_for_Outlook_ including ``Setting up Outlook on an android phone``.
You need to install the `Microsoft Outlook app for Android <https://play.google.com/store/apps/details?id=com.microsoft.office.outlook&hl=en&gl=US>`_.
According to the Outlook_FAQ_ you need to install the Microsoft_InTune_ app on Android phones.

**WARNING:** Do NOT install the `Microsoft Outlook Lite app <https://play.google.com/store/apps/details?id=com.microsoft.outlooklite&hl=en&gl=US>`_,
since this app does not have the functionality of the proper Outlook_ app!

.. _Microsoft_InTune: https://learn.microsoft.com/en-us/mem/intune/fundamentals/what-is-intune

Linux E-mail clients
-----------------------------

We have found some good help pages for Linux E-mail clients:

* `Microsoft 365 (Thunderbird) - Configure Modern Authentication <https://kb.wisc.edu/helpdesk/page.php?id=102005>`_.
* `How to Configure Thunderbird for Office 365 Using IMAP (Oauth2) <https://uit.stanford.edu/service/office365/configure/thunderbird-oauth2>`_.
* `Office 365: Configuring Gnome Evolution with Modern Authentication <https://oit.duke.edu/help/articles/kb0032012>`_.

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

* Microsoft Outlook_ users have built-in calendar functions.
* Microsoft Outlook_Web_Access_ (OWA).
  Login to Office365_ using a browser:

    https://outlook.office365.com or the alias https://outlook.office.com

.. _Outlook: https://en.wikipedia.org/wiki/Microsoft_Outlook
.. _Outlook_Web_Access: https://en.wikipedia.org/wiki/Outlook_Web_App

Adding holidays to the calendar
-----------------------------------

In the Outlook_Web_Access_ or Outlook_ for Windows you can add national holidays to your calendar.
In Outlook_Web_Access_ click on the calendar pane on the left and select ``+ Add calendar`` to open a pop-up window.
Here you can select ``Holidays`` to add the official holidays of many different countries to your calendar.

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
* Select the options you’d like to have synchronised. 
* **Remember** to change the ``Periodic synchronisation (in minutes)`` time field to something suitable, for example 5 minutes.
* Select ``Synchronize now`` to start synchronisation for the first time.

.. _Using-Thunderbird-with-O365: https://www.canterbury.ac.nz/media/documents/its/Using-Thunderbird-with-O365.pdf
.. _TBSync: https://addons.thunderbird.net/en-us/thunderbird/addon/tbsync/
.. _Provider_for_Exchange_ActiveSync: https://github.com/jobisoft/EAS-4-TbSync/
