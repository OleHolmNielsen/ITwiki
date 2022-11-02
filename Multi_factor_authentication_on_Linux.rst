.. _Multi_factor_authentication_on_Linux:

====================================================
Multi Factor Authentication (MFA) on Linux computers
====================================================

.. Contents:: 

Secure authentication of users of Linux computers should require additional security beyond the user password.
Here the use of *Multi factor authentication* (MFA_) on Linux computers is described.

Typically, MFA_ is used with SSH logins and other services.
Sometimes the term *Two-factor authentication* (2FA_) is used, but this is emcompassed by MFA_.

This page describes alternative MFA_ approaches using one-time passcodes or a Radius_ server.

MFA security issues
===================

If you are interested in the security issues related to the use of MFA_, here is a list of interesting articles:

* Bruce Schneier blog `Bypassing Two-Factor Authentication <https://www.schneier.com/blog/archives/2022/04/bypassing-two-factor-authentication.html>`_.
* `Lapsus$ and SolarWinds hackers both use the same old trick to bypass MFA <https://arstechnica.com/information-technology/2022/03/lapsus-and-solar-winds-hackers-both-use-the-same-old-trick-to-bypass-mfa/>`_.
* `Before You Turn On Two-Factor Authentication <https://stuartschechter.medium.com/before-you-turn-on-two-factor-authentication-27148cc5b9a1>`_.
* `Why Is the Majority of Our MFA So Phishable? <https://www.linkedin.com/pulse/why-majority-our-mfa-so-phishable-roger-grimes>`_
* `Risk Assessment: Multi-Factor Authentication (MFA) Security <https://www.akamai.com/resources/white-paper/risk-assessment-multi-factor-authentication-mfa-security>`_.

.. _MFA: https://en.wikipedia.org/wiki/Multi-factor_authentication
.. _2FA: https://en.wikipedia.org/wiki/Help:Two-factor_authentication

Google Authenticator end-user instructions
==========================================

With MFA_ a 6-digit code, which is your Time-based *One-Time Password* (OTP_) which must be used with every MFA_ login, is displayed by a smartphone app.

The following guide is for end users with a need to use MFA_ to connect to an SSH_ login-server which requires MFA_ authentication:

* Install the **Google Authenticator app**, the most well-known TOTP_ mobile app available via *Google Play* or Apple *App store* on mobile phones.

  In addition, the **Microsoft Authenticator app** works as well with the QR-code_ generated here.

* Run the google-authenticator_ command to create a new secret key to be stored in the user's ``$HOME/.ssh/`` directory::

    $ google-authenticator --secret=$HOME/.ssh/google_authenticator

  Answer **y** (yes) to all questions to use the recommended default settings.

* The google-authenticator_ command should display a QR-code_ (a black-white pattern) in the terminal window, similar to this test QR-code_:

  |qrtest|.

.. |qrtest| image:: attachments/qrtest.png

* Open the **Google Authenticator app** or **Microsoft Authenticator app** on your smartphone and press **+** to add a new account.

  Click **Scan a QR-code** and scan the QR-code_ which is displayed in your terminal window.
  The new account should appear on the list of accounts.

  A 6-digit code, which is your *One-Time Password* (OTP_) which must be used with every MFA_ login, is displayed next to the account.

* Important advice about the user's secret file ``$HOME/.ssh/google_authenticator`` in order to ensure your account's privacy and security:

  - It **must** be kept **absolutely safe**!
  - It **must not** be shared with other people.
  - It **must not** be copied to other computers.
  - It **must not** be backed up to other computers, such as cloud services like *Dropbox*.

* The *emergency scratch codes* (similar to `Google backup codes <https://support.google.com/accounts/answer/1187538>`_) are also in the secret file.
  You can print the codes on a piece of paper.

See also the google-authenticator_ manual page::

  $ man pam_google_authenticator

.. _QR-code: https://en.wikipedia.org/wiki/QR_code
.. _google-authenticator: https://github.com/google/google-authenticator-libpam/blob/master/man/google-authenticator.1.md

Using MFA with an SSH login server
----------------------------------

An SSH server with MFA_ enabled will both ask for the user's password, and subsequently require the 6-digit **Verification code** from the *Google Authenticator app*::

  $ ssh <username>@<SSH-server-name>
  Password: 
  Verification code: 


