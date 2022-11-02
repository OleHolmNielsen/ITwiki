.. _Docker_containers:

===========================================
Docker containers for applications on Linux
===========================================

Docker_ is an open-source project that automates the deployment of applications inside software containers, by providing an additional layer of abstraction and automation of operating-system-level virtualization on Linux.
Docker_ uses resource isolation features of the Linux kernel such as *cgroups* and kernel *namespaces* to allow independent "containers" to run within a single Linux instance, 
avoiding the overhead of starting and maintaining virtual machines.

.. Contents::

.. _Docker: https://en.wikipedia.org/wiki/Docker_%28software%29

Docker documentation
====================

See:

* Docker_homepage_ 
* Docker_user_guide_
* Working_with_containers_
* Docker_Hub_: A centralized place to build and share Docker container images, collaborate with friends and colleagues, and automate pipelines.

.. _Working_with_containers: https://docs.docker.com/userguide/usingdocker/
.. _Docker_homepage: https://www.docker.com/
.. _Docker_user_guide: http://docs.docker.com/userguide/
.. _Docker_Hub: https://hub.docker.com

Docker security
===============

See:

* `Docker security <https://docs.docker.com/articles/security/>`_.

* `Security Risks and Benefits of Docker Application Containers <https://zeltser.com/security-risks-and-benefits-of-docker-application/>`_.

Installing Docker
=================

Installing docker requires root priviledges.

For CentOS hosts see `Installing Docker - CentOS-7 <http://wiki.centos.org/Cloud/Docker>`_::

  yum install docker
  systemctl start docker
  systemctl enable docker

To get the latest stable official CentOS image on Docker_Hub_::

  docker pull centos

To test this Docker_ container::

  docker run centos cat /etc/centos-release

See the ``man docker-run`` manual page.

To display running containers::

  docker ps
  docker ps -a

To stop a running container::

  docker stop <CONTAINER-ID>

Running docker as non-root user
===============================

In many places you will see this **bad advice** about adding users to the *docker* group:

* To permit a named user to user Docker_::

    DON'T DO THIS: usermod -a -G docker <your-user>

On RHEL7/CentOS7 this is **not permitted for security reasons**.
In `Bug 1214104 - /var/run/docker.sock permissions <https://bugzilla.redhat.com/show_bug.cgi?id=1214104>`_ this is explained::

  We don't want to allow docker access from non privileged users since this is the equivalent of allowing these users root access with no logging.  We would prefer that you set them up to use sudo.
  We will not fix this issue until we have proper logging and Access Control built into docker.

Conclusion: Users must use sudo_ to run docker, or docker must be run by *root*.

Setting up sudo to run docker
-----------------------------

Advice for running docker via sudo_:

* https://www.projectatomic.io/blog/2015/08/why-we-dont-let-non-root-users-run-docker-in-centos-fedora-or-rhel/

First install the sudo_ RPM::

  yum install sudo

Then use the command ``visudo`` to edit ``/etc/sudoers`` to include a line for user XXX::

  XXX  ALL=(ALL) /usr/bin/docker

.. _sudo: https://en.wikipedia.org/wiki/Sudo

Examples
========

* To run an interactive shell with a pseudo-tty::

    docker run -i -t centos /bin/bash

* Running Apache httpd server on CentOS container: https://registry.hub.docker.com/u/jdeathe/centos-ssh-apache-php/

* Fedora dockerfile for httpd: https://github.com/fedora-cloud/Fedora-Dockerfiles/tree/master/apache
