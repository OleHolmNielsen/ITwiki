.. _RedHat_Enterprise_Linux:

==================================
RedHat Enterprise Linux and clones
==================================

.. Contents::

RHEL and CentOS documentation
===================================

There is some relevant documentation:

* `CentOS 7 Release Notes <http://wiki.centos.org/Manuals/ReleaseNotes/CentOS7>`_ and CentOS7_FAQ_.

* `RHEL7 documentation <https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/>`_
  including `Release Notes <https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/7.0_Release_Notes/>`_.

.. _CentOS7_FAQ: http://wiki.centos.org/FAQ/CentOS7

AlmaLinux documentation
============================

Alma:ref:`Linux` resources:

* `AlmaLinux Wiki <https://wiki.almalinux.org/>`_
* Mirror list at https://mirrors.almalinux.org/
* We have a local AlmaLinux_ mirror at https://mirror.fysik.dtu.dk/linux/almalinux/
* To switch from CentOS 8 to Alma:ref:`Linux` use the EL to AlmaLinux migration tool in https://github.com/AlmaLinux/almalinux-deploy.

.. _AlmaLinux: https://almalinux.org/

RockyLinux documentation
============================

The Rocky:ref:`Linux` has a `download page <https://rockylinux.org/download>`_ and a `FAQ <https://rockylinux.org/faq/>`_.

* We have a local RockyLinux_ mirror at https://mirror.fysik.dtu.dk/linux/rockylinux/

Ansible_ 2.9.20 does not have Rocky:ref:`Linux` in the *hostname module* file */usr/lib/python3.6/site-packages/ansible/modules/system/hostname.py*.
Updates have been committed to Ansible_ 2.9+ in PRs https://github.com/ansible/ansible/pull/74545 and https://github.com/ansible/ansible/issues/74565

.. _RockyLinux: https://rockylinux.org/
.. _Ansible: https://wiki.fysik.dtu.dk/ITwiki/Ansible_configuration

CentOS Stream documentation
============================

Information about CentOS Stream_:

* https://blog.centos.org/2020/12/future-is-centos-stream/
* https://arstechnica.com/gadgets/2020/12/centos-shifts-from-red-hat-unbranded-to-red-hat-beta/
* https://www.linkedin.com/pulse/why-you-should-have-already-been-centos-stream-back-2019-smith/

Converting from CentOS Linux to CentOS Stream_::

  $ dnf swap centos-linux-repos centos-stream-repos
  $ dnf distro-sync

.. _Stream: https://www.centos.org/centos-stream/

CentOS AppStream
----------------------

CentOS 8 (and the clones) has a new concept **AppStream**::

  Content in the AppStream repository includes additional user space applications, runtime languages, and databases in support of the varied workloads and use cases. Content in AppStream is available in one of two formats - the familiar RPM format and an extension to the RPM format called modules.

See:

* `Using AppStream <https://docs.centos.org/en-US/8-docs/managing-userspace-components/assembly_using-appstream/>`_.

* `Installing CentOS 8 content <https://docs.centos.org/en-US/8-docs/managing-userspace-components/assembly_installing-rhel-8-content/>`_ including *module streams*.
