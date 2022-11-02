.. _SMTP_AUTH_server:

=================================
How to set up an SMTP AUTH server 
=================================

.. Contents::

Overview
========

Disclaimer: This page is for a RedHat Linux server.  The general aspects should be applicable to other distributions as well.

We wish to enable **authenticated mail relaying** (with username/password) from all Internet sites,
as a convenient service for our people that are travelling or work from home, especially when using 
laptops both at work and remotely.

It is apparently **not possible** to mix authenticated (SMTP AUTH) and unauthenticated (SMTP) mail relaying on the same server,
so we have to use a dedicated server for this purpose.

As explained in http://en.wikipedia.org/wiki/SMTP_AUTH:

 * SMTP-AUTH is an extension of the Simple Mail Transfer Protocol (SMTP) to include an authentication step through which the client effectively logs in 
   to the mail server during the process of sending mail. Servers which support SMTP-AUTH can usually be configured to require clients to use this extension,
   ensuring the true identity of the sender is known.
   SMTP-AUTH is defined in RFC 4954.

Sendmail listening on port 587
==============================

Roaming SMTP clients may often be blocked from sending mail on the usual port 25, which ISPs block for reasons of spam control.

A solution of this problem is to have the SMTP AUTH session connect to the SMTP server at another port in addition to port 25.
This is described in the RHEL file ``/etc/mail/sendmail.mc``::

  dnl # The following causes sendmail to additionally listen to port 587 for
  dnl # mail from MUAs that authenticate. Roaming users who can't reach their
  dnl # preferred sendmail daemon due to port 25 being blocked or redirected find
  dnl # this useful.
  dnl #
  DAEMON_OPTIONS(`Port=submission, Name=MSA, M=Ea')dnl

**But**, this configuration will make the server **only** listen on port 587 and **not** on port 25 !
You can add port 25 in addition to port 587 by adding also these lines::

  dnl # This line will add the usual port 25 as well
  DAEMON_OPTIONS(`Port=smtp, Name=MTA')dnl

This configuration is suggested in `this HOWTO <http://www.corvidworks.com/articles/configure-sendmail-to-listen-on-multiple-ports>`_ article.

The port names *smtp* and *submission* are defined in the ``/etc/services`` file as ports 25 and 587, respectively.

Do a ``make`` and restart the sendmail daemon.
The Sendmail configuration option is explained in this page:
http://www.sendmail.org/~gshapiro/8.10.Training/DaemonPortOptions.html

We must also make sure that port 587 is open in the DTU router filters (firewall).

Mail client configuration for using port 587 is described in http://kb.wisc.edu/helpdesk/page.php?id=2786

The port 587 feature is described in `RFC 2476 <http://www.faqs.org/rfcs/rfc2476.html>`_.

Sendmail with SSL
=================

Delivery of mail using the SMTP protocol with the Sendmail mail-server software can be authenticated and encrypted with SSL.
There is an excellent guide `Using SMTP AUTH and STARTTLS with sendmail <http://www.joreybump.com/code/howto/smtpauth.html>`_
which is much easier to use than the authoritative pages on 
`Sendmail AUTH <http://www.sendmail.org/~ca/email/auth.html>`_
and `Sendmail STARTTLS <http://www.sendmail.org/~ca/email/starttls.html>`_.

Even though the procedure shown below works correctly for SMTP AUTH and STARTTLS, please beware of these issues:

  1. It probably **does not work** on a server for incoming mail from the Internet
     because that would require other SMTP servers to use SMTP AUTH and STARTTLS.

  2. Local mail clients will be forced to accept the server's SSL-certificate, even though they may not use SSL.

Setup of SMTP AUTH
==================

Create a sendmail.pem certificate as explained in the above SMTP AUTH guide:
Make your certificate (note that on Fedora Core 4 the location is now /etc/pki/tls/certs)::

  cd /usr/share/ssl/certs
  make sendmail.pem 

We make some local modifications of the above SMTP AUTH guide:

 * Copy your certificate to ``/etc/pki/tls/certs/sendmail.pem`` (for RedHat/CentOS 5).

 * The RedHat configuration file ``/etc/mail/sendmail.mc`` already contains the (commented out) configuration lines needed for SMTP AUTH,
   so you only need to uncomment them.
   However, remember to add the ``y`` flag (deny anonymous relaying) in the line::

     define(`confAUTH_OPTIONS', `A p y')dnl

We choose to have the SMTP AUTH server relay mail to the Internet by itself, and this is probably the best solution.
It would also be possible to relay through your.mail.server (replace as needed) first by defining this line::

  define(`SMART_HOST', `your.mail.server')dnl

Further Sendmail configuration
------------------------------

Our configuration file ``/etc/mail/sendmail.mc`` also has a few throttling parameters set::

  define(`confMAX_MESSAGE_SIZE', `20480000')
  define(`confTO_COMMAND',`5m')dnl
  define(`confTO_DATABLOCK', `10m')dnl
  define(`confTO_DATAFINAL', `10m')dnl
  define(`confMAX_DAEMON_CHILDREN', `20')dnl
  define(`confCONNECTION_RATE_THROTTLE', `3')dnl
  define(`confBAD_RCPT_THROTTLE', `5')dnl
  define(`confREFUSE_LA',`12')
  define(`confQUEUE_LA',`8')

Accepting SMTP AUTH from poorly configured addresses
----------------------------------------------------

We had initially some complaints from users at IP-addresses that did *not* have a reverse-DNS hostname.
The reason is that Sendmail by default refuses connections from such hosts.
In the maillog you will see error messages like this one::

  Jan 30 16:41:22 web2 sendmail[30782]: n0UFepRJ030782: ruleset=check_rcpt, arg1=<xxx@fysik.dtu.dk>, relay=[x.x.x.x], reject=550 5.7.1 <xxx@fysik.dtu.dk>... Relaying denied. IP name lookup failed [x.x.x.x] 

The solution was reported in http://osdir.com/ml/redhat.release.enigma/2002-05/msg00057.html suggesting to configure also::

  FEATURE(delay_checks)dnl

so that the sending host check is deferred until after the SMTP AUTH has accepted the user.

This problem was **not** described in any known guides about SMTP AUTH,
although the above mentioned guide did suggest to use it "If you plan on using a DNSBL" (which we do not use).

Configure SASL authentication
=============================

The SMTP AUTH service requires SASL authentication to be available.

Simple Authentication and Security Layer (SASL) is a framework for authentication and data security in Internet protocols, see
`Simple_Authentication_and_Security_Layer <http://en.wikipedia.org/wiki/Simple_Authentication_and_Security_Layer>`_.

Configure the SASL authentication daemon to run when the server boots, then start it::

  chkconfig saslauthd on
  service saslauthd restart 

You will get the following error messages in ``/var/log/messages``::

  (date) (host) sendmail[13326]: unable to open Berkeley db /etc/sasldb2: Bad file descriptor

A fix for this problem is in this `Fedora forum article <http://forums.fedoraforum.org/archive/index.php/t-36607.html>`_.
Create an "empty" ``/etc/sasldb2`` file by::

  # saslpasswd2 -c dummy
  Password: ****
  Again (for verification): ****
  # saslpasswd2 -d dummy
  # ls -l /etc/sasldb2
  -rw-r-----  1 root root 12288 Jan  2 17:14 /etc/sasldb2
