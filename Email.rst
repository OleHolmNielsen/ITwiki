.. _Email:

=============
E-mail at FYS
=============

.. Contents::

The FYS computer systems has a carefully managed E-mail system with a spam filtering mechanism.
We support the following E-mail client softwares:

* `Mozilla Thunderbird <http://www.mozilla.com/en-US/thunderbird/>`_.
* Microsoft Outlook: Only for users connected to the central DTU Exchange server (please contact Ole Mogensen for setup).

Setting up an E-mail client
===========================

When setting up your favorite E-mail client on a desktop PC on the FYS network, you should configure it with:

* Server type: **IMAP** (we recommend **not** to use the POP3 method).
* Use secure connection: **SSL** (Use default port 993) with "Normal password"
* IMAP incoming server name: imap.fysik.dtu.dk
* Outgoing SMTP server: mail.fysik.dtu.dk (**unselect** the box *Use name and password*).

Additional setups for Mozilla Thunderbird
-----------------------------------------

Some specific settings that pertain to Mozilla Thunderbird:

IMAP server settings
....................

* Click on *Advanced...* and **uncheck** the box *Server supports folders that contain sub-folders and messages*.

Setup of SMTP server
....................

In the default SMTP server setup at FYS you have to make this setup:

* In the *SMTP server (SMTP) Settings* tab, click on *Edit* and locate the field *Security and Authentication*: Please **uncheck** the *Use name and password* box.

Alternatively, you can use the `E-mail for mobile and home use`_ setup shown below.

Attachment forwarding
.....................

An additional setting in *Thunderbird 3* (*not* older versions) is how mail messages get forwarded.
We recommend to forward messages as **Attachments**.
This is configured by:

1. Go to the *Tools->Options...* menu.
2. In the *Options* window select the pane *Composition->General*.
3. Find the item *Forward messages:* and select **As Attachment** and press the OK button.

E-mail for mobile and home use
------------------------------

If you use a laptop PC that may be at arbitrary locations on the Internet, or if you would like to use the FYS
mailservers from your desktop PC at home, we recommend some configurations in addition to the above.
You can also use the setup below with PCs located on the FYS network.

For Mozilla Thunderbird go the the E-mail account setup window and select the *Outgoing server (SMTP)*,
add a new default SMTP server with the following settings:

* Description: **DTU FYS SMTP AUTH server**
* Server name: **smtp.fysik.dtu.dk**
* Port: **587** (Default: 25)
* **Check** the box *Use name and password*
* Type in your FYS network **username** (*not* your E-mail address) in *User Name:*
* Choose the connection security as follows:

  - **Thunderbird version 3.x**:

    1. **Uncheck** the item *Use secure authentication* # only on Linux?
    2. In *Connection security* choose the value **STARTTLS**  with "Normal password"

  - **Thunderbird version 2.x**:

    1. In *Use secure connection* select **TLS** 

  - **Mac OS X Mail**:

    1. In the *Preferences/Accounts*, for *Outgoing Mail Server* choose *Edit SMTP server list*.
    2. Select the server, choose *Advanced*.
    3. Select **Use Secure Socket Layer (SSL)**
    4. Select **Use custom port** and set it to 587.  (The combination of SSL and port 587 or 25 is interpreted as 
       the variant of SSL often known as STARTTLS).

Now click OK a few times to save the settings.  Using this new SMTP server, try to send an E-mail message.
The first time around you will be asked to accept a *security certificate* from the mail server.
Next, and every time you start the mail application, you will be asked to enter the password of your account at FYS.

