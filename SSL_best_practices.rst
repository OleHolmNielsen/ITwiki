.. _SSL_best_practices:

=============================
Web server SSL best practices
=============================

.. contents::

Introduction
============

Configuring web servers to use TLS_ (SSL_) securely is a fairly difficult problem given the currently known security holes in old encryption methods and the plethora of encryption ciphers available.
This page collects some configuration information for Apache_ web servers in particular, however, some links contain information about other web servers as well.

.. _SSLv2: http://en.wikipedia.org/wiki/Transport_Layer_Security#SSL_1.0.2C_2.0_and_3.0
.. _SSLv3: http://en.wikipedia.org/wiki/Transport_Layer_Security#SSL_1.0.2C_2.0_and_3.0
.. _Apache: http://httpd.apache.org/

Transport Layer Security
========================

*Transport Layer Security* (TLS_) and its predecessor, *Secure Sockets Layer* (SSL_), are cryptographic protocols designed to provide communication security over the Internet.

In the most secure web servers, only the latest TLS_1.2_ should be used.
However, for compatibility with old web clients (*Internet Explorer* on Windows XP and Vista, for example) the older TLS_1.1_ or even TLS_1.0_ may have to be allowed.

SSLv2 and SSLv3 MUST NOT be used
--------------------------------

The obsolete protocol SSLv2_ **MUST NOT be used**, see:

* IETF: Official deprecation of SSLv2_: `Prohibiting Secure Sockets Layer (SSL) Version 2.0 <http://tools.ietf.org/html/rfc6176>`_ (RFC6176).

.. _TLS: http://en.wikipedia.org/wiki/Transport_Layer_Security
.. _SSL: http://en.wikipedia.org/wiki/Transport_Layer_Security
.. _TLS_1.0: http://en.wikipedia.org/wiki/Transport_Layer_Security#TLS_1.0
.. _TLS_1.1: http://en.wikipedia.org/wiki/Transport_Layer_Security#TLS_1.1
.. _TLS_1.2: http://en.wikipedia.org/wiki/Transport_Layer_Security#TLS_1.2

The insecure protocol SSLv3_ **MUST NOT be used**, see:

* IETF: `Deprecating Secure Sockets Layer Version 3.0 <https://tools.ietf.org/rfc/rfc7568.txt>`_ (RFC7568) as of June 2015.

See also information about the so-called *POODLE Attack*:

* US-CERT Alert `TA14-290A: SSL 3.0 Protocol Vulnerability and POODLE Attack <https://www.us-cert.gov/ncas/alerts/TA14-290A>`_.
* Microsoft: `Vulnerability in SSL 3.0 Could Allow Information Disclosure <https://technet.microsoft.com/en-us/library/security/3009008.aspx>`_.
* Google: `This POODLE Bites: Exploiting The SSL 3.0 Fallback <https://www.openssl.org/~bodo/ssl-poodle.pdf>`_.
* Qualys: https://community.qualys.com/blogs/securitylabs/2014/10/15/ssl-3-is-dead-killed-by-the-poodle-attack.

There are some good discussions about configuring SSL:

* Ubuntu Linux: `How do I patch/workaround SSLv3 POODLE vulnerability (CVE­-2014­-3566)? <http://askubuntu.com/questions/537196/how-do-i-patch-workaround-sslv3-poodle-vulnerability-cve-2014-3566>`_.

SSL Cipher Suite configuration
------------------------------

The SSLCipherSuite_ (*Cipher Suite available for negotiation in SSL handshake*) configuration is really complicated.
Very important recommendations for a number of different web servers are in:

* Server_Side_TLS_
* tls-ssl-cipher-hardening_

.. _Server_Side_TLS: https://wiki.mozilla.org/Security/Server_Side_TLS
.. _tls-ssl-cipher-hardening: http://www.acunetix.com/blog/articles/tls-ssl-cipher-hardening/

In fact, one may generate an appropriate SSL_ configuration (including SSLCipherSuite_ for Apache_) in the page:

* https://mozilla.github.io/server-side-tls/ssl-config-generator/

