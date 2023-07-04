.. _MoinMoin_Wiki:

==========================================
Management of MoinMoin wikis for beginners
==========================================

.. contents::

*Rationale for this page:* 
The official and unofficial `MoinMoin <http://moinmo.in/>`_ documentation pages are sadly difficult to use when you need to do standard system administration tasks,
such as configuring and upgrading a `MoinMoin <http://moinmo.in/>`_ wiki.
Answers to simple beginner's questions are often extremely difficult to find, and you may spend hours googling for them.
Therefore we have collected the information below in order to provide an overview for *MoinMoin beginners* with pointers to the information on the web.
This page has also been copied into http://moinmo.in/HowTo with the title `Management of MoinMoin wikis for beginners <http://moinmo.in/HowTo/BeginnersLinux>`_.

*Caveat:* This information pertains to a *Linux* operating system with an *Apache* web-server. We use *RedHat RHEL5 Linux* on our server.

*Contact info:* Comments on this page are welcome !  Send mail to Ole.H.Nielsen *at* fysik.dtu.dk.

Download and install
====================

The MoinMoin_ wiki software can be downloaded from the MoinMoin_ Download_ page,
and a server installation should be installed as explained in https://master19.moinmo.in/InstallDocs#server.

We currently use MoinMoin_ version 1.9.11 which **requires Python 2.7**.

In 1.9.11 Python 2.6 **no longer works**, so CentOS/RHEL 6 **cannot use version 1.9.11** and must use the insecure version 1.9.10!

For installation we follow http://coq.inria.fr/cocorico/HelpOnInstalling/BasicInstallation and install MoinMoin_ to the default system location::

  tar xzf moin-1.9.11.tar.gz
  cd moin-1.9.11
  python setup.py install --record=install.log

You can also use Pip_ to install MoinMoin_::

  pip install moin-1.9.11.tar.gz

Some Linux distributions also have a *moin RPM*, however, these tend to be very much out of date (and therefore lacking security patches) and cannot be recommended
(for an example see `RPMforge <http://packages.sw.be/moin/>`_).

.. _Pip: https://pypi.org/project/pip/
.. _Download: https://moinmo.in/MoinMoinDownload

Ansible installation of MoinMoin
--------------------------------

We now (January 2020) use Ansible_ to configure a web-server with Apache and MoinMoin_.

Ansible_ playbooks and roles are on the *servauth3* server in ``/root/ansible``.
The relevant Ansible_ roles in the playbooks are:

   - ssl_certificate
   - apache_server
   - intrawiki
   - moinmoin

These roles take care of setting up Apache with SSL certificates, configuring MoinMoin_, and setting up the *intrawiki* files.

The playbboks and roles are also on GitHub: https://github.com/OleHolmNielsen/ansible

.. _Ansible: https://wiki.fysik.dtu.dk/it/Ansible_configuration

CentOS 8 installation
---------------------

The Python version in CentOS/RHEL 8.x is 3.6.8.
However, MoinMoin_ 1.9.11 **requires** Python 2.7 (previously 2.6).

As a workaround on CentOS/RHEL 8 you can install the old Python2 package::

  dnf install python2 python2-docutils python2-pip

and use the ``python2`` command everywhere in stead of ``python``.

Importantly, in ``/var/www/wiki/cgi-bin/moin.cgi`` you **must** replace the first line by::

  #!/usr/bin/env python2

moin command
------------

The installation creates just one user-level Moin command::

  /usr/bin/moin

Run ``/usr/bin/moin`` with no arguments to see the usage information.
There is also a page with `Help on Moin Command <http://master.moinmo.in/HelpOnMoinCommand>`_.

There are two important arguments to ``moin``:

* ``--config-dir``: Path to the directory containing the wiki configuration files. [**default: current directory**]
* ``--wiki-url``: URL of a single wiki to migrate e.g. http://localhost/mywiki/ [**default: CLI** (the actual meaning of the term "CLI" in this context remains a mystery so far)]

See also the source code file ``/usr/lib/python2.4/site-packages/MoinMoin/script/__init__.py``.

To get ``moin`` syntax help use::

  moin <module> <subcommand> --help

Documentation of MoinMoin
=========================

`About MoinMoin <http://en.wikipedia.org/wiki/MoinMoin>`_ (Wikipedia article).

There are some `MoinMoin HowTos <http://moinmo.in/HowTo>`_ and a list of `Help pages <http://moinmo.in/HelpIndex>`_.

