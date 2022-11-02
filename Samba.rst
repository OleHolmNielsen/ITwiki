.. _Samba_service:

=============
Samba service
=============

.. Contents::

Introduction
============ 

Samba_ provides Windows networking services using a Unix machine.

The resources available on a Windows Network is called the `browse list`. 
The `browse list` is maintained on a computer called the `Master Browser`. 
For a Windows network spanning multiple subnets, a 
`domain master browser` collects the browse list for the entire domain.  
The fys `domain master brower` is `intra`. You can view the current 
browse list from a unix machine using, the `smbclient` command:: 

    smbclient -L intra

This could look like this::

 Password:
 Domain=[INTRA] OS=[Unix] Server=[Samba 3.0.9-1.3E.5]

        Sharename       Type      Comment
        ---------       ----      -------
        camp            Disk      CAMP group shared directory
        mossbauer       Disk      Mossbauer group shared directory
        mossbauerWWW    Disk      Mossbauer group WWW directory
        mossstud        Disk      Mossbauer group student directory
        WWW             Disk      World Wide Web data for dcwww.fys.dtu.dk
        wwwstm          Disk      STM WWW-files (restricted access)
        cinfWWW         Disk      CINF WWW-server files (restricted access)
        NanoteketWWW    Disk      Nanoteket WWW-server files (restricted access)
        cinfDB          Disk      CINF Database files (access only for CINF)
        IPC$            IPC       IPC Service (INTRA FYS Samba Server)
        ADMIN$          IPC       IPC Service (INTRA FYS Samba Server)
        camp4200        Printer   Created by redhat-config-printer 0.6.x
        lhansen         Disk      Home Directories
 Domain=[INTRA] OS=[Unix] Server=[Samba 3.0.9-1.3E.5]

        Server               Comment
        ---------            -------

        Workgroup            Master
        ---------            -------
        AABOULEVARD          RUBECH
        ARBEJDSGRUPPE        FARSLAPTOP
        FYS                  INTRA
        MSHOME               MATRIXII
        WORKGROUP            STREBELNOTEBOOK


NetBIOS resolution of names across subnet is done, not using DNS, 
but  `Windows Internet Name Service` or `WINS`.
`WINS` provides a dynamically updated central database, which can be used to 
resolve hostnames into IP adresses. 

The `smb.conf` file
=================== 

This section describes the changes from the default `smb.conf` at 
fys: 

Global:: 
 
   workgroup = FYS 
    
   server string = INTRA FYS Samba Server  # Replace "INTRA" by actual server name

   hosts allow  = 130.225.86. 130.225.87. 127.l

   max log size = 1000 

   password level = 2
   username level = 2

   local master = yes
   os level = 60 

   domain master = yes

   preferred master = yes

   wins support = yes

   wins proxy = yes
   dns proxy = yes 

   # local setup 
   display charset = UTF8 
   utmp = yes 

   create mask = 0644
   directory mask = 0755


Other shares defined at fys: 

* homes 
* mossbauer

In these setting the `netbios name` is not set explicitly. 
The `netbios name` will in this case get the first part of DNS name. 

The `netbios name` can be changed using:: 

     netbios name = intra

SAMBA password database
=======================

We use Samba's default database for storing passwords, as configured in ``smb.conf``::

  security = user
  passdb backend = tdbsam

Use this command to list the contents of the TDBSAM password database::

  /usr/bin/pdbedit -L
  /usr/bin/pdbedit -L -w -u <USERNAME>

Use the ``pdbedit -i`` command to insert a new user into the database.
To delete an existing user from the database::

  pdbedit -x -u <USERNAME>

Location of SAMBA password database
-----------------------------------

The TDBSAM password database file is ``passdb.tdb``.
With Samba version 3.3 and above (used by RHEL6/CentOS6), the password database is located in::

  /var/lib/samba/private/

The Samba-3 docs show a general method for determining the `TDB Database File Information <http://www.samba.org/samba/docs/man/Samba-HOWTO-Collection/install.html#tdbdocs>`_
where the file location is given by ``PRIVATE_DIR``::

  root# smbd -b | grep PRIVATE_DIR
  PRIVATE_DIR: /etc/samba/private


WINS server
===========

The `FYS` Workgroup spans across mutiple TCP/IP subnets. 
NETBIOS name resolution in this situation relies on a WINS (Windows Internet Name Service) 
server to resolve NETBIOS names. 
In our case the Samba server is set up to be the WINS server. This is done 
in the `smb.conf` file (wins support = yes). 

The IP adress of the WINS server must be supplied to dhcpd via the `netbios-name-servers`::

   option netbios-name-servers 130.225.86.4;

.. _Samba : http://www.samba.org 