.. _SSLCipherSuite: http://httpd.apache.org/docs/2.2/mod/mod_ssl.html#sslciphersuite

Configuring SSL and TLS in browsers
-----------------------------------

SSL can be disabled in browsers too.
Some interesting pages are:

* `Disabling SSLv3 Support in Browsers <https://zmap.io/sslv3/browsers.html>`_.
* `Microsoft security advisory: Vulnerability in SSL 3.0 could allow information disclosure <https://support2.microsoft.com/kb/3009008>`_.

Apache configuration
====================

Linux configuration files
-------------------------

The RHEL_/CentOS_ default Apache_ config files are in ``/etc/httpd/conf.d/``.
Apache_ loads config files in alphanumeric order, so file names starting with digits will be read first.

.. _RHEL: http://www.redhat.com/en/technologies/linux-platforms/enterprise-linux
.. _CentOS: http://www.centos.org

Apache ssl.conf file
--------------------

The ``ssl.conf`` configuration file should (probably) be renamed as ``02ssl.conf`` so that Apache_ reads it before other config files.

Configure the SSL certificates files in the (renamed) ``02ssl.conf`` file, **and in all subsequent virtual server .conf files** for each server instance, as::

    SSLCertificateFile      /path/to/signed_certificate
    SSLCertificateChainFile /path/to/intermediate_certificate
    SSLCertificateKeyFile   /path/to/private/key
    SSLCACertificateFile    /path/to/all_ca_certs

Now make these Apache_ global configurations in ``02ssl.conf``::

    SSLEngine on
    # intermediate security configuration, disable obsolete SSLv2 and SSLv3
    SSLProtocol             all -SSLv2 -SSLv3
    SSLCipherSuite          <paste ciphersuite from links in above section>
    SSLHonorCipherOrder     on

Apache_ v2.2 documentation:

* SSLEngine_ toggles the usage of the SSL/TLS Protocol Engine.
* SSLProtocol_  control the SSL protocol flavors mod_ssl should use when establishing its server environment.
* SSLHonorCipherOrder_ server's cipher preference order in stead of client's order.

.. _SSLEngine: http://httpd.apache.org/docs/2.2/mod/mod_ssl.html#sslengine
.. _SSLProtocol: http://httpd.apache.org/docs/2.2/mod/mod_ssl.html#sslprotocol
.. _SSLHonorCipherOrder: http://httpd.apache.org/docs/2.2/mod/mod_ssl.html#sslhonorcipherorder

It is necessary to disable TLS 1.0 SSLCompression_ to avoid CRIME_ attacks, and in Apache_ 2.2.24 and above one must configure::

  SSLCompression off

.. _SSLCompression: http://httpd.apache.org/docs/2.2/mod/mod_ssl.html#sslcompression
.. _CRIME: http://www.acunetix.com/vulnerabilities/vulnerability/CRIME_SSL_TLS_attack/

Testing SSL security
====================

It is important to verify the security, as well as the web client compatibility, of your SSL based web server.
This is not a simple matter.

There are SSL testing tools available on the Internet:

* testssl.sh_: Testing TLS/SSL encryption

* SSL Labs (Qualys) at https://www.ssllabs.com/ssltest/ 

* GlobalSign has a modified interface of SSL Labs that is interesting as well: https://sslcheck.globalsign.com/


.. _testssl.sh: https://testssl.sh/

In test results, make sure that SSLv2_ and SSLv3_ are shown as **disabled**.
You should also check the table of client compatibility in order to ensure that no important clients will be broken with this server.

Testing of SSL version
----------------------

On a Linux computer you can test the SSLv2_ or SSLv3_ protocol on a given web server, for example::

  openssl s_client -connect myserver.example.com:443 -ssl3

If SSLv3_ is correctly disabled you should get a handshake error::

  139743822751616:error:14094410:SSL routines:SSL3_READ_BYTES:sslv3 alert handshake failure:s3_pkt.c:1257:SSL alert number 40
  139743822751616:error:1409E0E5:SSL routines:SSL3_WRITE_BYTES:ssl handshake failure:s3_pkt.c:596:

Otherwise the command should print the server certificate information.