Redisplay of QR codes
---------------------

To redisplay the QR-code_ of a previously generated key: 

* https://stackoverflow.com/questions/34520928/how-to-generate-a-qr-code-for-google-authenticator-that-correctly-shows-issuer-d

Users can use the ``qrencode`` command to generate ASCII output QR-code_ with::

  $ qrencode -o- -t ANSI256 -d 300 -s 10 "otpauth://totp/$USER@`hostname`?secret=`head -1 $HOME/.ssh/google_authenticator`"

It may be convenient to generate also a protected image file ``$HOME/.ssh/google_authenticator.png`` containing the QR-code_::

  $ qrencode -o $HOME/.ssh/google_authenticator.png -d 300 -s 10 "otpauth://totp/$USER@`hostname`?secret=`head -1 $HOME/.ssh/google_authenticator`"
  $ chmod 0400 $HOME/.ssh/google_authenticator.png

If the mentioned Linux commands are not available on your system, please contact your system administrator and refer to the present page for information.


System administrator guide to the Google Authenticator PAM module
=================================================================

The following sections are for **Linux system administrators only**.
End users should skip these sections.

Security considerations of TOTP passcodes
-----------------------------------------

Users' secret file ``$HOME/.ssh/google_authenticator`` may be compromised by careless users.
The alternative described below keeps all secret files in a location which can only be read by the root user.

**Beware:** If the users' secret file are somehow compromised (for example, by obtaining root access to the system), 
then attackers can use the secret files to regenerate the users' MFA_ QR-code_ giving access to two-factor authentication,
which therefore becomes useless.

Google Authenticator PAM module
-------------------------------

Google provides an example Linux PAM_module_ demonstrating two-factor authentication for logging into servers via SSH_, OpenVPN_, etc.:

* google-authenticator-libpam_

.. _PAM_module: https://en.wikipedia.org/wiki/Pluggable_authentication_module
.. _google-authenticator-libpam: https://github.com/google/google-authenticator-libpam
.. _SSH: https://en.wikipedia.org/wiki/Secure_Shell_Protocol
.. _OpenVPN: https://en.wikipedia.org/wiki/OpenVPN
.. _Linux_PAM: https://en.wikipedia.org/wiki/Linux_PAM

Google_Authenticator_ provides a two-step authentication procedure using one-time passcodes (OTP_). 
The OTP_ generator application is available for iOS, Android and Blackberry. 
Similar to S/KEY Authentication the authentication mechanism integrates into the Linux_PAM_ system. 

Time-based One-time Password (TOTP_) is a computer algorithm that generates a one-time password (OTP_) which uses the current time as a source of uniqueness. 
TOTP_ is defined in RFC6238_.

Documentation:

* `Setting up multi-factor authentication on Linux systems <https://www.redhat.com/sysadmin/mfa-linux>`_ (Red Hat).
* `Set Up SSH Two-Factor Authentication (2FA) on CentOS/RHEL Server <https://www.linuxbabe.com/redhat/ssh-two-factor-authentication-centos-rhel>`_ 
* `Google Authenticator instructions <https://wiki.archlinux.org/title/Google_Authenticator>`_ (archlinux).

Summary:

* Install packages from EPEL_ and Base::

    dnf install google-authenticator qrencode qrencode-libs

.. _EPEL: https://fedoraproject.org/wiki/EPEL

Secret file in a non-standard location
--------------------------------------

**Optionally** you may decide to store the secret file in a non-standard location, for example::

  auth required pam_google_authenticator.so secret=/var/authenticator/${USER}/.google_authenticator

Then you also have to tell your users to manually move their ``.google_authenticator`` file to this location.

The folder ``/var/authenticator/${USER}`` would have to be created and protected, for example for user xxx::

  mkdir -p /var/authenticator/xxx
  chmod 0700 /var/authenticator/xxx
  chmod 0600 /var/authenticator/xxx/.google_authenticator

The folder ``/var/authenticator/`` would have to be replicated on all servers where users can login.

See also the description of Storage_location_.

.. _Storage_location: https://wiki.archlinux.org/title/Google_Authenticator#Storage_location

