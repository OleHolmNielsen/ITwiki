.. _Ceph_storage:

==================================
Setting up a Ceph storage platform
==================================

Ceph_ is a free-software storage platform, implements object storage on a single distributed computer cluster, and provides interfaces for object-, block- and file-level storage. 

.. Contents::

.. _Ceph: https://ceph.com/


Ceph documentation
==================

* Wikipedia article: https://en.wikipedia.org/wiki/Ceph_(software)
* The Ceph_ homepage.
* Ceph_documentation_.
* The `ceph-users <http://lists.ceph.com/listinfo.cgi/ceph-users-ceph.com/>`_ mailing list.
* Ceph_ `Github repository <https://github.com/ceph>`_.
* `RedHat Ceph <https://www.redhat.com/en/technologies/storage/ceph>`_ page.
* `SUSE Ceph Solution <https://www.suse.com/solutions/software-defined-storage/ceph/>`_.
* Ceph-salt_ Salt states for Ceph cluster deployment.
* ceph-ansible_ Ansible playbooks for Ceph
* RedHat `Storage Cluster Installation <https://access.redhat.com/documentation/en-us/red_hat_ceph_storage/2/html/installation_guide_for_red_hat_enterprise_linux/storage_cluster_installation>`_ manual.
* Ceph_filesystem_

Tutorials:

* `How to build a Ceph Distributed Storage Cluster on CentOS 7 <https://www.howtoforge.com/tutorial/how-to-build-a-ceph-cluster-on-centos-7/>`_
* `Using Ceph as Block Device on CentOS 7 <https://www.howtoforge.com/tutorial/using-ceph-as-block-device-on-centos-7/>`_
* `How to Mount CephFS on CentOS 7 <https://www.howtoforge.com/tutorial/how-to-mount-cephfs-on-centos-7/>`_

Object storage:

* Ceph_ implements distributed object storage. Ceph’s software libraries provide client applications with direct access to the *reliable autonomic distributed object store* (**RADOS**) object-based storage system, and also provide a foundation for some of Ceph’s features, including RADOS Block Device (RBD), RADOS Gateway, and the Ceph File System.


.. _Ceph_documentation: http://docs.ceph.com/docs/master/
.. _ceph-ansible: http://docs.ceph.com/ceph-ansible/master/
.. _Ceph_filesystem: http://docs.ceph.com/docs/master/cephfs/
.. _Ceph-salt: https://github.com/komljen/ceph-salt

Ceph installation
=================

Get an overview of current stable and development versions:

* The Ceph_releases_ page.

.. _Ceph_releases: https://ceph.com/category/releases/

Preflight instructions
----------------------

First follow the preflight_ instructions for RHEL/CentOS.

.. _preflight: http://docs.ceph.com/docs/master/start/quick-start-preflight/

Enable the EPEL_ repository::

  yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

Then enable the Ceph_ repository for the current mimic_ or luminous_ release Yum repository::

  cat << EOM > /etc/yum.repos.d/ceph.repo
  [ceph-noarch]
  name=Ceph noarch packages
  # baseurl=https://download.ceph.com/rpm-luminous/el7/noarch
  baseurl=https://download.ceph.com/rpm-mimic/el7/noarch
  enabled=1
  gpgcheck=1
  type=rpm-md
  gpgkey=https://download.ceph.com/keys/release.asc
  EOM

The *baseurl* determines which release you will get.

Install this package::

  yum install ceph-deploy

Make sure that NTP is installed and configured::

  yum install ntp ntpdate ntp-doc

Install SSH server::

  yum install openssh-server

.. _EPEL: https://fedoraproject.org/wiki/EPEL

Creating cephuser
.................

Following the tutorial `How to build a Ceph Distributed Storage Cluster on CentOS 7 <https://www.howtoforge.com/tutorial/how-to-build-a-ceph-cluster-on-centos-7/>`_ 
we first create a Ceph user::

  export CephUSER=984
  groupadd -g $CephUSER cephuser
  useradd  -m -c "Ceph storage user" -d /var/lib/cephuser -u $CephUSER -g cephuser  -s /bin/bash cephuser
  passwd cephuser

