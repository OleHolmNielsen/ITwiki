.. _Sendmail_configuration:

======================
Sendmail configuration
======================

.. Contents::

Sendmail_ is a general purpose internetwork email routing facility that supports many kinds of mail-transfer and delivery methods, including the *Simple Mail Transfer Protocol* (SMTP_) used for email transport over the Internet.

The current Open Source Sendmail_ version is 8.16.1, see https://www.sendmail.com/sm/open_source/download/.

.. _SMTP: https://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol
.. _Sendmail: http://www.sendmail.org
.. _Dovecot: http://www.dovecot.org/

Sendmail_ versions in some Linuxes are:

* RHEL7/CentOS7: version 8.14.7.
* RHEL8/CentOS8: version 8.15.2.
* Fedora 33: version 8.16.1.

This page refers mainly to the RHEL/CentOS installation of Sendmail_.

Documentation
=============

Some Sendmail_ documentation is available on the Sendmail_ homepage and in `several books <http://www.sendmail.org/books.html>`_.

Configuration files
===================

All configuration files of Sendmail_ is in the ``/etc/mail`` directory.
The relevant files to configure are:

* ``Makefile``: Manages most of the configuration files.

* ``sendmail.mc``: Contains the most crucial server configurations, see ``/usr/share/sendmail-cf/README``.

* ``local-host-names``: List of hostnames that alias to this server.

* ``access``: Reject/accept list.

* ``virtusertable``: Virtual users, such as user@nano.dtu.dk and invalid addresses.

Whenever a file has been changed, do a ``make`` in this directory.
If ``sendmail.mc`` has been changed, you also need to restart the ``sendmail`` service.

Sendmail parameters
===================

A few runtime parameters are defined in the file ``/etc/sysconfig/sendmail``::

  DAEMON=yes
  QUEUE=1h
  SMQUEUE=5m

SMTP AUTH and STARTTLS
======================

SMTP_ Authentication, often abbreviated SMTP_AUTH_, is an extension of the *Simple Mail Transfer Protocol* (SMTP_) whereby an SMTP_ client 
may log in using an authentication mechanism chosen among those supported by the SMTP_ server. 
The authentication extension is mandatory for mail submission servers.

.. _SMTP_AUTH: https://en.wikipedia.org/wiki/SMTP_Authentication

You can read about SMTP_AUTH_in_sendmail_ and Sendmail_STARTTLS_.
STARTTLS_ is an extension to plain text communication protocols, which offers a way to upgrade a plain text connection to an encrypted (TLS_ or SSL) connection 
instead of using a separate port for encrypted communication.
Usually port 587 is used for SMTP_AUTH_ mail submission with STARTTLS_, although port 465 with SSL is sometimes used for legacy mail clients.

.. _SMTP_AUTH_in_sendmail: http://www.sendmail.org/~ca/email/auth.html
.. _Sendmail_STARTTLS: https://www.sendmail.com/sm/open_source/docs/m4/starttls.html
.. _STARTTLS: https://en.wikipedia.org/wiki/STARTTLS
.. _TLS: https://en.wikipedia.org/wiki/Transport_Layer_Security

Sendmail TLS (SSL) configuration
--------------------------------

Configuration of TLS_ for use with Sendmail_STARTTLS_ should be improved beyond the defaults in Sendmail_.
Modern and secure SSL certificates should be used for proper security, see also :ref:`SSL_best_practices`.

Documentation:

* The Sendmail_ file ``/usr/share/sendmail-cf/README`` defining the ``sendmail.mc`` parameters.
* `Configuration of hidden Sendmail SSL/TLS connection options <http://www.michaelm.info/blog/?p=1256>`_
* `Perfect Forward Secrecy in Sendmail einrichten <http://sendmaid.org/22-perfect-forward-secrecy-in-sendmail-einrichten>`_.
* Guide_to_Deploying_Diffie-Hellman_for_TLS_

.. _Guide_to_Deploying_Diffie-Hellman_for_TLS: https://weakdh.org/sysadmin.html

Sendmail SSL/TLS connection options
-----------------------------------

From `Configuration of hidden Sendmail SSL/TLS connection options <http://www.michaelm.info/blog/?p=1256>`_:

* **CipherList**: This option configures the available cipher list for encrypted connections.
  Your cipher list can be tuned by using the ``openssl ciphers -v`` command.
  Stronger ciphers are obviously better. Excluding weak ciphers may mean that very old clients will be unable to connect.
  Note that with SSLv3 and TLS1.x the **client**, by default, will select its preferred cipher from the server’s list.

