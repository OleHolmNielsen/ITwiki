.. _OpenSSH_configuration:

======================================
OpenSSH configuration of an SSH server
======================================

.. Contents::

Secure Shell, or SSH_, is a cryptographic (encrypted) network protocol for initiating text-based shell sessions on remote machines in a secure way.

Due to the increased security issues in SSH_ remote login servers, we collect some information about OpenSSH_ configuration best practices.

For protecting your SSH_ server against attacks see the :ref:`Linux_firewall_configuration` page.

.. _SSH: https://en.wikipedia.org/wiki/Secure_Shell
.. _OpenSSH: http://www.openssh.com/

OpenSSH documentation
=====================

OpenSSH_ documentation:

* OpenSSH_ **FAQ**: http://www.openssh.com/faq.html

* OpenSSH_ sources for Linux/UNIX are found in http://www.openssh.com/portable.html.

* OpenSSH_ mailing lists are at https://lists.mindrot.org/mailman/listinfo

OS-specific documentation:

* RHEL 7: `9.2. Configuring OpenSSH <https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/s1-ssh-configuration.html>`_.

* RHEL 6: `Chapter 13. OpenSSH <https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Deployment_Guide/ch-OpenSSH.html>`_.

* CentOS: `Securing OpenSSH <http://wiki.centos.org/HowTos/Network/SecuringSSH>`_.

OpenSSH security issues
=======================

* Blog Secure_Secure_Shell_ and its corresponding Secure_Secure_Shell_Wiki_.

* `On OpenSSH and Logjam <https://jbeekman.nl/blog/2015/05/ssh-logjam/>`_.

* `Guide to Deploying Diffie-Hellman for TLS <https://weakdh.org/sysadmin.html>`_.

* A paper Applied_Crypto_Hardening_ (see section 2.2.1 on OpenSSH_ configuration) from https://bettercrypto.org/.

* Mozilla Wiki Security_Guidelines_OpenSSH_.

.. _Secure_Secure_Shell: https://stribika.github.io/2015/01/04/secure-secure-shell.html
.. _Secure_Secure_Shell_Wiki: https://github.com/stribika/stribika.github.io/wiki/Secure-Secure-Shell
.. _Applied_Crypto_Hardening: https://bettercrypto.org/static/applied-crypto-hardening.pdf
.. _Security_Guidelines_OpenSSH: https://wiki.mozilla.org/Security/Guidelines/OpenSSH

OpenSSH configuration
=====================

Please note that configuration settings may differ between minor versions of OpenSSH_.

SSH settings to be configured include:

* Cipher_ algorithms.
* HMAC_: Hash-based message authentication codes.
* KEX_: Key exchange.

See also `Steps to disable the diffie-hellman-group1-sha1 algorithm in SSH  <https://access.redhat.com/solutions/4278651>`_.
List the supported algorithms of the server using the commands::

  # sshd -T | grep kex
  # sshd -T | grep Ciphers

On EL8 systems uncomment the line with the ``CRYPTO_POLICY=`` variable in ``/etc/sysconfig/sshd`` and restart the sshd service.

To verify, run ssh with the -vvv flag from a client to the relevant server::

  # ssh -vvv user@server

.. _Cipher: https://en.wikipedia.org/wiki/Cipher
.. _HMAC: https://en.wikipedia.org/wiki/Hash-based_message_authentication_code
.. _KEX: https://en.wikipedia.org/wiki/Key_exchange

OpenSSH 5.3
-----------

The version 5.3 is found in RHEL/CentOS 6.

In Security_Guidelines_OpenSSH_ is recommended in ``sshd_config``::

  HostKey /etc/ssh/ssh_host_rsa_key
  HostKey /etc/ssh/ssh_host_ecdsa_key
  KexAlgorithms diffie-hellman-group-exchange-sha256
  MACs hmac-sha2-512,hmac-sha2-256
  Ciphers aes256-ctr,aes192-ctr,aes128-ctr

To generate the missing ECDSA key file run::

  ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key 

You must configure the correct SELinux_ contexts, for example::

  chcon --reference=ssh_host_rsa_key ssh_host_ecdsa_key*

Check the files::

  # ls -Z ssh_host*key*
  -rw-------. root root system_u:object_r:sshd_key_t:s0  ssh_host_dsa_key
  -rw-r--r--. root root system_u:object_r:sshd_key_t:s0  ssh_host_dsa_key.pub
  -rw-------. root root system_u:object_r:sshd_key_t:s0  ssh_host_ecdsa_key
  -rw-r--r--. root root system_u:object_r:sshd_key_t:s0  ssh_host_ecdsa_key.pub
  -rw-------. root root system_u:object_r:sshd_key_t:s0  ssh_host_key
  -rw-r--r--. root root system_u:object_r:sshd_key_t:s0  ssh_host_key.pub
  -rw-------. root root system_u:object_r:sshd_key_t:s0  ssh_host_rsa_key
  -rw-r--r--. root root system_u:object_r:sshd_key_t:s0  ssh_host_rsa_key.pub


OpenSSH 6.6
-----------

The version 6.6 is found in RHEL/CentOS 7.