Secret files in a root-owned location
-------------------------------------

See the description of Storage_location_ and change the secret file location path for PAM in ``/etc/pam.d/sshd``::

  auth required pam_google_authenticator.so user=root secret=/var/authenticator/${USER}/google_authenticator

The **user=root** is used to force PAM to search the file using root user.

All users' secret file must be stored in this location::

  /var/authenticator/${USER}/google_authenticator

Each site will need to have a method for creating user secret files in this location, and removing them from user $HOME directories for security reasons!
If multiple servers are used, the ``/var/authenticator`` folder must be replicated from the same source using, for example, rsync_.

All user secret files must be readable only by the root user::

  chown -R root.root /var/authenticator
  chmod 0700 /var/authenticator/*
  chmod 0400 /var/authenticator/*/*

.. _rsync: https://en.wikipedia.org/wiki/Rsync

sshd configuration for Time-based One-time Password
---------------------------------------------------

**NOTE:** Make sure you have an open terminal window to the server, since you can easily lock yourself out!

In ``/etc/ssh/sshd_config`` configure the use of password + one-time code::

  ChallengeResponseAuthentication yes

If you do not need any user to authenticate solely with a password, configure this line in ``/etc/ssh/sshd_config``::

  PasswordAuthentication no

You should configure that the **root** user can only login with a public key::

  PermitRootLogin without-password

Check that ``sshd_config`` is configured with::

  UsePAM yes

Define **one** of the following AuthenticationMethods:

1. To enforce the use of 1) public key and 2) password + one-time code for all users, including the **root** user::

     AuthenticationMethods publickey,keyboard-interactive

2. Alternatively, first permit login with public key, and if that fails, the next method is password + one-time code::

     AuthenticationMethods publickey keyboard-interactive

Finally, restart the *sshd* service::

  systemctl restart sshd

PAM configuration for google-authenticator
------------------------------------------

The Linux_PAM_ configuration file syntax is described in http://www.linux-pam.org/Linux-PAM-html/sag-configuration-file.html

Edit the file ``/etc/pam.d/sshd`` and find near the top of the file this line::

  auth       include      postlogin

Insert after that line the following lines::

  auth [success=done default=ignore] pam_succeed_if.so user = root
  auth [success=ok default=ignore] pam_access.so
  auth required pam_google_authenticator.so secret=${HOME}/.ssh/google_authenticator

The rules in ``/etc/pam.d/sshd`` are processed one line at a time from the top and down, see the ``man pam.conf`` manual page.

Comments:

1. The ``pam_succeed_if.so`` skips the following checks for the **root** user, which can then use public key only without a password.

   This configuration goes together with the *sshd* configurations ``PermitRootLogin`` and ``AuthenticationMethods`` defined below.

   See the ``man pam_succeed_if`` manual page.

2. The ``pam_access.so`` line allows special rules for users and networks.
   The default configuration file is ``/etc/security/access.conf`` described below,
   but a non-default file may be specified with ``accessfile=<file>``.

   See the ``man pam_access`` manual page.

3. With ``pam_google_authenticator.so`` you might add **nullok** in case you wish to skip check for users without a ``${HOME}/.ssh/google_authenticator`` file::

     auth required pam_google_authenticator.so nullok secret=${HOME}/.ssh/google_authenticator

   See the ``man pam_google_authenticator`` manual page.

4. Users may (by accident or by ignorance) give others permission to read the secret file ``${HOME}/.ssh/google_authenticator``.
   Fortunately, the ``pam_google_authenticator`` catches such user errors and should log them into ``/var/log/secure`` similar to this::

     sshd(pam_google_authenticator)[408484]: Secret file "/home/XXX/.ssh/google_authenticator" permissions (0644) are more permissive than 0600
     sshd(pam_google_authenticator)[408484]: No secret configured for user XXX, asking for code anyway.


**Notice:** When using the secret= option, you might want to also set the user= option. 
The latter forces the PAM module to switch to a dedicated hard-coded user id prior to doing any file operations. 
When using the user= option, you must not include "~" or "${HOME}" in the filename.
The user= option can also be useful if you want to authenticate users who do not have traditional UNIX accounts on your system.

System administrator guide to the Radius PAM module
===================================================

