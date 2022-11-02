.. _Calendar:

Calendar service
================

.. Contents::

The central DTU Exchange server contains shared calendars for all *mailbox users* (**not** mail contacts, i.e., external addresses).

We have set up a DavMail service gateway service at DTU Fysik.

Outlook users
-------------------------------

Users of `Microsoft Outlook <http://en.wikipedia.org/wiki/Microsoft_Outlook>`_ have built-in calendar functions.

**To be written...**

Outlook Web Access at DTU
-------------------------------

If your mailbox is hosted by the DTU Exchange server, you can access your mailbox **including calendar items** using Microsoft *Outlook Web Access* (OWA).
You simply log in to the `DTU Outlook Web Access server <https://mail.win.dtu.dk/>`_ using a web browser.

Thunderbird users
-------------------------------

There is a Danish website for Mozilla calendars at http://wiki.mozilladanmark.dk/wiki/Kalender.
You can also look at http://kb.mozillazine.org/.

The `Thunderbird extension <https://addons.mozilla.org/en-US/thunderbird/>`_ Lightning_ can be used to enable calendar messages within Thunderbird.

Maybe we can also use `Provider for Microsoft Exchange <http://linux.softpedia.com/get/Internet/Thunderbird-Extensions/Provider-for-Microsoft-Exchange-58076.shtml>`_ (need to test it) ?

.. _Lightning: https://addons.mozilla.org/en-US/thunderbird/addon/lightning/

Thunderbird Lightning for Linux
-------------------------------

RPMs for Thunderbird Lightning_ can be found at http://www.rpmfind.net/:

* Lightning: http://www.rpmfind.net/linux/rpm2html/search.php?query=thunderbird-lightning
* Libical prerequisite: http://www.rpmfind.net/linux/rpm2html/search.php?query=libical

Perhaps this site can also be used: http://pkgs.org/package/thunderbird-lightning

Thunderbird Lightning for Windows
---------------------------------

In **Thunderbird 3.1** (and above) go to the menu item *Tools->Add-ons*:

* In this window use the *Get Add-ons* pane and search for **Lightning**.
* Click *Add to Thunderbird*.

After restarting, Thunderbird will have the Lightning_ calendar extension in the menu bar item **Events and Tasks**:

* Select *Events and Tasks->Calendar (Control+Shift+C)* to view the calendar pane.

Configuring Thunderbird for a DavMail calendar
----------------------------------------------

Set up a standard IMAP mail account (an `example <http://davmail.sourceforge.net/thunderbirdimapmailsetup.html>`_)
and then see the `Thunderbird calendar setup <http://davmail.sourceforge.net/thunderbirdcalendarsetup.html>`_.

At DTU, the DavMail service client should use this network *CalDAV* server address::

  https://xxx.yyy.dtu.dk:1080/users/USERNAME@win.dtu.dk/calendar

changing of course the *USERNAME*.

This has been tested on Windows with Thunderbird 3.1, Lightning 1.02beta.
It also seems OK on CentOS Linux with Thunderbird 2.0 and Lightning 0.9.

National holiday calendars
--------------------------

If you wish to import your national holiday calendar into your personal calendar, 
there is a list of calendars here `Calendar - Holiday Files <http://www.mozilla.org/projects/calendar/holidays.html>`_
which you can import using the *File->Import calendar...* menu.

Thunderbird LDAP directory setup
--------------------------------

DavMail service Directory support is now available to access Exchange address book through LDAP_.
See `Thunderbird directory setup <http://davmail.sourceforge.net/thunderbirddirectorysetup.html>`_

.. _LDAP: http://en.wikipedia.org/wiki/Ldap


Configuring Evolution for a DavMail calendar
-------------------------------------------------------------

The *evolution* calendar window is displayed by *View->Window->Calendars (Ctrl+3)*.

In the calendar pane, right-click and choose *New calendar*.
Select *Type=CalDAV* and in the *New calendar* window enter::

  URL:  https://davmail.fysik.dtu.dk:1080/users/USERNAME@win.dtu.dk/calendar
