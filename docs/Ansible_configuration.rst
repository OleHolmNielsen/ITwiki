.. _Ansible_configuration:

===================================================
Ansible configuration of Linux servers and desktops
===================================================

.. Contents::

Ansible_ is used for configuration of Linux servers and desktops.

Getting started with Ansible
============================

Tutorials on Ansible_:

* Getting_started_ tutorial.
* Server World: https://www.server-world.info/en/note?os=CentOS_7&p=ansible&f=1
* An Ansible Tutorial: https://serversforhackers.com/c/an-ansible-tutorial
* Ansible_blog_
* `Introduction To Ad-Hoc Commands <http://docs.ansible.com/ansible/latest/intro_adhoc.html>`_.
* `How to Use Ansible: A Reference Guide <https://www.digitalocean.com/community/cheatsheets/how-to-use-ansible-cheat-sheet-guide>`_.

Further documentation:

* Glossary_ of term definitions used elsewhere in the Ansible_ documentation.
* Best_practices_.
* YAML_Syntax_ for playbooks etc.

.. _Glossary: http://docs.ansible.com/ansible/latest/glossary.html
.. _Best_practices: http://docs.ansible.com/ansible/latest/playbooks_best_practices.html
.. _YAML_Syntax: http://docs.ansible.com/ansible/latest/YAMLSyntax.html
.. _Ansible_blog: https://www.ansible.com/blog

There is an Ansible_github_ repository.

.. _Ansible: https://www.ansible.com/
.. _Getting_started: http://docs.ansible.com/ansible/intro_getting_started.html
.. _Ansible_github: https://github.com/ansible/

Inventory
---------

Ansible_ works against multiple systems in your infrastructure at the same time. 
It does this by selecting portions of systems listed in Ansible_’s inventory_file_, which defaults to being saved in the location::

  /etc/ansible/hosts

You can specify a different inventory file using the ``-i <path>`` option on the command line.

.. _inventory_file: http://docs.ansible.com/ansible/latest/intro_inventory.html

Modules
-------

* All modules: https://docs.ansible.com/ansible/2.9/modules/list_of_all_modules.html
* Modules by category: https://docs.ansible.com/ansible/2.9/modules/modules_by_category.html
* Packaging modules: https://docs.ansible.com/ansible/2.9/modules/list_of_packaging_modules.html

Ansible Vault
-------------

Ansible Vault_ is a feature of Ansible_ that allows you to keep sensitive data such as passwords or keys in encrypted files, rather than as plaintext in playbooks or roles. 
These vault files can then be distributed or placed in source control.

To enable this feature, a command line tool::

  ansible-vault

is used to edit files, and a command line flag (--ask-vault-pass, --vault-password-file or --vault-id) is used. 
Alternately, you may specify the location of a password file or command Ansible to always prompt for the password in your ansible.cfg file. 
These options require no command line flag usage.

.. _Vault: https://docs.ansible.com/ansible/latest/user_guide/vault.html

Playbooks
---------

* Introduction:  http://docs.ansible.com/ansible/playbooks_intro.html
* Playbook conditionals: http://docs.ansible.com/ansible/playbooks_conditionals.html
* Tests expressions: http://docs.ansible.com/ansible/latest/playbooks_tests.html
* Error Handling In Playbooks: http://docs.ansible.com/ansible/latest/playbooks_error_handling.html

Roles
-----

* Roles_ documentation.

* `Red Hat Enterprise Linux (RHEL) System Roles <https://access.redhat.com/articles/3050101>`_.

.. _Roles: http://docs.ansible.com/ansible/latest/playbooks_roles.html

Galaxy
-------

Galaxy_ provides pre-packaged units of work known to Ansible as roles.

Some useful Galaxy_ packages include:

* `linux-system-roles/network <https://galaxy.ansible.com/linux-system-roles/network/>`_ This role enables users to configure network on target machines.
  Install by::

    ansible-galaxy install linux-system-roles.network

To upgrade a version from Galaxy_,
you have to install it with the ``--force`` option::

  ansible-galaxy install --force <galaxy-role-name>