The following sections are for **Linux system administrators only**.
End users should skip these sections.
DTU users should read this page on `Inside <https://www.inside.dtu.dk/da/medarbejder/it-og-telefoni/it-support-og-kontakt/guides/mfa>`_.

A convenient MFA solution for SSH is to use an existing Radius_ server in your organization (setting up such a server is beyond the scope of this document).
For Linux servers there is a `FreeRADIUS <https://freeradius.org/>`_ server.

Security considerations of RADIUS authentication
------------------------------------------------

The Radius_ article states that passwords in the RADIUS protocol are protected by the 
`cryptographically broken <https://www.kb.cert.org/vuls/id/836068>`_ MD5_ encryption plus the *shared secret*::

  Passwords are hidden by taking the MD5 hash of the packet and a shared secret, and then XORing that hash with the password. 

Notice the RADIUS protocol's use of the **user clear-text password**.
See `An Analysis of the RADIUS Authentication Protocol <https://www.untruth.org/~josh/security/radius/radius-auth.html>`_ for details of the algorithm,
and for a discussion of security issues with the Radius_ protocol.

**Beware:** If the server's RADIUS shared secret is somehow compromised (for example, by obtaining root access to the system), then all user clear-text passwords will be readable by attackers,
whenever the user has been authenticating with RADIUS.

There are possible attacks on the Radius_ network protocol, see
`Using John to crack RADIUS shared secrets <https://openwall.info/wiki/john/Using-john-to-crack-RADIUS-shared-secrets>`_.

In order for this attack to work, you will need to either be able to try authentications with a specific login and password and sniff the Access-Request packets,
or sniff Access-Request and corresponding Access-Reply packets.

.. _Radius: https://en.wikipedia.org/wiki/RADIUS
.. _MD5: https://en.wikipedia.org/wiki/MD5

Firewall setup
--------------

Your network firewalls between the Radius_ client and your Radius_ server must be open for two-way Radius_ traffic (UDP, standard port 1812). 

Linux PAM Radius module
-----------------------

There are some more-or-less useful guides to using Radius_ with PAM on a Linux system, but nothing authoritative and pedagogical:

* `SSH Authentication using PAM and RADIUS IN Linux <https://99linux.wordpress.com/2013/05/03/ssh-authentication-using-pam-and-radius-in-linux/>`_
* `PAM with a Mideye Server <https://www.mideye.com/support/administrators/documentation/integration/pam-linux/>`_
* `McAfee: Install and configure a pam-radius module  <https://docs.mcafee.com/bundle/web-gateway-9.0.x-product-guide/page/GUID-53DBBFA6-A63F-42CB-BE16-53D9859EBE00.html>`_

Read more about the pam_radius_ module including `usage information <https://github.com/FreeRADIUS/pam_radius/blob/master/USAGE>`_.

.. _pam_radius: https://github.com/FreeRADIUS/pam_radius

On CentOS/RHEL 7/8 or Ubuntu Linux install this package::

  dnf install pam_radius   # EL8
  yum install pam_radius   # EL7
  apt install libpam-radius-auth  # Ubuntu

Usage information is in the RPM file ``/usr/share/doc/pam_radius/USAGE``.

The PAM Radius_ configuration file is::

  /etc/pam_radius.conf       # RHEL/CentOS/EL7/EL8
  /etc/pam_radius_auth.conf  # Ubuntu

containing lines about your Radius_ servers::

  # server[:port]	shared_secret      timeout (s)
  127.0.0.1	secret             1
  other-server    other-secret       3

Your organization's Radius service
----------------------------------

You need to obtain **your organization's** Radius_ server IP-address and a client-specific **shared-secret** string.

Please contact your Radius_ service's system administrators in order to obtain the required information.

The only line in ``/etc/pam_radius.conf`` (Ubuntu: ``/etc/pam_radius_auth.conf``) should be the one defining your site's Radius_ information::

  <radius-server-IP>:1812  <shared-secret> 30

with a 30 second timeout (or longer) for Radius_ authentication, since this involves a human response.
The standard UDP port is 1812, so the *:1812* may be omitted.
If you have multiple Radius_ servers, you can have one line for each such server.

An example ``/etc/pam_radius.conf`` file could contain a single line like::

  1.2.3.4 s3cr3t 30

