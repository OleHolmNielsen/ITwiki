.. _Thunderbird_calendar:

========================================
Thunderbird calendar client setup at DTU
========================================

.. Contents::

Thunderbird mail and calendar client
====================================

This page explains several methods for using calendars with the Thunderbird_ mail client.
You **must** be using Thunderbird_ version 3.1 or higher.

.. _Thunderbird: http://www.mozilla.org/projects/thunderbird/

Thunderbird Lightning add-on
============================

The Thunderbird_ add-on named Lightning_ can be used to enable calendar messages within Thunderbird.

.. _Lightning: https://addons.mozilla.org/en-US/thunderbird/addon/lightning/

See also https://support.mozilla.org/en-US/products/thunderbird/calendar

There is a Danish website for Mozilla calendars at http://wiki.mozilladanmark.dk/wiki/Kalender, and some instructions on the page http://kimludvigsen.dk/programmer-tools-sunbird-trin.php
You can also look at http://kb.mozillazine.org/.

Installation of Thunderbird Lightning Add-on
--------------------------------------------

Open the Thunderbird_ *Add-on manager* (the *Tools->Add-ons* menu):

* In this window use the *Get Add-ons* pane and search for Lightning_.
* Click *Add to Thunderbird*.

After restarting, Thunderbird will have the Lightning_ calendar extension in the menu bar item **Events and Tasks**:

* Select *Events and Tasks->Calendar (Control+Shift+C)* to view the calendar tab.

Using a CalDAV calendar service gateway
=======================================

E-mail and calendar clients which do not use Microsoft's proprietary *Exchange* protocol must use
*Calendaring Extensions to WebDAV*, or CalDAV_, which is an Internet standard allowing a client to access scheduling information on a remote server.
At DTU Fysik we have set up a DavMail_ gateway service for use by non-Microsoft calendar clients at the address *davmail.fysik.dtu.dk*.
Several ways of accessing this calendar are described in the sections below.

.. _DavMail: http://davmail.sourceforge.net/index.html

Configuring Thunderbird Lightning for a DavMail calendar
--------------------------------------------------------

Set up a standard IMAP mail account as described at :ref:`How to set up Email at DTU Fysik <Email>`.
and then follow the `Thunderbird calendar setup <http://davmail.sourceforge.net/thunderbirdcalendarsetup.html>`_  (in French).

Summary of the setup of DavMail in Thunderbird Lightning:

- In Thunderbird enter the *Calendar* tab, right-click to get a menu and choose *New calendar...*

- Select: On the Network -> CalDAV

  At DTU Fysik, set the following network CalDAV_ server address::

      https://davmail.fysik.dtu.dk:1080/users/USERNAME@win.dtu.dk/calendar

  changing the *USERNAME*.  You **must** be a *mailbox user* on the Exchange server in order for this to work.

.. _CalDAV: http://en.wikipedia.org/wiki/CalDAV

Exchange Calendar and Tasks Add-on for Lightning (Thunderbird/Seamonkey)
========================================================================

The *Exchange* server offers an *Exchange Web Services* (EWS_) interface to calendars etc.

.. _EWS: http://msdn.microsoft.com/en-us/library/bb408417%28v=exchg.80%29.aspx

Installation of Exchange EWS Calendar and Tasks Add-on
------------------------------------------------------

You can install the Ericsson exchangecalendar_ extension to Lightning_ described as:

* The only add-on for Thunderbird and Seamonkey which will add access to you Exchange calendars, contacts and Global Address List [GAL].
  It is an add-on for the Lightning. Calendering Add-on and will allow you to communicate with an Exchange 2007, 2010 and 2013 server using the Exchange Web Service [EWS] interface.
  You can access any Calendar, Task or Contacts folder on the EWS server in an easy way.
  And also manage your [Out of Office] settings.

.. _exchangecalendar: https://github.com/Ericsson/exchangecalendar/wiki

Adding a DTU Exchange calendar
------------------------------

In the Thunderbird_ calendar pane (*Events and Tasks->Calendar*):

1. Right-click on a calendar and select **New Calendar...**.
2. In the *Create a New Calendar* window choose *On the network*.
3. Then choose the format *Microsoft Exchange 2007/2010* (as provided by this new add-on).
4. Assign a calendar name, color etc. in the next window.
   Use your own address in the *E-mail:* field.
5. In the next window *Exchange/Windows AD settings* enter the following *EWS server URL*
   (see the `how to add a calendar FAQ <http://www.1st-setup.nl/wordpress/?wp_super_faq=how-to-add-a-exchange-calendar>`_)::

     https://mail.win.dtu.dk/ews/exchange.asmx

   You should **not** use the *autodiscovery* checkbox since this function is not implemented in the FYS network.

