.. _Exchange_IMAP_Email:

==========================================================================
How to set up Exchange IMAP Email via the central DTU Exchange mail server
==========================================================================

.. Contents::

The central DTU Exchange 2010 mail server offers E-mail service using Internet standard protocols (non-Outlook) for E-mail clients such as Thunderbird_ or Evolution_ at the address::

  mail.dtu.dk

**Warning**: automatic detection of settings (server names, port numbers) in an email client may fail, therefore make sure to use the manual settings provided below.

Please see first the information on DTU's *Portalen* at http://portalen.dtu.dk/DTU_Generelt/AIT/Services/Infrastruktur/Email/FAQ.aspx

.. _Thunderbird: http://www.mozillamessaging.com/en-US/thunderbird/
.. _Evolution: http://projects.gnome.org/evolution/features.shtml

Permission for sending mail by SMTP at DTU
==========================================

Due to problems with phished user accounts and subsequent abuses for spam E-mail, DTU has had to introduce special rules for sending mail by SMTP through the DTU mail server *mail.dtu.dk*.

All new users at DTU must contact their departmental IT support staff and ask them for the following assistance:

* Please add a new *IT role* named *SMTP Relay* in DTUBasen_ for your user account.

.. _DTUBasen: https://www.dtubasen.dtu.dk/

If you experience this error message::

  Login to server mail.dtu.dk failed

then you may have been hit by the above requirement.
Please contact your IT staff.


IMAP incoming mail server
=========================

Set up your IMAP mail client with these parameters:

* Use the IMAP server address **mail.dtu.dk**.
* For *Connection Security* select **SSL/TLS** (for Evolution_ select TLS).
* Set *Port* to **993**.
* For *Authentication Method* select **Normal password**.
* Type in your user name and, if desired, your password (only if secured with a *Master Password* or the like).

SMTP outgoing mail server
=========================

Define the SMTP outgoing mail server with these parameters:

* Use the SMTP server address **mail.dtu.dk**.
* Set port number **587** (default: 25). Some clients (like Evolution_) set the port like this: ``mail.dtu.dk:587``.
* Select **STARTTLS** connection security (for Evolution_ select TLS).
* For *Authentication Method* select **NTLM**.
* Type in your user name and, if desired, your password (only if secured from reading by others).

SMTP error conditions
---------------------

If you get the error message *5.7.1 Client does not have permissions to send as this sender* when trying to send mail,
there may be an incorrect setting for your account inside the Exchange server which needs to be fixed. 
Please report the problem to support@fysik.dtu.dk.
For details see `Client cannot send e-mail via authenticated SMTP., problem with "Mail from" <http://social.technet.microsoft.com/Forums/uk/exchangesvrtransport/thread/12bbf289-2132-4cc2-970c-50165290f6ed>`_.
The solution is copied here::

  Under Microsoft Exchange Management Console:
  Recipient Configuration | Mailbox
  Right Click on the user| Select "Manage Send As Permission"
  Click the Green +Add... button, add the "SELF" user, which will show up as "NT AUTHORITY\SELF"
  Click Manage | Finish

Exchange LDAP address book
==========================

The DTU Exchange server's LDAP address book can be accessed from Thunderbird.
We have copied (and changed slightly) the recipe from the `IMM IT wiki <https://itswiki.imm.dtu.dk/index.php/Exchange_address_book_in_thunderbird>`_,
replacing the DTU AIT Domain_controller_ name by one of the currently valid names:

1. Due to a Self-signed_certificate_ add the DTU AIT Domain_controller_ to the list of sites that Thunderbird_ trusts, even though the certificate is untrusted (self-signed):

   * Go to *Edit -> Preferences -> Advanced -> Certificates -> View certificates*, in the new window select *Servers -> Add exception* and type **AIT-PADFDC16.win.dtu.dk:636** and save the settings.

2. Go to *Tools -> Address book* and in the new window select *File -> New -> LDAP Directory* and fill out like this:

   * Name: **DTU LDAP directory**
   * Hostname: **AIT-PADFDC16.win.dtu.dk** (or some other AIT Domain_controller_)
   * Base DN: **OU=DTUBaseUsers,DC=win,DC=dtu,DC=dk**
   * Port number: **636**
   * Bind DN: **XXXX@win.dtu.dk**
     where XXXX is your DTU initials (username).
   * Make sure that **Use secure connection (SSL)** is selected.
   * In the Thunderbird_ *Tools->Address Book*, go to *View -> Show Name As* and choose *Last,First* or *First,Last* (but **not** *Display Name*) 

3. Hints:

   * You cannot search on a combination of first and last name, i.e. a search on "Anders Overgaard Bjarklev" returns nothing while a search on "Anders Overgaard" or "Bjarklev" provides the expected result.
   * The address book is only available from DTU IP addresses (but not DTU wireless). Download a offline copy to have it available from outside DTU. However, using a offline copy has reported as working rather unstable. 

Note: this setup is not widely tested yet but basic functionality should be OK. 

.. _Self-signed_certificate: http://en.wikipedia.org/wiki/Self-signed_certificate
.. _Domain_controller: http://en.wikipedia.org/wiki/Domain_controller

Mail-clients specific settings
==============================

First, please make sure that you have updated your mail client software (Thunderbird_, etc.) to the latest version,
both due to security updates, and also due to added functionality in later versions.

Mozilla Thunderbird 3.1 and above
---------------------------------

Thunderbird_\'s ``Sent`` and ``Trash`` folders are called ``Sent Items`` and ``Deleted Items`` on the *Microsoft Exchange* server, respectively
(see https://kb.mozillazine.org/IMAP_Trash_folder).

First make sure that you have actually subscribed to the IMAP folders ``Sent Items`` and ``Deleted Items``:

* Right-click on the account name and select *Subscribe:*

* In the *Subscribe* window check all folders that you want to see, including ``Sent Items`` and ``Deleted Items`` and press OK.
  These folders should appear shortly under the account name.

Now configure Thunderbird_ with the *Microsoft Exchange* folder names as follows:

* First open the Thunderbird_ *Account Settings* window 
  (under the *Tools* menu, or available in the right hand pane after selecting the account name).

* **Folders Sent, Drafts:** 

  * Under *Account Settings* -> *Copies & Folders* select the folders to use under *When sending messages, automatically*:

    * For example, use *Place a copy in->Other:*
    * Use the pull-down menu to select the appropriate account name and the folder under that account.

* **Trash folder:** To change the *Trash* folder into the *Microsoft Exchange* folder name *Deleted Items*, go to the *Account Settings* window:

  * Select *Server settings* and go to the item *When I delete a message:->Move it to this folder* 
  * Select from the pull-down menu the folder named *Deleted Items*.

**Note**: emails deleted under Thunderbird_ are *really* removed from the server only after right-clicking on the corresponding folder and
selecting the *Compact* action. This needs to be done for all default (``Deleted Items``, ``Drafts``, ``Inbox``, ``Sent Items``) folders separately.