Please note that the ``/etc/pam_radius.conf`` file must be protected by permissions 0600,
that is readable by root, and NO ONE else::

  chmod 0600 /etc/pam_radius.conf

Testing your organization's Radius service
..........................................

First you need to ensure that your Radius_ server is responding to requests from your server (which is a Radius_ client).
Any problems encountered could be due to 1) the Radius_ server itself, or 2) more likely that a firewall somewhere in your network is blocking the UDP port 1812 traffic.

The Radius_ client sends UDP packets to the Radius_ server on one of the ports 1645, 1646, 1812, 1813.

To verify the connectivity to the Radius_ server, use the radclient_ tool.
Install this package::

  dnf install freeradius-utils   # EL8 uses dnf

An example command querying the Radius_ server (which uses the shared secret *s3cr3t*) is for some existing user (here: user *test* with password *mypass*)::

  echo "User-Name=test,User-Password=mypass" | radclient <radius-server-IP>:1812 auth s3cr3t

See the `radclient manual page <https://linux.die.net/man/1/radclient>`_.

.. _radclient: https://wiki.freeradius.org/config/Radclient

sshd configuration for Radius authentication
--------------------------------------------

**NOTE:** Make sure you have an open terminal window to the server, since you can easily lock yourself out!

In ``/etc/ssh/sshd_config`` configure the use of password + Radius_ authentication::

  ChallengeResponseAuthentication yes

If you do not need any user to authenticate solely with a password, configure this line in ``/etc/ssh/sshd_config``::

  PasswordAuthentication no

You should configure that the **root** user can only login with a public key::

  PermitRootLogin without-password

Check that ``sshd_config`` is configured with::

  UsePAM yes

Restart the *sshd* service.

PAM Radius configuration
------------------------

The Linux_PAM_ configuration file syntax is described in http://www.linux-pam.org/Linux-PAM-html/sag-configuration-file.html

The rules in ``/etc/pam.d/sshd`` are processed one line at a time from the top and down, see the ``man pam.conf`` manual page.

Edit the file ``/etc/pam.d/sshd`` to contain the following lines at the top of the file::

  #%PAM-1.0
  # Allow root login first
  auth sufficient pam_succeed_if.so user = root
  # Access configuration file (for subnets etc.) is /etc/security/access.conf
  auth optional pam_access.so
  # The RADIUS pam_radius authentication module ("debug" is only used when troubleshooting)
  auth sufficient pam_radius_auth.so debug

After this follows the usual lines in the system's default ``/etc/pam.d/sshd`` file.

The ``auth sufficient`` actually makes the authorization proceed to the next method in the file, 
so if your Radius_ server fails the login, a local password login is attempted next.
This may not be what you want for a strict security.
In stead you can configure login failure if the Radius_ authentication failed by using in stead these lines::

  #%PAM-1.0
  # Allow root login first
  auth sufficient pam_succeed_if.so user = root
  # Access configuration file (for subnets etc.) is /etc/security/access.conf
  auth optional pam_access.so
  # The RADIUS pam_radius authentication module ("debug" is only used when troubleshooting)
  auth [success=done default=die] pam_radius_auth.so debug 

The ``pam_access.so`` line allows special rules for users and networks.
The default configuration file is ``/etc/security/access.conf`` described below,
but a non-default file may be specified with ``accessfile=<file>``.

Note that each of the four keywords: **required**, **requisite**, **sufficient**, and **optional** have an equivalent expression in terms of the **[...]** syntax as follows:

* required:
    [success=ok new_authtok_reqd=ok ignore=ignore default=bad]
* requisite:
    [success=ok new_authtok_reqd=ok ignore=ignore default=die]
* sufficient:
    [success=done new_authtok_reqd=done default=ignore]
* optional:
    [success=ok new_authtok_reqd=ok default=ignore]

Testing the SSH server with Radius authentication
-------------------------------------------------

With the above configuration, and having restarted the *sshd* service, test logins to the SSH server:

1. Try to login as root with a previously configured SSH public-key::

     root@other-server$ ssh root@ssh-server

   The SSH public-key should allow root login here.