6. The *Mailboxname* is either your E-mail address (the usual case)::

     initials@win.dtu.dk (or any E-mail alias)

   but for **shared calendars** you may also enter another user's E-mail (only if the mailbox owner has chosen to share his/her calendar with you).

7. The *Username* is your DTU initials, and the *Domain* is::

     win.dtu.dk

8. Now press the button **Check server and mailbox**. 
   You will be asked for your login name and password.
9. Press *Next* and *Finish* to complete the setup.
10. Wait a minute or two while the new calendar gets loaded into Thunderbird_.
    You may also right-click on the calendar and choose *Reload remote calendars*.

Using the Exchange calendar
---------------------------

Right-click on the new calendar to check:

* *Exchange (EWS) Properties* such as AD, Meetings and Folders.
* *Out of Office* settings such as auto-reply and dates.

External network calendars
==========================

Independently of which calendar client software you use, there are some network based calendars which you may want to consider subscribing to:

* **National holiday calendars:**
  If you wish to import your national holiday calendar into your personal calendar, 
  there is a list of calendars here `Calendar - Holiday Files <http://www.mozilla.org/projects/calendar/holidays.html>`_.
  For example the Danish Holidays are available at `DanishHolidays <http://www.mozilla.org/projects/calendar/caldata/DanishHolidays.ics>`_.

* Campusnet_Calendar_ at DTU:
  You can subscribe to your personal Campusnet_Calendar_
  as described in the `iCalendar-udgivelse <https://www.campusnet.dtu.dk/cnnet/calendar/iCalendar.aspx?userid=1>`_ page.
  In this case you must select the iCal_ calendar type (in stead of CalDAV_).

  **Note** that your personal Campusnet_Calendar` is accessible from calendar clients like thunderbird, ect. as **read-only**.

.. _iCal: http://en.wikipedia.org/wiki/Ical
.. _Campusnet_Calendar: https://www.campusnet.dtu.dk/cnnet/calendar/default.aspx

Configuring Thunderbird Lightning for an ICS calendar
=====================================================

- In Thunderbird enter the *Calendar* tab, right-click to get a menu and choose *New calendar...*

- Select: On the Network -> Icalendar (ICS), and provide url location of the \*.ics file.

Additional technical details
============================

Below are some technical details which are mainly of interest to **system administrators**.

Autodiscover DNS name
---------------------

The *Exchange Calendar and Tasks Add-on for Lightning* described above may use 
the DNS address ``autodiscover.xxx.dtu.dk``.
See the FAQ item http://www.1st-setup.nl/wordpress/?wp_super_faq=how-does-autodiscover-work

We have tried to make a DNS CNAME alias for ``autodiscover.fysik.dtu.dk`` pointing to ``mail.win.dtu.dk``.
This indeed makes mailbox autodiscovery work as expected.

Unfortunately, since the central Exchange server's SSL certificate doesn't belong to the fysik.dtu.dk domain, 
error messages were experienced with Outlook clients.
Therefore we no longer use the autodiscover DNS alias.

Thunderbird LDAP directory setup
--------------------------------

DavMail_ Directory support is now available to access Exchange address book through LDAP_.
See `Thunderbird directory setup <http://davmail.sourceforge.net/thunderbirddirectorysetup.html>`_.
**This still needs testing**.

.. _LDAP: http://en.wikipedia.org/wiki/Ldap


Building DavMail RPM
--------------------

Search for ready RPMS at `davmail at build.opensuse.org <https://build.opensuse.org/package/show?package=davmail&project=home%3Amarcindulak>`_.


To build using rpmbuild use the `DavMail source <http://sourceforge.net/projects/davmail/files/>`_ with the
`davmail.spec  <https://svn.fysik.dtu.dk/projects/rpmbuild/trunk/SPECS/davmail.spec>`_ file, and relevant source files from
`SOURCES  <https://svn.fysik.dtu.dk/projects/rpmbuild/trunk/SOURCES>`_.
Configure the rpmbuild environment as described at `configure rpmbuild <https://wiki.fysik.dtu.dk/niflheim/Cluster_software_-_RPMS#configure-rpmbuild>`_.

To build an RPM on a CentOS5 configure the following external repositories:

- http://blackopsoft.com/Main_Page (provides recent ant package)

- http://dev.centos.org/centos/5/CentOS-Testing.repo (provides jpackage-utils)

Set `enabled=0` in the `/etc/yum.repos.d/*.repo` file of those repositories, then install the required packages::

  yum install ant ant-antlr --enablerepo=c5-testing,blackop