The Mozilla Wiki Security_Guidelines_OpenSSH_ recommends for OpenSSH 6.7+::

  # Supported HostKey algorithms by order of preference.
  HostKey /etc/ssh/ssh_host_ed25519_key
  HostKey /etc/ssh/ssh_host_rsa_key
  HostKey /etc/ssh/ssh_host_ecdsa_key
 
  KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256
 
  Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
 
  MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com
 
  # Password based logins are disabled - only public key based logins are allowed.
  AuthenticationMethods publickey
 
  # LogLevel VERBOSE logs user's key fingerprint on login. Needed to have a clear audit track of which key was using to log in.
  LogLevel VERBOSE
 
  # Log sftp level file access (read/write/etc.) that would not be easily logged otherwise.
  Subsystem sftp  /usr/lib/ssh/sftp-server -f AUTHPRIV -l INFO
 
  # Root login is not allowed for auditing reasons. This is because it's difficult to track which process belongs to which root user: 
  #
  # On Linux, user sessions are tracking using a kernel-side session id, however, this session id is not recorded by OpenSSH.
  # Additionally, only tools such as systemd and auditd record the process session id.
  # On other OSes, the user session id is not necessarily recorded at all kernel-side.
  # Using regular users in combination with /bin/su or /usr/bin/sudo ensure a clear audit track.
  PermitRootLogin No
 
  # Use kernel sandbox mechanisms where possible in unprivileged processes
  # Systrace on OpenBSD, Seccomp on Linux, seatbelt on MacOSX/Darwin, rlimit elsewhere.
  UsePrivilegeSeparation sandbox

The paper Applied_Crypto_Hardening_ recommends::

  Protocol 2
  # HostKeys for protocol version 2
  HostKey /etc/ssh/ssh_host_rsa_key
  #HostKey /etc/ssh/ssh_host_dsa_key
  #HostKey /etc/ssh/ssh_host_ecdsa_key
  HostKey /etc/ssh/ssh_host_ed25519_key
  PermitRootLogin no # or 'without-password' to allow SSH key based login
  StrictModes yes
  PermitEmptyPasswords no
  Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes128-ctr
  MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,hmac-ripemd160
  KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1,diffie-hellman-group-exchange-sha1

The Secure_Secure_Shell_Wiki_ recommends for RHEL7.1/CentOS7.1::

  HostKey /etc/ssh/ssh_host_ed25519_key
  HostKey /etc/ssh/ssh_host_rsa_key
  Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
  KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
  MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-ripemd160-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,hmac-ripemd160,umac-128@openssh.com

/etc/ssh/moduli file
--------------------

You may want to check or even recreate the ``/etc/ssh/moduli`` file.
From Blog Secure_Secure_Shell_:

If you chose to enable 5 (*diffie-hellman-group-exchange-sha256: Custom DH with SHA2*), 
open /etc/ssh/moduli if exists, and delete lines where the 5th column is less than 2000::

  awk '$5 > 2000' /etc/ssh/moduli > "${HOME}/moduli"
  wc -l "${HOME}/moduli" # make sure there is something left
  mv "${HOME}/moduli" /etc/ssh/moduli

If it does not exist, create it::

  ssh-keygen -G /etc/ssh/moduli.all -b 4096
  ssh-keygen -T /etc/ssh/moduli.safe -f /etc/ssh/moduli.all
  mv /etc/ssh/moduli.safe /etc/ssh/moduli
  rm /etc/ssh/moduli.all

This will take a while (maybe some hours).

**Note added:**
If your system runs SELinux_, set the SELinux_ security context::

  chcon -v --type=etc_t /etc/ssh/moduli

.. _SELinux: https://en.wikipedia.org/wiki/Security-Enhanced_Linux

Please verify the correct SELinux_ settings::

  # ls -Z /etc/ssh/moduli 
  -rw-r--r--. root root system_u:object_r:etc_t:s0       /etc/ssh/moduli

Generating user keys
====================

Normal users should generate SSH keys in their $HOME/.ssh/ directory by the following command::

  /usr/bin/ssh-keygen -t ${keytype} -f id_${keytype} -N ""

where ${keytype} is *rsa, dsa, ecdsa*, respectively.
The contents of the files .ssh/id_${keytype}.pub should be appended to the $HOME/.ssh/authorized_keys file.

Testing the SSH server
======================

Connect a client with verbose logging enabled to the SSH_ server::

  ssh -vvv myserver.com 

The various algorithms supported by a particular OpenSSH version can be listed with the following commands::
	
  ssh -Q cipher
  ssh -Q cipher-auth
  ssh -Q mac
  ssh -Q kex
  ssh -Q key

as explained in the ``man ssh`` page::

  -Q cipher | cipher-auth | mac | kex | key
     Queries ssh for the algorithms supported for the specified version 2.

The available features are: 

* cipher (supported symmetric ciphers),
* cipher-auth (supported symmetric ciphers that support authenticated encryption),
* mac (supported message integrity codes),
* kex (key exchange algorithms),
* key (key types).


OpenSSH bugs
============

WARNING: /etc/ssh/moduli does not exist, using fixed modulus
------------------------------------------------------------

The SSH_ server in OpenSSH_ 6.6p1 on RHEL7/CentOS7 may log a warning message in the syslog upon successful SSH_ logins::

  sshd[15880]: WARNING: /etc/ssh/moduli does not exist, using fixed modulus

even though the file ``/etc/ssh/moduli`` exists.

This error message can be traced to the source code in file ``dh.c`` up to and including OpenSSH 6.9p1::

        if ((f = fopen(_PATH_DH_MODULI, "r")) == NULL &&
            (f = fopen(_PATH_DH_PRIMES, "r")) == NULL) {
                logit("WARNING: %s does not exist, using fixed modulus",
                    _PATH_DH_MODULI);
                return (dh_new_group14());
        }

A patch that logs both file names has been proposed in http://lists.mindrot.org/pipermail/openssh-unix-dev/2015-July/034147.html.

An incorrect SELinux_ security context may prevent the *sshd* daemon from reading the files, causing the above syslog message.
Please verify the correct SELinux_ settings::

  # ls -Z /etc/ssh/moduli 
  -rw-r--r--. root root system_u:object_r:etc_t:s0       /etc/ssh/moduli