We recommend **not to save** the password in the mail client software for security reasons, unless you configure the use of a
Thunderbird **master password** (see the *Preferences* window's *Privacy->Passwords* tab).

Further reading for those interested in the technical details: 

* The `SMTP AUTH protocol <http://en.wikipedia.org/wiki/SMTP_AUTH>`_.
* The standard **port 587** used for `mail submission <http://en.wikipedia.org/wiki/Mail_submission_agent>`_
  is defined in `RFC4409 <http://www.ietf.org/rfc/rfc4409.txt>`_.
* How to set up an :ref:`SMTP_AUTH_server`.

If sending of mail fails
------------------------

Sending of mail may fail for many different reasons.
Below we list some workarounds we have found.

McAfee virus scanner blocks outgoing mail from Thunderbird
..........................................................

**Symptom:** When trying to send mail with Thunderbird on a Windows PC for the first time, an error message pops up::

  The message could not be sent because connecting to SMTP server smtp.fysik.dtu.dk failed. ...

If ``smtp.fysik.dtu.dk`` is actually working (try with a ``ping`` command), then we have seen the error to be caused by what we think is a bug in the
**McAfee 8.7i** anti-virus scanner (Patch 4 on Windows 7).
A workaround is:

1. Open McAfee 8.7i *VirusScan Console* (unlock *User Interface* if necessary).
2. Right-click on *Access Protection* and click *Properties*.
3. In the new window with *Access Protection Rules* click on *Anti-virus Standard Protection*.
4. In the right-hand pane locate the line *Prevent mass-mailing worms from sending mail* and **unselect** (remove checkmark) the *Block* rule.

   You could of course select *Edit...* and try to add ``thunderbird.exe`` to the *Processes to exclude*,
   but this is exactly where the bug in McAfee seems to be: It doesn't work ! 

5. Click OK a few times. Now all processes should be able to send mail.

Setups for mobile phones
------------------------

Many phones can be set up for E-mail access using *IMAP* and sending of E-mail using *SMTP*.
You should use the above described settings, in particular the settings for mobile use.

Here we list additional setups for specific mobile phone models that we have tried:

 * *Nokia 6700 Classic*: E-mail setups are in *Messaging->Message settings->E-mail messages->Edit mailboxes*.

   The IMAP4 server settings are in the *Incoming mail settings* submenu, where you must set *Security=Secure port* (SSL) and *Port=993*.

   You must also set *Use pref. access pt.=No* (meaning unknown), if *Yes* no connection can be obtained.

Calendar
========

Calendar feature is described  at `Calendar <http://wiki.fysik.dtu.dk/it/Calendar>`_

Vacation auto-reply
===================

When you are away on vacation or at a conference, you may want to set up an automatic reply to incoming messages.

This auto-reply feature can unfortunately not be set up on the FYS mailserver by the user himself.
You must send a message to support@fysik.dtu.dk containing:

1. The message text (in English and/or Danish) that you want in the auto-reply.

2. The date and time for the **start** and **end** of the auto-reply.

Problems accessing the SMTP server
==================================

If you receive an error message when trying to send mail using the SMTP AUTH service that the server is *not responding* or *not available*, 
you may do the following checks:

1. If your computer is connected directly to the cabled network within FYS, please make sure that you **really** are connected
   to the network by, for example, browsing some WWW-pages or use other network service.

2. If you are using a network outside the FYS premises, or if you are using the DTU Wireless network, you have probably been hit
   by the network's firewall rules that may block the usual SMTP port 25 (for reasons of virus containment).
   You are strongly encouraged to change your mail client software's setup to use *port 587 for mail submission* as described in the preceding section.

Migrating mailboxes from DTU Fysik to another email account
===========================================================

When leaving DTU Fysik users may prefer to transfer the contents of
their mailboxes from the DTU Fysik mailserver to another email account.

This can be achieved in Mozilla Thunderbird (or other clients) by:

- configuring both DTU Fysik and another email account.
  The "another mail account" must use the `IMAP <http://en.wikipedia.org/wiki/Internet_Message_Access_Protocol>`_ protocol
  (for example for gmail see `Enabling IMAP <http://mail.google.com/support/bin/answer.py?hl=en&answer=77695>`_),
- selecting emails and moving them between accounts - the servers will perform synchronization
