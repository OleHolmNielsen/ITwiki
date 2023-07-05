.. _DellOS6:

==============================
Dell OS6 network switch series
==============================

.. Contents::

This page describes configuration of Dell switch series N1000, N2000, N3000 running Dell OS6_ network OS.

.. _OS6: https://www.dell.com/learn/us/en/04/campaigns/dell-networking-os6

Initial switch configuration
============================

Connecting to the switch
------------------------

To monitor and configure the switch via the USB console, use the console
port on the front panel of the switch to connect it to a computer running
VT100 terminal emulation software using the supplied USB cable. It may be
necessary to download and install a driver on first use of the USB cable.

Perform the following tasks to connect a terminal to the switch console port:

* Connect the USB type B connector on the supplied switch and connect the other end to a computer running VT100 terminal emulation software.

* The Linux PC will create a new serial USB device::

    /dev/ttyUSB0

  Change device permissions::

    chmod 666 /dev/ttyUSB0

  Connect using *minicom* (or *screen*)::

    minicom -D /dev/ttyUSB0

* Configure the terminal emulation software as follows:
 
  * Select the appropriate serial port (for example, COM 1) to connect to the console.
  * Set the data rate to **115,200 baud**.
  * Set the data format to 8 data bits, 1 stop bit, and no parity.
  * Set the **flow control to none**.
  * Set the terminal emulation mode to VT100.
  * Select Terminal keys for Function, Arrow, and Ctrl keys. Make sure that the setting is for Terminal keys (not Microsoft Windows keys).

Initial setup
-------------

When connected through the serial port go to the **enable** mode and then to the **configure** mode::

  console>enable 
  console#configure                                                               
  console(config)#

Now create an administrator user name::

  console(config)#username admin password (secret-pwd) privilege 15

Set the hostname and gateway::

  console(config)#hostname switchname
  switchname(config)#ip default-gateway 10.2.128.2 

The switch MAC-address for DHCP is printed on the **service tag pull-out tab** on the front of the switch cabinet.

It can also be learned from the CLI::

  show ip interface
  Burned In MAC Address.......................... E4F0.046D.14A0  

Fixed IP address::

  switchname(config)#interface vlan 1 
  switchname(config-if-vlan1)#ip address none     # Disables DHCP client
  switchname(config-if-vlan1)#ip address 10.2.128.61 /16   # Fixed IP address
  switchname(config-if-vlan1)#exit

For dynamic IP address by DHCP::

  switchname(config)#interface vlan 1 
  switchname(config-if-vlan1)#ip address dhcp     # Enable DHCP client
  switchname(config-if-vlan1)#exit

SSH enable
----------

SSH and SSH keys setup::

  crypto key zeroize rsa
  crypto key zeroize dsa
  crypto key generate rsa
  crypto key generate dsa
  ip ssh protocol 2
  ip ssh server
  ip telnet server disable
  show ip ssh       

Now you should be able to connect to the switch using SSH from a server::

  $ ssh admin@switchname            

Write configuration to NVRAM
-----------------------------

Remember to **write** the configuration to NVRAM in **enable** mode::

  console(config)#exit                                                            
  console#write 

Ansible configuration
=====================

See our main :ref:`Ansible_configuration` page to get started.

Ansible_ modules for automation of Dell EMC Networking OS6 switches:

* https://www.ansible.com/integrations/networks/dell
* https://docs.ansible.com/ansible/latest/modules/list_of_network_modules.html#dellos6

Relevant roles from Ansible_Galaxy_:

* https://galaxy.ansible.com/search?deprecated=false&order_by=-relevance&keywords=Dell-Networking
* https://galaxy.ansible.com/dell-networking/dellos-system
* https://galaxy.ansible.com/dell-networking/dellos-interface
* https://galaxy.ansible.com/dell-networking/dellos-vlan
* https://galaxy.ansible.com/dell-networking/dellos-users
* https://galaxy.ansible.com/dell-networking/dellos-snmp
* https://galaxy.ansible.com/dell-networking/dellos-ntp

.. _Ansible_Galaxy: https://galaxy.ansible.com/

.. _Ansible: https://www.ansible.com/

Install Dell-Networking roles by::

  ansible-galaxy install Dell-Networking.dellos-system
  ansible-galaxy install Dell-Networking.dellos-snmp
  ansible-galaxy install Dell-Networking.dellos-ntp
  ansible-galaxy install Dell-Networking.dellos-interface
  ansible-galaxy install Dell-Networking.dellos-vlan
  ansible-galaxy install Dell-Networking.dellos-users


Using the network_cli connection
--------------------------------

See the blog https://www.ansible.com/blog/porting-ansible-network-playbooks-with-new-connection-plugins about the new **network_cli** connection.

