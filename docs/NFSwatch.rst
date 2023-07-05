.. _NFSwatch_monitoring:

====================================
NFSwatch monitoring of an NFS server
====================================

.. Contents::

About nfswatch
==============

nfswatch_ is a tool used on an NFS_ server to monitor the NFS_ I/O traffic from NFS_ clients.
Unfortunately nfswatch_ hasn't been updated since 2010.

nfswatch_ is an **extremely useful** tool when you need to understand a server's NFS load.
For example, if you want to identify which NFS clients are making heavy I/O traffic to the NFS server.

Apparently nfswatch_ doesn't support NFS v4, see Bug_570981_.

.. _Bug_570981: https://bugzilla.redhat.com/show_bug.cgi?id=570981

.. _nfswatch: https://sourceforge.net/projects/nfswatch/
.. _NFS: https://en.wikipedia.org/wiki/Network_File_System

Installing nfswatch
===================

RHEL/CentOS/AlmaLinux/RockyLinux 8
----------------------------------

There are no RPM packages of nfswatch_ for EL8 Linux distributions.
However, you can build an RPM using the Fedora_ source as follows:

1. Download the source RPM from the Fedora build system page https://src.fedoraproject.org/rpms/nfswatch

2. Rebuild the package::

     rpmbuild --rebuild nfswatch-4.99.11-20.fc34.src.rpm 

3. Install the RPM::

     dnf install $HOME/rpmbuild/RPMS/x86_64/nfswatch-4.99.11-20.el8.x86_64.rpm

RHEL/CentOS 7
-------------

There are no RPM packages of nfswatch_ for RHEL/CentOS 7, not even in the EPEL_ repository.
However, you can build an RPM using the Fedora_ source as follows:

1. Download the source RPM from the Fedora build system page `nfswatch-4.99.11-11.fc26 <https://koji.fedoraproject.org/koji/buildinfo?buildID=847903>`_::

     wget https://kojipkgs.fedoraproject.org//packages/nfswatch/4.99.11/11.fc26/src/nfswatch-4.99.11-11.fc26.src.rpm

   or check for newer packages at https://koji.fedoraproject.org/koji/packageinfo?packageID=2637

2. Rebuild the package::

     rpmbuild --rebuild nfswatch-4.99.11-11.fc26.src.rpm

3. Install the RPM::

     yum install $HOME/rpmbuild/RPMS/x86_64/nfswatch-4.99.11-11.el7.centos.x86_64.rpm

.. _EPEL: https://fedoraproject.org/wiki/EPEL
.. _Fedora: https://en.wikipedia.org/wiki/Fedora_(operating_system)


RHEL/CentOS 6
-------------

RPM packages for RHEL/CentOS 6 and other OSes can be found in http://rpmfind.net/linux/rpm2html/search.php?query=nfswatch

The EL6 package page is http://rpmfind.net/linux/RPM/dag/redhat/el6/x86_64/nfswatch-4.99.9-1.el6.rf.x86_64.html

Using nfswatch
==============

See the ``man nfswatch`` manual page.

On CentOS 6 and 7 the nfswatch_ tool spits out lots of error messages::

   Unknown Linux fsid_type 6:

It is not obvious which of the file systems the error message refers to.

However, you can still use nfswatch_ by piping the error messages::

  nfswatch 2>/dev/null

Here is a recommended usage monitoring all network interfaces, listing NFS clients, and sort them by usage::

  nfswatch -allif -clients -usage 2>/dev/null

You can also get the usernames of NFS client users::

  nfswatch -allif -auth -usage 2>/dev/null

You may add these convenient aliases to your ``.bashrc`` file::

  # NFS watch clients
  alias nfsw='nfswatch -allif -clients -usage 2>/dev/null'
  # NFS watch users
  alias nfsu='nfswatch -allif -auth -usage 2>/dev/null'


Other NFS monitoring tools
==========================

There doesn't seem to be any other tool which provides information similar to nfswatch_.
However, some insights may be gleaned using these methods:

1. Use iftop_ to monitor all traffic on a specific interface, for example::

     iftop -i ib0

   Get iftop_ from the EPEL_ repository.

2. `Analyzing Linux NFS server performance <https://serverfault.com/questions/38756/analyzing-linux-nfs-server-performance>`_ suggests these commands::

     netstat -plaute | grep nfs
     watch -d "netstat -plaute | grep nfs | sort -k 4,5"

   I suggest this watch command::

     watch -n 5 "netstat -plate | grep nfs | sort -r -n -k 3,2"

3. Use the nfsiostat_ command on each NFS client, see `Monitoring Client NFS Storage with nfsiostat <http://www.admin-magazine.com/HPC/Articles/Monitoring-NFS-Storage-with-nfsiostat>`_.

4. Use tcpdump_ to log NFS port 2049 traffic (50000 packets)::

     tcpdump -n -vvv -s 200 port 2049 | grep '> IP-address' | head -50000 | sed 's/>.*//' |  awk -F. '{printf("%d.%d.%d.%d\n", $1,$2,$3,$4)}' | sort | uniq -c | sort -n +0 -1 

   where you must substitute the NFS server's IP in stead of **IP-address**.


.. _iftop: http://www.ex-parrot.com/pdw/iftop/
.. _tcpdump: https://en.wikipedia.org/wiki/Tcpdump
.. _nfsiostat: https://www.redhat.com/sysadmin/using-nfsstat-nfsiostat