2. Try to login as a normal, external user::

     user@external-host$ ssh user@ssh-server
     Password: *****

   When the user's correct password has been entered, the user will be authenticated by your Radius_ server.
   The Radius_ server may use different MFA methods such as SMS codes or smartphone authenticator popups.
   If all is well, the user will be logged in through the SSH session.

Azure Active Directory authentication
=====================================

Azure_ provides a `Remote Desktop Gateway and Azure Multi-Factor Authentication Server using RADIUS <https://docs.microsoft.com/en-us/azure/active-directory/authentication/howto-mfaserver-nps-rdg>`_,
but there is no offering of Linux PAM integration.

The pam_aad_ project aims to provide Azure Active Directory authentication for Linux, but this project seems not to be developed actively any more.

.. _Azure: https://azure.microsoft.com/en-us/
.. _pam_aad: https://github.com/CyberNinjas/pam_aad


YubiKey hardware authentication device
======================================

The YubiKey_ is a hardware authentication device manufactured by Yubico to protect access to computers, networks, and online services that supports one-time passwords (OTP), public-key cryptography, and authentication, and the Universal 2nd Factor (U2F) and FIDO2 protocols developed by the FIDO Alliance. 
It allows users to securely log into their accounts by emitting one-time passwords or using a FIDO-based public/private key pair generated by the device. 
YubiKey_ also allows for storing static passwords for use at sites that do not support one-time passwords.

There is a list of YubiKey_ `Current Products <https://www.yubico.com/products/identifying-your-yubikey/>`_.
In Denmark you can buy devices from `this vendor <https://www.dustinhome.dk/sog/Yubikey>`_, among others.

There is a guide to use two factor authentication for YubiKey_and_SSH_.
See also the page 
`SSH Public key+MFA with Yubikey on Centos 8/Ubuntu 20.4 LTS <https://ismailyenigul.medium.com/ssh-public-key-mfa-with-yubikey-on-centos-8-ubuntu-20-4-lts-8fb368133690>`_.

Steps to enable YubiKey_ on RHEL Linux and clones:

1. Enable the EPEL_ repository as instructed in that page.

2. Install this package (including prerequisites)::

     yum/dnf install pam_yubico

.. _YubiKey: https://en.wikipedia.org/wiki/YubiKey
.. _YubiKey_and_SSH: https://developers.yubico.com/yubico-pam/YubiKey_and_SSH_via_PAM.html

Configuring YubiKey on the system
---------------------------------

Read YubiKey_and_SSH_.
In Administrative level, system administrators hold right to configure the user and YubiKey token ID mapping. 
Administrators can achieve this by creating a new file that contains information about the username and the corresponding IDs of YubiKey(s) assigned.

Create a YubiKey_ key mapping file, for example ``/etc/yubikeyid``, with contents in this format::

  <first user name>:<YubiKey token ID1>
  <second user name>:<YubiKey token ID2>:<YubiKey token ID3>:…

Append the following line to the beginning of the ``/etc/pam.d/sshd`` file::

  auth required pam_yubico.so id=16 debug authfile=/etc/yubikeyid



Require MFA for external networks only
======================================

Sometimes we just want to enable the MFA_ capability only when we connect from **external networks** to our local network. 

To achieve this, append to ``/etc/security/access.conf`` the specific networks from where you want to be able to bypass the MFA_, for example::

  # Logins from local IP range (192.168.0.0/24) and crond
  +:root:192.168.0.0/24
  +:root:cron
  -:root:ALL
  +:ALL:192.168.0.0/24
  # Hosts with no "." in the name
  # +:ALL:LOCAL

The lines with ``root`` will disallow root logins from other than 192.168.0.0/24.

**NOTE:** 

* There **should not be any spaces** around the ":" separators, see ``man access.conf``.

* The default configuration file for ``pam_access.so`` (in ``/etc/pam.d/sshd``) is ``/etc/security/access.conf``, 
  but a non-default file may be specified with ``accessfile=<file>``.

.. _Google_Authenticator: https://github.com/google/google-authenticator
.. _OTP: https://en.wikipedia.org/wiki/One-time_password
.. _TOTP: https://en.wikipedia.org/wiki/Time-based_One-Time_Password
.. _RFC6238: https://datatracker.ietf.org/doc/html/rfc6238