First set up the switches for DHCP client IP address and SSH logins as shown above.

Define switches and variables in ``/etc/ansible/hosts`` for configuration connection::

  # Dell Poweredge N1100 series switches
  [DellN1100]
  switchname

  [DellN1100:vars]
  ansible_network_os=dellos6
  ansible_become=yes
  ansible_become_method=enable
  ansible_become_pass=
  ansible_user=admin
  ansible_password=<secret!>

Dellos6 bugs
------------

There are (as of Jan. 2019) some bugs which you must fix.

In ``/usr/lib/python2.7/site-packages/ansible/modules/network/dellos6/dellos6_config.py`` fix the **yes** answer to become **y**::

  # diff -u /usr/lib/python2.7/site-packages/ansible/modules/network/dellos6/dellos6_config.py.orig /usr/lib/python2.7/site-packages/ansible/modules/network/dellos6/dellos6_config.py
  --- /usr/lib/python2.7/site-packages/ansible/modules/network/dellos6/dellos6_config.py.orig	2018-12-13 22:14:39.000000000 +0100
  +++ /usr/lib/python2.7/site-packages/ansible/modules/network/dellos6/dellos6_config.py	2019-01-03 11:17:45.322096619 +0100
  @@ -287,7 +287,7 @@
           result['changed'] = True
           if not module.check_mode:
                   cmd = {'command': 'copy running-config startup-config',
  -                       'prompt': r'\(y/n\)\s?$', 'answer': 'yes'}
  +                       'prompt': r'\(y/n\)\s?$', 'answer': 'y'}
                   run_commands(module, [cmd])
                   result['saved'] = True
           else:



Dellos6 example
---------------

We will use the hosts **[DellN1100]** defined in ``/etc/ansible/hosts`` as shown above.

Go to your Ansible_ root directory, for example::

  cd ~/ansible

Create files in the ``host_vars`` directory with SNMP location and any other host-specific information for each switch, 
for example ``host_vars/switchname.yml``::

  location: "DK:Lyngby:Building:Room:Rack:Slot"

Please note that **semicolon** (;) apparently will be stripped from Ansible strings.
We have not found any way to protect/escape the ; character.

Create the group file ``group_vars/DellN1100.yml`` with variables that are common to all DellN1100 switches and which will be used by the Dell networking roles::

  ntp_server: 10.54.1.2
  contact: support@your.domain
  snmp_server: 10.54.1.1

  dellos_system:
    hostname: "{{ inventory_hostname }}"

  dellos_snmp:
    snmp_contact: "{{ contact }}"
    snmp_location: "{{ location }}"
    snmp_host: 
      - ip: "{{ snmp_server }}"
        version: "2c"
        communitystring: "public"
        state: present
    snmp_community:
      - name: public
        access_mode: ro
        state: present

  dellos_ntp:
    server:
      -  ip: "{{ ntp_server }}"

Create the Ansible_ playbook file ``DellN1100.yml`` containing some **pre_tasks** which must be run before the Dell Ansible_ roles::

  - hosts: DellN1100
    connection: network_cli
    gather_facts: no
    pre_tasks:
      - name: Set SSH Exec Timeout
        dellos6_config:
          lines: ['exec-timeout 600']
          parents: ['line ssh']
          match: exact
 
      - name: Set console Exec Timeout
        dellos6_config:
          lines: ['exec-timeout 600']
          parents: ['line console']
          match: exact
 
      - name: Set Timezone
        dellos6_config:
          lines:
            - 'clock summer-time recurring EU'
            - 'clock timezone 1 minutes 0'
          match: line
    
      - name: Disable telnet server
        dellos6_config:
          lines: ['ip telnet server disable']
          match: line
    
      - name: Disable http port 80 server
        dellos6_config:
          lines: ['no ip http server']
          match: line
    
      - name: Enable sntp unicast client
        dellos6_config:
          lines: ['sntp unicast client enable']
          match: line
    
    roles:
      - Dell-Networking.dellos-snmp
      - Dell-Networking.dellos-system
      - Dell-Networking.dellos-ntp

    post_tasks:
    - name: "Save running configuration to NVRAM, and make a backup"
      dellos6_config:
        backup: yes
        save: yes

The **post_tasks** performed at the end writes to configuration to NVRAM and makes a backup on the Ansible_ server in the ``backup/`` directory.

Run this playbook::

  ansible-playbook DellN1100.yml


Firmware upgrade
================

Ansible roles for upgrading the switch firmware exist only for the **OS10** switch series, **not for OS6** switches.
See https://galaxy.ansible.com/dell-networking/dellos-image-upgrade

You may install the role::

  ansible-galaxy install Dell-Networking.dellos-image-upgrade