Please do **NOT** use ``ceph`` as the user name.

Firewalld configuration
.......................

The Ceph_ preflight_ instructs to add ceph-mon and ceph services to firewalld.

Om *Monitor* nodes::

  firewall-cmd --zone=public --add-service=ceph-mon --permanent

On OSD and MDS nodes::

  firewall-cmd --zone=public --add-service=ceph --permanent

On all nodes then reload the *firewalld*::

  firewall-cmd --reload

Quickstart instructions for RHEL/CentOS
---------------------------------------

Follow the quickstart_ instructions for RHEL/CentOS.

.. _quickstart: http://docs.ceph.com/docs/master/start/quick-ceph-deploy/

You need an **admin node** which is **not** one of the Ceph_ nodes.
Log in to the **admin** node and run these instructions as user **cephuser** (not as root or by sudo)!

Create a Ceph_ Storage Cluster with one Ceph_ Monitor and three Ceph_ OSD Daemons::

  mkdir my-cluster
  cd my-cluster

Create the cluster on node *mon1*::

  ceph-deploy new mon1

This will create ``ceph.conf`` and other configuration files in the current directory.

**Warning**::

  The ceph-deploy tool will install the old jewel v.10 release by default!

You need to specify the current stable mimic_ v.13 (or the older luminous_ v.12) release explicitly, otherwise you will get the old jewel_ v.10 by default!!
See `this thread <http://lists.ceph.com/pipermail/ceph-users-ceph.com/2018-March/025187.html>`_.

Install Ceph_ on the monitor and OSD nodes::

  ceph-deploy install --release mimic mon1 osd1 osd2 osd3

.. _mimic: https://ceph.com/releases/v13-2-0-mimic-released/
.. _luminous: https://ceph.com/releases/v12-2-5-luminous-released/
.. _jewel: https://ceph.com/releases/v10-2-10-jewel-released/

After the installation has been completed, you may verify the Ceph_ version on all nodes::

  cephuser# sudo ceph --version

Deploy the initial monitor(s) and gather the keys::

  ceph-deploy mon create-initial

Use ceph-deploy to copy the configuration file and admin key to your admin node and your Ceph Nodes::

  ceph-deploy admin mon1 mds1 osd1 osd2 osd3

Deploy a manager daemon on the monitor node (required only for luminous+ builds)::

  ceph-deploy mgr create mon1

Create data devices (here assuming /dev/sdXX - change this to an unused disk device) on all the OSD nodes::

  ceph-deploy osd create --data /dev/sdXX osd1
  ceph-deploy osd create --data /dev/sdXX osd2
  ceph-deploy osd create --data /dev/sdXX osd3

Check the health details::

  ceph health detail

The correct result would be::

  HEALTH_OK

Test the Ceph cluster
---------------------

Do the **Exercise: Locate an Object** section at the end of the quickstart_ page.
Remember that all commands must be preceded by ``sudo``.

At the end of the exercise the storage pool is removed, however, this is **not permitted** with the mimic_ release.
The following error is printed::

  Error EPERM: pool deletion is disabled; you must first set the mon_allow_pool_delete config option to true before you can destroy a pool

Configure Ceph with Ansible
===========================

Instructions are in the ceph-ansible_ page.
onsult the Ceph_releases_ page for
Check out the *master* branch::

  git clone https://github.com/ceph/ceph-ansible.git
  git checkout masteronsult the Ceph_releases_ page for

Install Ansible::

  yum install ansible

See also our Wiki page :ref:`Ansible_configuration`.

Ceph Filesystem (CephFS)
========================

The CephFS_ filesystem (Ceph FS) is a POSIX-compliant filesystem that uses a Ceph Storage Cluster to store its data. 
The Ceph_ filesystem uses the same Ceph_ Storage Cluster system as Ceph_ Block Devices, Ceph_ Object Storage with its S3 and Swift APIs, or native bindings (librados).