List installed Galaxy_ packages::

  ansible-galaxy list

.. _Galaxy: https://galaxy.ansible.com/

Callbacks
---------

Callback_ plugins enable adding new behaviors to Ansible_ when responding to events. 
For example, the skippy_ plugin will make Ansible_ screen output that ignores *skipped* status.

You must **whitelist** any plugins in ``ansible.cfg``, for example::

  stdout_callback = skippy
  callback_whitelist = skippy


.. _Callback: https://docs.ansible.com/ansible/latest/plugins/callback.html
.. _skippy: https://docs.ansible.com/ansible/latest/plugins/callback/skippy.html


Network Automation with Ansible
===============================

Ansible’s simple automation framework means that previously isolated network administrators can finally speak the same language of automation as the rest of the IT organization, extending the capabilities of Ansible to include native support for both legacy and open network infrastructure devices. 
Network devices and systems can now be included in an organization's overall automation strategy for a holistic approach to application workload management.

* `Command Module Deep Dive for Networks <https://www.ansible.com/blog/command-module-deep-dive-for-networks>`_
* `Network Automation with Ansible <https://www.ansible.com/network-automation>`_
* `Advanced Topics with Ansible for Network Automation <https://docs.ansible.com/ansible/latest/network/user_guide/index.html>`_
* List of `Network modules <https://docs.ansible.com/ansible/latest/modules/list_of_network_modules.html>`_

Product specific Ansible documentation:

* :ref:`DellOS6` N1000, N2000 and N3000 series (N1148P etc.)

Setting up client hosts
=======================

SSH authorized keys
-------------------

Password-less login from the Ansible_ server requires SSH authorized keys.
Initially you must set up SSH keys on all client hosts as *root*::

  mkdir $HOME/.ssh
  restorecon -R -v $HOME/.ssh
  scp <ansible-server>:.ssh/id_ecdsa.pub .
  cat id_ecdsa.pub >> $HOME/.ssh/authorized_keys
  rm -f id_ecdsa.pub

Test the Password-less login from the server::

  server# ssh <client> date

Setting up the Ansible server
=============================

Configuration file
------------------

The Ansible_ configuration_file_ is ``/etc/ansible/ansible.cfg``.

.. _configuration_file: http://docs.ansible.com/ansible/intro_configuration.html

For local logging to a file uncomment this line::

  log_path=/var/log/ansible.log

and create the file::

  touch /var/log/ansible.log

Inventory: Hosts and Groups
---------------------------

Ansible_ works against multiple systems in your infrastructure at the same time. 
It does this by selecting portions of systems listed in Ansible_’s Inventory_, 
which defaults to being saved in the location ``/etc/ansible/hosts``.

.. _Inventory: http://docs.ansible.com/ansible/intro_inventory.html

Add Ansible_ client hosts to the file ``/etc/ansible/hosts``, for example::

  [camd-desktops]
  dirac.fysik.dtu.dk

Inventory: host-specific files
------------------------------

Sometimes some files with host-specific contents/data must be copied to the remote host.
Unfortunately, Ansible_ doesn't have any obvious way to copy host-specific files.

A solution exists, see `Where should I be organizing host-specific files/templates? <https://stackoverflow.com/questions/32830428/where-should-i-be-organizing-host-specific-files-templates>`_:

In the top-level directory (same level as playbooks) I have a files folder. 
In the files folder there is a folder for every host with it's own files where the folder's name is the same as the host name in inventory::

  .
  ├── files
  │   ├── common
  │   ├── myhost1
  │   ├── myhost2

Now in any role you can access the files with files modules relatively::

  - name: Copy any host based file
    copy:
      src={{ inventory_hostname }}/file1
      dest= /tmp

Explanation:

The magic variable inventory_hostname_ is to get the host.
Any file module (as for example copy) looks up the files directory in the respective role directory and the files directory in the same level as the calling playbook.
Of course same applies to templates (but if you have different templates for the same role you should reconsider your design)

