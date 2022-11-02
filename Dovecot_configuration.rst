.. _Dovecot_configuration:

=====================
Dovecot configuration
=====================

.. Contents::

Dovecot_ is an open-source IMAP and POP3 server for Linux/UNIX-like systems.

This page refers mainly to the RHEL/CentOS installation of Dovecot_, versions are:

* RHEL7/CentOS7: version 2.2.10.
* Fedora 22: version 2.2.18.

.. _Dovecot: http://www.dovecot.org/

Dovecot configuration
=====================

The Dovecot_ IMAP and POP3 mailbox service is configured by the files::

  /etc/dovecot/dovecot.conf
  /etc/dovecot/conf.d/*.conf

Documentation is in ``/usr/share/doc/dovecot*/`` and on the Dovecot_ homepage.

Userids
-------

By default Dovecot_ only permits user UIDs >500 to log in.
To change this default configure, for example::

  first_valid_uid = 1000

Dovecot and SSL certificates
----------------------------

Dovecot_ configuration of SSL is documented in http://wiki.dovecot.org/SSL.

The IMAPS service (IMAP over SSL) is configured in ``/etc/dovecot/conf.d/10-ssl.conf``.

The SSL certificates for are stored in ``/etc/pki/tls/`` subdirectories.

Some SSL certificates require the use of a **Certificate Authority** (CA) file.
This should be configured as::

  # File containing trusted SSL certificate authorities. Usually not needed.
  # The CAfile should contain the CA-certificate(s) followed by the matching
  # CRL(s). CRL checking is new in dovecot .rc1
  ssl_ca_file = /etc/pki/tls/certs/intermediate.crt

Dovecot and SSL protocols/ciphers
---------------------------------

For reason of security one should never use low-strength SSL-certificates.
This is configured as explained in http://wiki.dovecot.org/SSL/DovecotConfiguration by::

  # SSL ciphers to use
  ssl_cipher_list = ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:!DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA
  ssl_parameters_regenerate = 72h
  # The !TLSv1 disables TLSv1.0. Only TLS v1.1 and v1.2 are OK
  ssl_protocols = !SSLv2 !SSLv3 !TLSv1
  # Prefer the server's order of ciphers over client's
  # Only available on dovecot 2.2.6 and later::
  ssl_prefer_server_ciphers = yes
  # Only available on dovecot 2.2.7 and later::
  ssl_dh_parameters_length = 2048

Notice that we disable this CBC cipher, in contrast to advice in `Guide to Deploying Diffie-Hellman for TLS <https://weakdh.org/sysadmin.html>`_::

  !DES-CBC3-SHA

Testing dovecot SSL
-------------------

Check the Dovecot_ SSL configurations by::

  grep  ^ssl_ /etc/dovecot/conf.d/10-ssl.conf

From a client machine, test the Dovecot_ SSL server as explained in http://wiki1.dovecot.org/SSL/DovecotConfiguration (section *Testing*)::

  openssl s_client -connect servername:imaps -ssl2   # Should be rejected
  openssl s_client -connect servername:imaps -ssl3   # Should be rejected
  openssl s_client -connect servername:imaps -tls1   # Should be rejected
  openssl s_client -connect servername:imaps -tls1_1
  openssl s_client -connect servername:imaps -tls1_2

See *man s_client* for documentation.

From the output of this command you can put *Server certificate* into a file and display the server certificate by::

  openssl x509 -noout -text -in <certificate-file>

IMAP quotas
-----------

Dovecot_ from version 1.0 supports the usage of IMAP disk quotas, see http://wiki.dovecot.org/Quota.
Configuration of filesystem quotas is described in http://wiki.dovecot.org/Quota/FS.

The `Thunderbird <http://www.mozilla.com/en-US/thunderbird/>`_ mail client does support IMAP quotas
(right-click on an IMAP folder, select *Properties* and view the *Quota* tab).

Logging
-------

By default Dovecot_ logs every user connection, which causes excessive amounts of logging in the syslog.
To turn off this logging configure ``conf.d/10-logging.conf``::

  info_log_path = /dev/null

See http://wiki.dovecot.org/Logging about logging.