You can also use the built-on Moin HelpContents pages (from the ``underlay/`` pages).

There are some `MoinMoin mailing lists <http://moinmo.in/MoinMoinMailingLists>`_,
especially the `Moin-user list <https://lists.sourceforge.net/lists/listinfo/moin-user>`_.

The `MoinMoin IRC chat <http://moinmo.in/MoinMoinChat>`_.


Supplementary third-party documentation of MoinMoin which we find useful:

* http://coq.inria.fr/cocorico/MoinMoin

Configuration of MoinMoin
=========================

We assume from now on that the Moin configuration files will be in::

  /var/www/wiki

This directory must be owned by user *apache* so that the web-server can write compiled Python *.pyc* files::

  chown apache.apache /var/www/wiki

Data directories
----------------

The Moin wiki data **must** be kept separate from the Apache webserver directories for security reasons,
see *Security warnings* in http://coq.inria.fr/cocorico/HelpOnInstalling/WikiInstanceCreation

We shall keep data directories in::

  /var/moin

The data files **must** be owned by user *apache* (so they can be changed), so it may be necessary to do::

    chown -R apache.apache /var/moin/*

in case some files do not have the correct ownership.

If your system has `SELinux <http://en.wikipedia.org/wiki/Selinux>`_ enabled and enforcing, you probably need to change the *SELinux* file context of the MoinMoin pages::

  chcon -R -t httpd_sys_content_t /var/moin

We can *rsync* this directory from another server if we want to copy the wiki to another server (also for `MoinMoin mirror`_ servers, see below),
and thereby all pages and users are copied over automatically.

Underlay directories (Help pages)
---------------------------------

The ``underlay/`` directories are used for shared read-only system and help pages.
In every *MoinMoin* wiki provides you with the HelpContents pages.
You probably want to share the ``underlay/`` directories between all of the wikis in your wiki farm (see `Farm configuration`_).

Copy MoinMoin's installed ``underlay/`` directory to another location, and make sure the files are owned by user *apache*::

  cp -rp /usr/share/moin/underlay /var/moin/
  chown -R apache.apache /var/moin/underlay/

MoinMoin version 1.9 Help pages
...............................

MoinMoin version 1.9 comes with **no system and help pages** installed by default!
You can only see the LanguageSetup page, see also http://master19.moinmo.in/LanguageSetup

First you must install the ``underlay/`` directories as shown in the preceding section.
Then install the help pages that you want in the languages you want, as instructed in the LanguageSetup page 
(you must do this in the Wiki, it can't be done on the command line):

1. Define a *superuser* in ``farmconfig.py``.
2. Log in as that superuser.
3. Go to the LanguageSetup page link *install help and system page packages*.
4. Select language and install just the help pages you need.

   Quickstart (for lazy people): Install the package **all_pages** for the language(s) in which you provide some content. 

5. Undefine the superuser again (for security reasons) - optional ?


Farm configuration
------------------

A *Farm* is a set of independent Wikis running on the same server.
The farm configuration is made in the file::

  /var/www/wiki/farmconfig.py

When upgrading Moin, back up the current configuration first,
then the new *farm template* file ``farmconfig.py`` should be copied from the new MoinMoin installation::

  cd /var/www/wiki
  cp -p farmconfig.py farmconfig.py.BAK
  cp /usr/share/moin/config/wikifarm/* .

The ``farmconfig.py`` should then be reconfigured with the relevant settings from the older ``farmconfig.py.BAK``.

You must define a shared ``underlay/`` directory for all Moin wiki farms in ``farmconfig.py`` by pointing to the ``underlay/`` directory (see `Underlay directories (Help pages)`_::

  data_underlay_dir = '/var/moin/underlay/'

For the farm's *Wiki instances*, check that the correct URL pattern is used in the lines with ``wikis``, for example::

  wikis = [
      ("it",  r"^wiki.example.com/it.*$"),
  ]

**Note:** With MoinMoin version 1.9 and above the syntax is slightly different::

  wikis = [
      ("it",  r"^https://wiki\.example\.com/it.*$"),
  ]

Creating or adding a new Wiki
-----------------------------

If you create a new Wiki, say ``XXX``, from scratch, or if you want to add an extra Wiki instance to an existing farm of Wikis,
there are instructions in http://coq.inria.fr/cocorico/HelpOnInstalling/WikiInstanceCreation

Use the file ``mywiki.py`` (copied from ``/usr/share/moin/config/wikifarm/``) as a configuration template::

  cp mywiki.py XXX.py
  chmod 644 XXX.py

Remember to add a new *ScriptAlias* to the `Apache configuration`_ files, and add the instance to ``farmconfig.py``.

Start by copying the templates directories::

  mkdir /var/moin/XXX/
  cp -rp /usr/share/moin/data /var/moin/XXX/
  chown -R apache.apache /var/moin/XXX

where XXX is the Moin instance directory.

Restructured text (docutils)
----------------------------

This is an optional step:
`Restructured text <http://docutils.sourceforge.net/rst.html>`_ is an easy-to-read, *what-you-see-is-what-you-get* plaintext markup syntax and parser system.
The `docutils <http://docutils.sourceforge.net/>`_ Python package must be installed if you want to enable 
`Restructured text <http://docutils.sourceforge.net/rst.html>`_ markup in the MoinMoin pages:

1. One way is to install an RPM from you distribution::

     yum install python-docutils

2. Another way is to install from source:
   Unpack the docutils source tar-ball and install::

     tar xzvf docutils-0.X.tar.gz 
     cd docutils-0.X
     python setup.py install

In order to enable Restructured text markup in the pages, define this in the ``XXX.py`` farm configuration files::

    # Use Restructured text as default markup
    default_markup = 'rst'

One feature of Restructured text that's poorly documented is how to link to attachments in the page.
This is done by the double-underscore like in this example::

  Migration of data is described in the *MoinMoin* file moin-VERSION/docs/README.migration__.
  
  __ attachment:README.migration.txt

A scant documentation of this is in http://moinmo.in/HelpOnParsers/ReStructuredText section *Support for MoinMoin-specific link schemes*.

Wiki navigation bar
-------------------

Moin contains a number of Wiki navigation tabs (the look depends on the *theme* chosen).
This is configured in the wiki instance file ``XXX.py`` by the *navi_bar* list, for example::

      navi_bar = [
        # Will use page_front_page, (default FrontPage)
        u'%(page_front_page)s',   # Wiki front page
        u'Linux',                 # An important topic...
        u'Windows',               # Another important topic...
        u'RecentChanges',         # Lists recently changed pages
        u'FindPage',              # Search page
        u'HelpContents',          # Help page
    ]

If the navi_bar doesn't work, for example HelpContents is not available, and you are using MoinMoin version 1.9 and above,
please see the section `MoinMoin version 1.9 Help pages`_ regarding installation of help pages.

User configuration
==================

Users can create accounts by themselves on the Wiki *Login* page, see also `Help on Login <http://moinmo.in/HelpOnLogin>`_.

The procedure for creating a new account is:

1. The user goes to the Wiki page in question and clicks on the **Login** link near the top of the page.
   This takes you to a page ``...?action=login``.
2. Click on the link *If you do not have an account, you can create one now*.
3. On the *Create Account* page, enter:

   a. Your Wiki username, by convention *FirstnameLastname*.
   b. Your password of choice (**not** a very secret password, it may not be safely stored!).
   c. Your E-mail address (for MoinMoin sending mail to the user, for example for password recovery).
   d. Press *Create Profile*.

MoinMoin stores a permanent cookie in your browser so the user will remain logged in.

There **does not** seem to be a MoinMoin interface to the `Linux PAM authentication <http://en.wikipedia.org/wiki/Linux_PAM>`_ modules,
so there doesn't seem to be any way to use Linux system username/password accounts.

Administrators can manage user accounts in MoinMoin, please see http://moinmo.in/HelpOnUserHandling.
The ``moin`` command has some user handling subcommands, see the syntax by::

  moin account check --help
  moin account create --help
  moin account disable --help
  moin account homepage --help
  moin account resetpw --help

User Groups and Access Control Lists
------------------------------------

`Access Control Lists <http://moinmo.in/HelpOnAccessControlLists>`_ (ACL's) allow you to control the permissions of a user or a group of users (which you define, see `HelpOnGroups <http://moinmo.in/HelpOnGroups>`_). 
You can define permissions for the entire wiki, or for select pages of the wiki. 
 
A `MoinMoin group <http://moinmo.in/HelpOnGroups>`_ is a simple data structure that maps a group name to a set of group member names. It can be used e.g. within ACL definitions to specify groups of users. 

You should make a page called AdminGroup and use it to define some people who get admin rights. 
The AdminGroup has the format::

  #acl AdminGroup:read,write,revert All:read
  #format wiki
  Members of this group will get admin rights. If you think you should be in this group, contact one of its members to add you.
  * SomeAdmin
  * AnotherAdmin

Notifications
-------------

MoinMoin can notify users of changed pages by E-mail, see `Help On Notification <http://moinmo.in/HelpOnNotification>`_.
Users can click on the *User* menu item *Settings* to manage their notifications.

Cleanup of pages
================

After some time there may be empty pages, deleted pages, or pages that are no longer referred to.
There is a cleanup command for this::

  moin maint cleanpage --help

which makes some shell commands (please review the commands in ``clean.sh``) to move bad pages out of the way::

  cd /var/moin/XXX
  mkdir trash deleted
  moin --config-dir=/var/www/wiki --wiki-url=wiki.example.com/XXX maint cleanpage > clean.sh
  sh -x clean.sh

Upgrading MoinMoin
==================

Migration of data is described in the *MoinMoin* file moin-VERSION/docs/README.migration__.

__ attachment:README.migration.txt

The wiki pages are accompanied by a **meta file** (not to be changed manually!) which described the *MoinMoin* version of all the pages::

  cat /var/moin/XXX/data/meta
  data_format_revision: 1090300

There exists further advice about upgrading MoinMoin:

* `Migration from moin 1.5 to 1.6 (and beyond) <http://moinmo.in/HowTo/Migrate%20from%201.5%20to%201.6>`_ (Linux based)
* `Updating from MoinMoin 1.5.x to 1.6.x <http://moinmo.in/RickVanderveer/UpgradingFromMoin15ToMoin16>`_ (Windows based)

Upgrading minor version 1.9.X to 1.9.Y
--------------------------------------

Install the new MoinMoin_ version as described above for a new installation, see `Download and install`_.

Next, in the Apache file ``/etc/httpd/conf.d/wiki.conf`` you must add a new line corresponding to the new version, for example::

  Alias /moin_static1911 "/usr/lib/python2.7/site-packages/MoinMoin/web/static/htdocs/"

You may have multiple lines like that without bad side effects.
Please note that MoinMoin_ 1.9.11 **requires Python 2.7** (no lower or higher versions will work!).

Remember to restart the Apache server after changing the configuration::

  systemctl restart httpd

MoinMoin version
----------------

It is not immediately obvious which version of *MoinMoin* is installed on a system.

One way to inquire about the installed version of *MoinMoin*  is to show the Wiki's SystemInfo page.
See `MoinMoinQuestions/Other <http://moinmo.in/MoinMoinQuestions/Other>`_ question *What version of MoinMoin is installed on my PC?*

Another way is using the ``moin`` command::

  moin --version
  MoinMoin 1.8.8 [release]

A third way is to look into the installed file ``/usr/lib/python2.4/site-packages/MoinMoin/version.py``.

If your *MoinMoin* has been installed by RPM, you can of course also do ``rpm -q moin``.

Upgrading from version 1.8 to 1.9
---------------------------------

The MoinMoin configuration files in version 1.9 differ somewhat from version 1.8.
As always, the old ``farmconfig.py`` and wiki files ``XXX.py`` should be reconfigured with some relevant settings from the older version backups.

Even though the MoinMoin 1.9 documentation recommends to use Apache with *WSGI* (see `Apache configuration`_ scripts below),
the old and slow ``moin.cgi`` works as well.
Make a backup first::

  cd /var/www/wiki/cgi-bin
  cp -p moin.cgi moin.cgi.BAK

before installing the ``moin.cgi`` from version 1.9 and configuring it as shown in `Configuration of MoinMoin`_.


Next steps:

1. Install MoinMoin version 1.9.X as usual (see `Download and install`_).

   You will have to modify the ``wikis`` list in ``farmconfig.py`` for version 1.9 like in `Farm configuration`_.

2. Perform page cleanup and migration as shown in the following section for upgrades to version 1.8.X, but with the new URL syntax::

     moin --config-dir=/var/www/wiki --wiki-url=https://wiki.example.com/XXX maint cleancache
     moin --config-dir=/var/www/wiki --wiki-url=https://wiki.example.com/XXX migration data

Apache web-server setup
=======================

There is some advice at http://coq.inria.fr/cocorico/HelpOnInstalling/ApacheOnLinux.

Apache scripts
--------------

The CGI script is the simplest and slowest way to implement a MoinMoin server.
The MoinMoin people recommend to use faster methods such as *FastCGI* or `WSGI <http://wsgi.org/>`_ (see http://master19.moinmo.in/InstallDocs#server).
See also http://coq.inria.fr/cocorico/HelpOnInstalling/ApacheOnLinux and the `Apache configuration`_ section below.

To use the simple CGI scripts, copy the Moin CGI file into the web-server directories::

  cp /usr/share/moin/server/moin.cgi /var/www/wiki/cgi-bin/moin.cgi

As explained in the help page, add the following line to ``moin.cgi`` which points to the location of Wiki files like ``farmconfig.py``::

  sys.path.insert(0, '/var/www/wiki')

One should use **absolute paths** in stead of relative paths.

Apache configuration
--------------------

First ensure that the required Apache packages are installed::

  rpm -q httpd mod_ssl

This is our Apache configuration file ``/etc/httpd/conf.d/wiki.conf`` for the Wiki (must change the server address)::

 # Wiki
 <VirtualHost XX.YY.ZZ.VV:80>
     AddDefaultCharset Off
     ServerAdmin webmaster@example.com
     ServerName wiki.example.com
     Redirect / https://wiki.example.com/
 </VirtualHost>   

 # Wiki SSL
 <VirtualHost XX.YY.ZZ.VV:443>
     AddDefaultCharset Off
     ServerAdmin webmaster@example.com
     ServerName wiki.example.com
     DocumentRoot /var/www/wiki/
     # For MoinMoin version >= 1.9
     # Static moin files for v.1.9.3, URL changes with Moin version:
     Alias /moin_static193 "/usr/lib/python2.4/site-packages/MoinMoin/web/static/htdocs/"
     # Required for /wiki/modern/css/*.css files:
     Alias /wiki/ "/usr/lib/python2.4/site-packages/MoinMoin/web/static/htdocs/"
     ScriptAlias /it "/var/www/wiki/cgi-bin/moin.cgi"
     SSLEngine On
     SSLCertificateFile /etc/pki/tls/certs/example.com.crt 
     SSLCertificateKeyFile /etc/pki/tls/private/example.com.key
 </VirtualHost>

Here ``moin_static193`` must be changed according the the Moin version being used !

The **IP address** in the configuration file must be changed according to which server is used.
Also, *SSL certificates* must be installed (beyond the scope of this page).

Logging
-------

Moin will make logging in the Apache logfiles by default.
Some explanation of Moin logging is in ``/usr/share/moin/config/logging/`` or in the source code ``moin-1.V.V/wiki/config/logging/``.
A thorough explanation of logging has not been found on the web so far.

Some example logging configurations are installed in the ``/usr/share/moin/config/logging/`` directory,
where we use the ``stderr`` example to make logging to the Apache webserver, changing however the loglevel in this file::

  [DEFAULT]
  # Default loglevel, to adjust verbosity: DEBUG, INFO, WARNING, ERROR, CRITICAL
  loglevel=WARNING

The default logging level is *INFO* which is useful while installing/debugging, but for a production site *WARNING* is better.

The ``stderr`` logging is configured in the ``moin.cgi`` file::

  # b) Configuration of moin's logging
  #    If you have set up MOINLOGGINGCONF environment variable, you don't need this!
  #    You also don't need this if you are happy with the builtin defaults.
  #    See wiki/config/logging/... for some sample config files.
  from MoinMoin import log
  log.load_config('/usr/share/moin/config/logging/stderr')


MoinMoin mirror
===============

This wiki can be mirrored on another server - all files in the ``/var/moin/`` directory are rsync'ed by a crontab job every night::

  10 0 * * * /usr/bin/rsync -aq /var/moin/ mirror:/var/moin/

Two configuration files must be modified so that the mirror wiki works and is read-only:

* In ``/var/www/wiki/XXX.py`` the following line is changed from::

    acl_rights_before = u"AdminGroup:read,write,delete,revert,admin"

  to::

    acl_rights_before = u"AdminGroup:read"

* The file ``/var/www/wiki/farmconfig.py`` must have the hostname configured as in::

    wikis = [
      ("it",  r"^mirror.example.com/it.*$"),
    ]