* **ServerSSLOptions**: This option configures the OpenSSL connection flags used for the SSL/TLS connections into Sendmail.
  By default Sendmail, and most other applications using the OpenSSL library, uses the SSL_OP_ALL composite flag for its connections.
  This option allows these flags to be altered.

  - The first option to consider using is SSL_OP_CIPHER_SERVER_PREFERENCE.
    This option causes the **server**, rather than the client, to choose the cipher based on its preference order.

  - The next option to consider is SSL_OP_DONT_INSERT_EMPTY_FRAGMENTS.
    This option disables a countermeasure against a SSLv3/TLSv1 protocol vulnerability.
    This flag disables the countermeasure and is set by default when SSL_OP_ALL is used.
    Thus, if one wishes to have the vulnerability countermeasure enabled, this flag needs to be disabled.

  - Depending on the clients and servers of your Sendmail instance you may wish to consider the use of SSL_OP_NO_SSLv2, SSL_OP_NO_SSLv3 and SSL_OP_NO_TLSv1.

  Note that the current version of Sendmail does not have support for OpenSSL’s SSL_OP_NO_TLS_v1_1 nor for SSL_OP_NO_TLSv1_2.
  These two could be quite useful and I have submitted a patch to Sendmail for these to be included.
  The value of this parameter is used to manipulate the bits passed to OpenSSL.

  Note that Sendmail starts with a value of SSL_OP_ALL and this option modifies that value – it does not reset it from scratch.
  You manipulate the value using [+]SSL_OP_XXX to **SET** the bits and using -SSL_OP_XXX to **CLEAR** the bits.
  Thus a value of +SSL_OP_ALL would have no effect (since those bits are already set. A value of -SSL_OP_ALL would result in no bits being set.
  A useful value might be ``+SSL_OP_NO_SSLv2 +SSL_OP_CIPHER_SERVER_PREFERENCE``.

* **ClientSSLOptions**: This option configures the OpenSSL connection flags used for the SSL/TLS connections initiated by Sendmail. The parameter’s value works the same as for ServerSSLOptions.


Diffie-Hellmann parameters
--------------------------

`Diffie–Hellman key exchange <https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange>`_ should be configured securely,
see Guide_to_Deploying_Diffie-Hellman_for_TLS_.

The Sendmail_ Diffie-Hellmann parameter file may be configured by::

  define(`confDH_PARAMETERS', `/etc/pki/tls/certs/dh2048.pem')dnl

To generate the DH_PARAMETERS file, see ``man dhparam``::

  openssl dhparam 2048 > /etc/pki/tls/certs/dh2048.pem

From Sendmail 8.14.8 the Diffie-Hellman Keys of length 2048 Bit are supported inside Sendmail_::

  define(`confDH_PARAMETERS', `2048')dnl

Sendmail cipher list
--------------------

From https://weakdh.org/sysadmin.html:

* In the LOCAL_CONFIG section of your ``/etc/mail/sendmail.mc`` configure this::

    LOCAL_CONFIG
    dnl # Certificates and keys must also have been configured
    O CipherList=ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:!DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA
    dnl # Disable SSLv2, SSLv3, TLSv1.0 (TLSv1.1 and TLSv1.2 should be supported)
    dnl # O ServerSSLOptions=+SSL_OP_NO_SSLv2 +SSL_OP_NO_SSLv3 +SSL_OP_NO_TLSv1 +SSL_OP_CIPHER_SERVER_PREFERENCE
    O ServerSSLOptions=+SSL_OP_NO_SSLv2 +SSL_OP_NO_SSLv3 +SSL_OP_CIPHER_SERVER_PREFERENCE
    dnl # Set options required when operating as client to remote servers
    dnl # O ClientSSLOptions=+SSL_OP_NO_SSLv2 +SSL_OP_NO_SSLv3 +SSL_OP_NO_TLSv1
    O ClientSSLOptions=+SSL_OP_NO_SSLv2 +SSL_OP_NO_SSLv3

Here we have disabled also *DES-CBC3-SHA* because it's insecure.

OPENSSL renegotiation Denial-Of-Service
---------------------------------------

The https://testssl.sh/ tool can be used to test for *Secure Client-Initiated Renegotiation* (CVE-2009-3555)::

  ./testssl.sh -R --starttls smtp mail-server:587

and will show a warning for Sendmail_::

  Secure Client-Initiated Renegotiation     VULNERABLE (NOT ok) , DoS threat

See `How to test for Secure Client-Initiated Renegotiation DOS Danger <https://community.qualys.com/message/21147>`_.

The OPENSSL parameters ``SSL_OP_LEGACY_SERVER_CONNECT`` and ``SSL_OP_ALLOW_UNSAFE_LEGACY_RENEGOTIATION`` controls the usage of the vulnerable Renegotiation.
The manual page ``man SSL_CTX_set_options`` (from the *openssl-devel* RPM) explains the SSL_OP_xxx parameters.

See also `The Small Print for OpenSSL legacy_renegotiation <http://www.exploresecurity.com/the-small-print-for-openssl-legacy_renegotiation/>`_.

Unfortunately, the parameters ``SSL_OP_LEGACY_SERVER_CONNECT`` and ``SSL_OP_ALLOW_UNSAFE_LEGACY_RENEGOTIATION`` are only accepted by Sendmail_ version 8.14.9 and later, see the source file ``sendmail/readcf.c``.

To configure the LOCAL section of ``sendmail.mc`` (Sendmail_ 8.14.9 or newer) to clear the SSL *legacy* flags::

  O ServerSSLOptions=+SSL_OP_NO_SSLv2 +SSL_OP_NO_SSLv3 +SSL_OP_CIPHER_SERVER_PREFERENCE -SSL_OP_LEGACY_SERVER_CONNECT -SSL_OP_ALLOW_UNSAFE_LEGACY_RENEGOTIATION

Testing the Sendmail TLS
========================

The https://testssl.sh/ tool can be used to test a *mail-server* port 587 (STARTTLS)::

  ./testssl.sh --starttls smtp mail-server:587

or port 465 (TLS/SSL) used for legacy mail clients::

  ./testssl.sh mail-server:465

To display all TLS (SSL) parameters of a server *mail-server* port 587::

  openssl s_client -starttls smtp -connect  mail-server:587 < /dev/null