.. _inventory_hostname: http://docs.ansible.com/ansible/latest/playbooks_variables.html#magic-variables-and-how-to-access-information-about-other-hosts

Basic Ansible tests
-------------------

Make the recommended tests::

  ansible all -m ping
  ansible all -a "/bin/echo hello"

Ansible facts
-------------

To print all facts gathered use the setup_ module::

  ansible XXX.fysik.dtu.dk -m setup

.. _setup: http://docs.ansible.com/ansible/latest/setup_module.html

Playbook examples
=================

To limit the playbook to one host only use the -l option::

  ansible-playbook <playbook>.yml -l hostname

Yum install
-----------

Playbook task::

    tasks:
    - name: Install the latest version of EPEL repository
      yum:
        name: epel-release
        state: latest
    - name: Install popular packages from the EPEL repository
      yum:
        name: Lmod,git-all,python34-pip,python2-pip
        state: latest

Create an empty file
--------------------

See `How to create an empty file with Ansible? <https://stackoverflow.com/questions/28347717/how-to-create-an-empty-file-with-ansible>`_.
It is better to use the ``copy`` module::

    - name: Create file if it does not exist
    copy:
      content: ""
      dest: <file>
      force: no
      owner: root
      group: root
      mode: 0644

in stead of the standard *touch* module which actually modifies the timestamp.

Playbook error handlers
-----------------------

Sometimes you want to ignore the **changed** status of a task.
Use the Playbook_error_handlers_ for Overriding The Changed Result::

  # this will never report 'changed' status
  - shell: wall 'beep'
    changed_when: False

.. _Playbook_error_handlers: http://docs.ansible.com/ansible/playbooks_error_handling.html

Loops in Ansible
----------------

Ansible offers two keywords for creating loops: ``loop`` and ``with_<lookup>``, see the loops_ page.
Ansible_ added ``loop`` in version 2.5. It is not yet a full replacement for ``with_<lookup>``, but we recommend it for most use cases.

Examples of loops_::

  disks: 
    - /dev/sdb 
    - /dev/sdc

  - name: Create a new GPT primary partition for LVM
    parted:
      device: "{{ item }}"
      number: "{{ partition }}"
      label: gpt
      flags: [ lvm ]
     state: present
    loop: "{{ disks }}"

Nested loops are also possible (although difficult to write).
See these examples:

* https://stackoverflow.com/questions/41908715/ansible-with-subelements


.. _loops: https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html

Using filters to manipulate data
--------------------------------

In Ansible_ functions are called filters_ and are used for transforming data inside a template expression. Ansible supports all filters provided by Jinja2 and also ships its own filters_. 

Filters let you transform JSON data into YAML data, split a URL to extract the hostname, get the SHA1 hash of a string, add or multiply integers, and much more. 
See the Ansible_ filters_ page and the blog post https://cloudaffaire.com/functions-in-ansible/

Getting an overview of available filters_ is surprisingly difficult!
The *Jinja template* page contains a comprehensive list of builtin-filters_.

Some example of useful filters include::

  int() length() string()

and may be used, for example, as::

  # Count the physical volumes in the disks array
  - debug:
      msg: "{{ 'Number of disk volumes is ' + disks|length|string + ' on disks ' + disks|string }}"


.. _filters: https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html
.. _builtin-filters: https://jinja.palletsprojects.com/en/2.11.x/templates/#builtin-filters

Lookup plugins
==============

Lookup_ plugins allow Ansible to access data from outside sources. This can include reading the filesystem in addition to contacting external datastores and services. Like all templating, these plugins are evaluated on the Ansible control machine, not on the target/remote.

The data returned by a lookup plugin is made available using the standard templating system in Ansible, and are typically used to load variables or templates with information from those systems.

Lookup_ s are an Ansible-specific extension to the Jinja2 templating language.

List all lookup plugins by::

  ansible-doc -t lookup -l
  ansible-doc -t lookup <plugin name> 

.. _Lookup: https://docs.ansible.com/ansible/2.9/plugins/lookup.html