See the CephFS_best_practices_ for recommendations for best results when deploying CephFS_.
For RHEL/CentOS 7 with kernel 3.10 the following recommendation of the FUSE_ client applies::

  As a rough guide, as of Ceph 10.x (Jewel), you should be using a least a 4.x kernel.
  If you absolutely have to use an older kernel, you should use the fuse client instead of the kernel client.

For a configuration guide for CephFS, please see the CephFS_ instructions.

.. _CephFS_best_practices: http://docs.ceph.com/docs/master/cephfs/best-practices/
.. _CephFS: http://docs.ceph.com/docs/master/cephfs/
.. _FUSE: http://docs.ceph.com/docs/mimic/cephfs/fuse/

Create a Ceph filesystem
------------------------

See the createfs_ page.

First create two RADOS pools::

  ceph osd pool create cephfs_data 128
  ceph osd pool create cephfs_metadata 128

The number of placement-groups_ (PG) is 128 in this example, as appropriate for <5 OSDs, see the placement-groups_ page.

An erasure-code_ pool may alternatively be created on 3 or more OSD hosts, in this case one also needs (see createfs_)::

  ceph osd pool set my_ec_pool allow_ec_overwrites true

List the RADOS pools by::

  ceph osd lspools

Create a filesystem by::

  ceph fs new cephfs cephfs_metadata cephfs_data
  ceph fs ls

Show the *metadata* server *mds1* status::

  ceph mds stat

To check a cluster’s data usage and data distribution among pools, you can use the *df* option on the monitoring node::

  ceph df

.. _createfs: http://docs.ceph.com/docs/master/cephfs/createfs/
.. _placement-groups: http://docs.ceph.com/docs/master/rados/operations/placement-groups/
.. _erasure-code: http://docs.ceph.com/docs/master/rados/operations/erasure-code/

Mount CephFS using FUSE
-----------------------

Installation of *ceph-fuse* package seems to be undocumented.
The CephFS client host must first install some prerequisites:

1. Enable the EPEL_ repository as shown above for preflight_.

2. Copy the file ``/etc/yum.repos.d/ceph.repo`` to the client host to enable the Ceph_ repository.

Then install the FUSE_ package::

  yum clean all
  yum install ceph-fuse

FUSE_ documentation is in http://docs.ceph.com/docs/mimic/cephfs/fuse/

Copy the Ceph_ config and client keyring files from the monitor node (mon1)::

  client# mkdir /etc/ceph
  mon1# cd /etc/ceph; scp ceph.conf ceph.client.admin.keyring client:/etc/ceph/

Do not give extra permissions to the secret ``ceph.client.admin.keyring`` file!

Mounting on the client host in ``/u/cephfs``::

  mkdir /u/cephfs
  ceph-fuse /u/cephfs

The FUSE_ server is read from ``ceph.conf``, or may be specified explicitly by the option ``-m mon1:6789``
See http://docs.ceph.com/docs/master/man/8/ceph-fuse/

List all mounted FUSE_ filesystems by::

  findmnt -t fuse.ceph-fuse

Umount the filesystem by::

  fusermount -u /u/cephfs

Mount by fstab
..............

The FUSE_ mount can be added to ``/etc/fstab`` as follows:

Add a FUSE_ mount point to fstab_ like this example::

  none    /u/cephfs  fuse.ceph ceph.conf=/etc/ceph/ceph.conf,_netdev,defaults  0 0

Now you can mount the filesystem manually::

  mount /u/fstab

Start and enable *Systemd* services for the ``/u/cephfs`` mount point::

  systemctl start ceph-fuse@/u/cephfs.service
  systemctl enable ceph-fuse@/u/cephfs.service

.. _fstab: http://docs.ceph.com/docs/mimic/cephfs/fstab/

Monitoring Ceph
===============

See http://docs.ceph.com/docs/jewel/rados/operations/monitoring/
