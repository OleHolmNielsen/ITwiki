.. _NeDi_network_monitoring:

=======================
NeDi network monitoring
=======================

NeDi_ (*Network Discovery*) is an open source network monitoring tool (GNU GPL_ license) with optional commercial NeDi_support_.
There is a brief NeDi_flyer_.

|NeDi_logo|

.. |NeDi_logo| image:: attachments/NeDi_logo.png

.. Contents:: Contents of this page:
   :depth: 2

.. _GPL: http://www.gnu.org/licenses/gpl.html

.. _NeDi: http://www.nedi.ch/
.. _NeDi_support: http://www.nedi.ch/services/
.. _NeDi_installation: http://www.nedi.ch/installation/
.. _NeDi_documentation: http://www.nedi.ch/documentation/
.. _NeDi_about: http://www.nedi.ch/about/
.. _NeDi_flyer: http://www.nedi.ch/wp-content/uploads/2011/08/nedi-flyer11.pdf

NeDi documentation
==================

We have found the following NeDi_ documentation and tutorials:

* NeDi_documentation_ page.
* `Videos on Youtube <https://www.youtube.com/user/NetworkDiscovery>`_.
* `Video about new features in NeDi 1.5 <https://www.youtube.com/watch?v=JLU4RwUnjQA>`_.
* `Tutorial on drawings maps in NeDi <https://www.youtube.com/watch?v=-K6wBuCkOx8&feature=youtu.be>`_.
* Video `OSMC 2014: Network Discovery Update | Remo Rickli <https://www.youtube.com/watch?v=-FGd78JC2_4&list=FL1aYM5K5bXjuU4cBy2FpY3g>`_ and the corresponding
  `Slides from OSMC 2014 <http://www.netways.de/fileadmin/events/OSMC2014/Slides_2014/Network_Discovery_Update_-_Remo_Rickli.pdf>`_.
* Outdated page on `SourceForge <http://nedi.sourceforge.net/about.html>`_.
* `NeDi user forum <http://forum.nedi.ch/>`_.

NeDi installation
=================

For security reasons it is strongly recommended to configure the NeDi_ server with a non-public IP-address, 
primarily to avoid making the web server a target of attack from the Internet.
It may even be advisable to put this server on an internal management subnet/VLAN where normal users are prohibited from access (at least to the web server ports 80+443).
Alternatively, configure the server's firewall rules so that only specific clients can access the web server ports.

On the dedicated server for NeDi_ download the NeDi_ tar-ball file ``nedi-XXX.tgz`` from the `NeDi download <http://www.nedi.ch/download/>`_ page.
Paying customers may download the latest version (currently 2.0) from the NeDi_customer_ page.

.. _NeDi_customer: https://www.nedi.ch/customer-area/

See also the general NeDi_installation_ page.

NeDi installation and upgrading on CentOS and RHEL Linux
--------------------------------------------------------

To keep this page more general, the installation as well as upgrading of NeDi_ on CentOS 6/7 and RHEL 6/7 Linux is documented in a separate page:

* :ref:`NeDi_installation_on_CentOS`.

See also the general NeDi_installation_ page.

Initial configuration of NeDi
=============================

This section explains how to get started initially with setting up your NeDi_ installation.

Start using the NeDi GUI
------------------------

Navigation of the NeDi_ GUI is explained in the page http://www.nedi.ch/documentation/the-gui/.

NeDi web page login and password
................................

Go the the NeDi_ server web page (https://nedi.example.com in the above example) and log in as user *admin* with password *admin*.

**Change the admin password immediately:** 

* When logged in, go to the *User->Profile* page (/User-Profile.php) for the *admin* user.
* In the *Status/Password* "padlock" fields type in old and new passwords and press the *Update* button.

User profiles
.............

You should update the *User->Profile* page for the *admin* user, and for any other user which you choose to create, for at least these fields:

* E-mail address for receiving E-mails from NeDi.
* SMS text message telephone number (if you want to set up an SMS gateway later).
* Time zone.

New user accounts are created in the *User->Management* window.
Here you can also assign access rights to the users.
The default user password is the same as the username.

The new user should log in and change the password immediately.

The user should be given permissions in NeDi_ by clicking one or more icons under the **Group** column.
The **Monitor** icon allows the user to monitor the network.

Network Discovery with NeDi
---------------------------

Network discovery by means of SNMP_ is documented in NeDi_documentation_.
However, NeDi_ first needs a little configuration.

.. _SNMP: http://en.wikipedia.org/wiki/Simple_Network_Management_Protocol

Configuration of nedi.conf
..........................

The NeDi_ main configuration file ``/etc/nedi.conf`` should first be configured:

* Set SNMP public and private communities::

    comm public
    comm <secret read-write SNMPv2 community>

  The *public* is the default SNMP read-only community name, but you may want use a different read-only community in your devices and in NeDi_

* Only discover devices where ip address matches this regular expression::

    netfilter ^192\.168\.0|^172\.16

* Address where notification emails are sent from::

    mailfrom nedi@example.com

* Add IP addresses, IP ranges or host names to the file ``/var/nedi/seedlist``, for example::

    10.13.6.2-64           public
    myserver.example.com   public
    myprinter.example.com  public

  The 2nd column (*public*) is the default SNMP read-only community name, but you may want use a different read-only community in your devices and in NeDi_

* All graphs are generated using RRDtool_.
  In NeDi_ 1.5 some *new* features available only in RRDtool_ 1.4 and higher are by default configured::

    rrdcmd rrdtool new

  If you have RRDtool_ 1.3 or older you must remove the *new* keyword.

.. _RRDtool: http://oss.oetiker.ch/rrdtool/

Running initial device discovery
................................

Read the NeDi_documentation_ page section *The First Time*.
Several options define how your network should be discovered:

* **-p** Use dynamic discovery protocols like CDP_ or LLDP_.
* **-o** Search ARP_ entries for network equipment vendors matched by *ouidev* in ``nedi.conf``.
* **-r** Use route table entries of OSI_model_ Layer 3 devices.

.. _CDP: http://en.wikipedia.org/wiki/Cisco_Discovery_Protocol
.. _LLDP: http://en.wikipedia.org/wiki/Link_Layer_Discovery_Protocol

A run without any options will result in a plain static discovery using the ``seedlist`` file, or the default gateway (router) if you haven’t added any ``seedlist`` file entries yet.
First use the CLI and the *-v* option to closely follow the discovery.

Please note that **-o** requires that you define the ``ouidev`` parameter in ``nedi.conf``.
It seems that this option is only useful if you want to *restrict* device discovery to certain vendors while avoiding, for example, Cisco devices.

Run static discovery (verbose: *-v*) as the *nedi* user::

  su - nedi
  ./nedi.pl -v

When you are satisfied with the result, you may perhaps want to try dynamic discovery::

  ./nedi.pl -v -p

SNMP test with snmpwalk
-----------------------

The ``snmpwalk`` command is installed by::

  yum install net-snmp-utils

For command options see *man snmpcmd*.

To test that you can read a switch using SNMP_ use, for example, this command::

  snmpwalk -Os -c <community-string> -v <protocol-version> <device-address> system

For example, on a Linux host test the localhost::

  snmpwalk -Os -c public -v 2c localhost system

For a remote system *b307-XXX*::

  snmpwalk -Os -c public -v 2c b307-XXX system

Generate device definitions for unknown devices
-----------------------------------------------

This part is really optional: 
Some switch devices may show up as grey icons (for example |grey|)in the *Devices-List.php* (Devices->List menu) because they are unknown to NeDi_
The solution to this problem has been described in a Defgen_Tutorial_ video.

.. |grey| image:: attachments/csan.png

To configure NeDi_ device definitions for an unknown device:

1. Click on the grey device icon |grey| to go to the *Devices-Status.php* page.

2. In the *Summary* pane, click on the *Edit Def File* icon |geom| to go to the *Other-Defgen.php* page.

3. View the Defgen_Tutorial_ video Chapter 1 (for a chassis switch go to Chapter 2 at about 19:15 min.).

4. In the *Main* pane look at the **SysObjId** field, below it are "similar" device definitions indicated by |geom| icons.
   Click on one of the closest values to the **SysObjId** field to load its values into the page, and then follow the Defgen_Tutorial_ video.

5. When the page has been completed, click on the **Write** button to write the device definition file to the server's disk.

6. Then click on the *Discovery* icon |radr| to make NeDi_ rediscover the device in question.

After the next scheduled NeDi_ network discovery has been run, all switches of this type should appear correctly in the *Devices->List*.

.. _Defgen_Tutorial: http://youtu.be/bunFHB-RoUQ
.. |geom| image:: attachments/geom.png
.. |radr| image:: attachments/radr.png

Contribute device definitions to NeDi
.....................................

As a courtesy to the NeDi_ community, when you have created and tested device definitions for a hitherto unknown device,
please contribute the definition file by E-mail:

* In the *Other-Defgen.php* page which you used before, click on the mail icon |mail| to E-mail the definitions to def@nedi.ch.

.. |mail| image:: attachments/mail.png

Switch configuration backup
---------------------------

Switch configurations can be backed up from the GUI or the CLI.
Configurations will be stored in directories under ``/var/nedi/config/``.

Using the GUI *Devices->List*, click on a given device to go to its *Devices-Status.php* page.
In the *Summary* pane find the *Configuration* line to view the backup status.
To make a new backup click on the *Configuration Backup* icon |radr|.

If using the CLI as user *nedi* the backup command learned from the GUI is::

  /var/nedi/nedi.pl -v -B0 -SWOAjedibatflowg -a <device-IP>

Using NeDi
==========

This section explains how to perform some common tasks.
Help information for each page is in the *Help* icon |Help|.

.. |Help| image:: attachments/ring.png

Locating a MAC address
----------------------

A common and important task is to locate the switch device and port which a particular node MAC address is connected to:

* Go to the *Nodes->Status* page.

* Enter the node MAC address and press *Show*.

After a few seconds the requested switch port information for this MAC is displayed.

Monitoring specific devices in Devices-List
-------------------------------------------

If you want NeDi_ to generate notification events or alerts for certain devices in the *Devices-List* use this procedure:

1. In *Devices-List* select a set of devices using the upper left selector, for example, *Device Type ~ 2530*.
   The press the *Show* button to display your list.

2. Verify the device list, and if it's OK press the *Monitor* button.
   Now NeDi_ will begin to monitor events from these devices.

3. To configure any desired actions on events, go to the *Monitoring-Setup* page.

4. In the *Monitoring-Setup* pane labelled *Filter* select once more the same devices as in 1., for example, *Device Type ~ 2530*.

5. In the *Monitor* pane select the type of test you want to perform for the selected devices.
   For example, replace *Test->* by *ping*.
   Then select the kind of alert desired, for example, replace *Alert->* by *Mail* in order to send E-mails to the logged-in user.

6. In the *Events* pane *Forward* field, select the minimum event level desired for alerts to be sent, for example, replace *Level* by *Warning*.

7. Press the *Update* button to confirm your changes.

Some hints:

* For network switches, it is better to use *Test->uptime* in item 5. above, so that you will be alerted when switches are rebooted.

* In order for E-mails to be sent to you, your E-mail address **must** be defined in the *User-Profile* page.

* *Monitoring Test* alerts can be generated from the *nedi* user's CLI (NeDi_ version 1.4 and above)::

    ./moni.pl -vc200 

Discovery Notifications "no working user"
-----------------------------------------

Some of your monitored devices may not permit CLI user logins with SSH/telnet (for example, you may not know the password).
This may cause *Discovery Notifications* E-mails complaining about inability to access the device CLI::
  
  <device-name>  CLI Bridge Fwd error: no working user
  <device-name>  Config backup error: no working user

There doesn't seem to be any simple way to configure *do not log in to this device*.
In stead you must modify the device discovery options for the device:

1. In the *Monitoring-Setup* page select the device.

2. In the column *Events* there is an icon |radr| called *notify* (when you hover the mouse over it).
   Here you enter the following device discovery options::

     adefijlmnopstw

   and press the *Update* button.
   Verify that the device *Discover* column now contain your new options.

.. |abc| image:: attachments/abc.png

These options explicitly omit the letters ``b`` (backup) and ``c`` (CLI).
The default values are defined in ``nedi.conf`` in the *Messaging & Monitoring* option ``notify``.
Hopefully this should eliminate the above CLI warnings.

Adjusting alert thresholds
--------------------------

In the *Monitoring-Setup*  (NeDi_ 1.6 and older) or *Devices-List* (NeDi_ 1.7 and newer) page you can adjust various alert **Threshold** values.

Click on the *Edit threshold* icon |file| field in the top pane next to the *Show* button:

* CPU, 
* Temperature,
* ARP_poison_ (ARP entries per IP to detect poisoning on routers),
* Memory,
* PoE_ (Power over Ethernet),
* Supply

NeDi_ 1.9 has a new feature for *Digital Optical Monitoring* in nedi.conf::

  dom-alert       default 3       -10     3       -12     default-settings

Lines can be added for specific devices with different alert thresholds.

.. _ARP_poison: http://hakipedia.com/index.php/ARP_Poisoning
.. _PoE: http://en.wikipedia.org/wiki/Power_over_Ethernet

Latency Warning alerts
......................

The default network *Latency Warning* alert is set at 100 milliseconds in *nedi.conf*::

  latency-warn  100

Unfortunately, you can't change the latency value for already discovered devices in *nedi.conf*.

The solution to this problem is rather cryptic:

1. You must go to the *Monitoring-Setup* page and select which devices to modify.
2. In the *Monitor* heading in the top pane there is a field with no icon next to it:
   If you hover the mouse over this field, a text **Latency Warning [ms]** is shown.
3. Click on the field's up-arrow selector to increase the value.
   Then click on the *Update* button.

Now you should see the new *Latency Warning* value in the device column under the *Statistics* heading.


Printer supply alerts
.....................

NeDi_ reads the printer supply levels (toner etc.) by SNMP from any printer devices monitored.
If any supply level is below the notification limit (default value: 5%), an alert will appear in the *Discovery Notifications* E-mail sent by NeDi_

To remove these often superfluous notifications go to the *Monitoring-Setup* (1.6) or *Devices-List* (1.7 or newer) page and select the desired printers.
Then edit the *Supply Alert* threshold icon |file| field to insert a value of 0, then press the *Update* button.

.. |file| image:: attachments/file.png

Discarding "Node changed IP and name" events
--------------------------------------------

If your network has nodes (servers) with multiple IP addresses assigned to a single network interface, NeDi_ will report (in *Monitoring-Events*) in every discovery cycle events similar to this::

  Node <MAC> changed IP to <IP> and name <DNS>

where MAC, IP and DNS will be specific to the nodes in question.

This is just annoying "noise" which we would like NeDi_ to discard, because it's perfectly normal.
One usage scenario will be multiple tagged VLANs on an interface.

You can force NeDi_ to discard all such events in the *Monitoring-Setup* page:

1. Select all relevant switch devices.

2. In the *Events* column *Syslog, Trap, Discover* |bell| icon.

3. Select *Discard* and *Level=Notice*.

4. In the *Filter* |abc| field enter the text::

     changed IP to

5. Press the *update* button.

.. |bell| image:: attachments/bell.png

The new filter will be shown in the *Events Action* column.

Notification: did not receive any traffic did not send any traffic
------------------------------------------------------------------

We have seen some cases where NeDi_ discovery sends E-mail notifications similar to::

  1) switchA	Port LLDP:switchB,port   did not receive any traffic did not send any traffic

If this doesn't cease, it's actually a problem on one or both switches.
The switch port counters have stopped incrementing while traffic is flowing.
One can log in to both affected switches and display real-time port counters to determine which switch is at fault.

**Solution:** Reboot the switch with broken port counters.

Monitoring specific devices in Nodes-List
-----------------------------------------

NeDi_ can also generate notification events or alerts for nodes in the *Nodes-List*, in addition to devices in the *Devices-List*.

Example nodes could be:

* Switches/routers which do not have or do not permit SNMP *Get* operations.
* Printers without SNMP.
* Servers without SNMP.
* Other devices such as PCs, cameras or whatever.

Use this procedure:

1. In *Nodes-List* make a search to uniquely list the node, for example, by its IP address.

2. Verify the node list, and if it's OK press the *Monitor* button.

3. Follow steps 3-7 in the above *Devices-List* procedure.

Geographical visualization of device locations
----------------------------------------------

From the NeDi_about_ page:

* NeDi_ is capable of visualizing your network down to rack level! 

In order to do that, NeDi_ needs a certain format in the SNMP *Location* string as defined in the device's SNMP configuration.
The format used by NeDi_ is::

  Region;City;Building;Floor;[Room;][Rack;][Rack Unit position;][Height in RUs]

(The separator character *;* can be modified in *nedi.conf* with *locsep*).

The building or street address can consist of several sub-buildings with a 2nd level separator (e.g. _). 
Example::

  Switzerland;Zurich;Main Station_A;5;DC;Rack 17;7

The resulting device location maps can be viewed in multiple pages:

* The *Topology-Map* page: Click on your *Region* name, then explore the map down in the *City* and *Building* levels.

* The *Topology-Table* and *Monitoring-Health* pages: Your *Buildings* will be shown, then explore the *Floors* and *Rooms* down to the device level. Location errors will also be shown.

In the room view displaying racks, the default number of rack columns is 8.
This may be too wide for your browser, so adjust the number of rack columns in your *User-Profile* page in the field |icon| *# Columns (0-31)*.
A number of 5 columns may be suitable.

.. |icon| image:: attachments/icon.png

There is an instructive Topology_Showcase_ video, which also describes the use of *maplo* and *nam2loc* in *nedi.conf*.

.. _Topology_Showcase: https://www.youtube.com/watch?v=19xBi_sQtNc&feature=youtu.be

Changing a device SNMP community name
-------------------------------------

If you decide to change a device SNMP community name, for example, the default SNMP read-only *public* community, the NeDi_ database must be updated manually,
since it doesn't help to reconfigure the ``nedi.conf`` or ``seedlist`` files with the new community name - updating this information seems to be ignored.

You have to run this command for each IP-address whose SNMP community name gets updated::

  nedi.pl -a <IP-address> -C <new-community-name> -SAFGgadobewitjumpv


Reports and traffic loads
=========================

Network utilization reports
---------------------------

To get an overview of the utilization of your subnets, either in terms of number of nodes, or in terms of which IP-addresses are in use,
go to the *Reports->Networks* page.

Select either **Network Distribution** or **Network Utilization** and click the *Show* button.

Network maps including traffic load
-----------------------------------

Go to the *Topology-Map* page:

1. In the *Filter* pane select the locations and/or devices you want to display.
2. In the *Main* pane select:

   * *Size&Format*: select type *png* and the image size you want.
   * *Map Type* |abc|: select *Devices* and *flat* 

3. In the *Layout* pane select the *Connection Information* type you want displayed, for example:

   * *Bandwidth* displays link bandwidth.
   * *Link Load* displays link load in percent.
   * *Traffic: Small* displays small load graphs for the past week.

4. In the *Show* pane you can add device IP address, location, etc.

Finally press the **Show** button to generate the network map image.

Interface reports (traffic load)
--------------------------------

To monitor the network traffic load of devices, use the *Devices-Interfaces* page:

1. In the *Interface-List* pane select the *Device Name* you want to monitor.

2. In the scrollable list of columns, select all the columns you want, for example: *Total traffic Inb, Total traffic out, Last traffic Inb, Last traffic out, Last Broadcasts Inb, IF graphs*.

3. In the *Limit* icon |form| pull-down list, select the maximum number of interfaces to display.

4. Click the *Show* button.

.. |form| image:: attachments/form.png

In each column heading there is a triangle/arrow icon: Click the triangle to sort the columns in ascending/descending values.

Node reports (traffic load)
---------------------------

To monitor the network traffic load of nodes (for example, to find nodes that generate too much traffic), use the *Nodes-List* page:

1. In the scrollable list of columns, select all the columns you want, for example: *Total traffic Inb, Total traffic out, Last traffic Inb, Last traffic out, Last Broadcasts Inb, IF graphs*.

2. In the *Limit* icon |form| pull-down list, select the maximum number of interfaces to display.

3. Click the *Show* button: The **node names** and **IP addresses** connected to each switch interface is shown.

In each column heading there is a triangle/arrow icon: Click the triangle to sort the columns in ascending/descending values.

If you want to restrict the node list to a specific switch:

* In the *Nodes-List* pane select the *Device Name* you want to monitor.

Mapping MAC address to IP address
=================================

Network switches at OSI_model_ Layer 2 operate only on the Ethernet MAC_address_ and are in principle ignorant about the IP_address_ of nodes on the network.
Then how may NeDi_ learn about the IP_address_ of nodes on the network by speaking only to network devices?

.. _MAC_address: http://en.wikipedia.org/wiki/MAC_address
.. _IP_address: http://en.wikipedia.org/wiki/IP_address
.. _OSI_model: http://en.wikipedia.org/wiki/OSI_model
.. _ARP: http://en.wikipedia.org/wiki/Address_Resolution_Protocol
.. _Router: http://en.wikipedia.org/wiki/Router_%28computing%29
.. _SNMP: http://en.wikipedia.org/wiki/Simple_Network_Management_Protocol

Each computer maintains its own table of the mapping from Layer 3 addresses (e.g. IP_address_) to Layer 2 addresses (e.g. Ethernet MAC_address_).
This is called the **ARP cache**.
Your network Router_ works at the Layer 3 IP_address_ level and forwards packets between local and remote networks, 
hence it must have ARP_ cache information about all its network interfaces.

NeDi_ will read the ARP_ cache information from your Router_ and all other SNMP_ capable devices in your network, 
and hence NeDi_ can build up a database of ARP_ cache information internally and present it to you.

In some cases your Router_ may not contain complete ARP_ cache information of each and every device, and you need to help NeDi_ with additional ARP_ cache data.
In this case you first want to run the arpwatch_ utility described below to accumulate an ARP_ cache database.

It is necessary to configure in ``nedi.conf``::

  arpwatch /var/lib/arpwatch/arp.dat*

Then execute this command::

  ./nedi.pl -N arpwatch

to make NeDi_ read in your arpwatch_ database.
Check the list of node IP and MAC addresses in the *Nodes-List* page.
If successful, you could run this command regularly (e.g., once per day) from *crontab*.

Note: If your NeDi_ version is too old (<= 1.5.038) then you must add the argument 0 to the *misc::ArpWatch()* call in ``nedi.pl`` at line 182::

          if($opt{'N'} =~ /^arpwatch/){
                &misc::ArpWatch(0);

Status of arpwatch
------------------

The arpwatch tool, while included in CentOS 7, CentOS 8 and Fedora, is no longer being maintained. 
Check https://en.wikipedia.org/wiki/Arpwatch

There is no *Systemd* script which will start arpwatch_ on multiple network interfaces.

Using arpwatch on CentOS 6
--------------------------

For a CentOS 6 Linux server to work with ARP_ caches, install the arpwatch_ package and its ``arpfetch`` script, as well as some tools in the arp-scan_ package::

  yum install arpwatch arp-scan
  cp -p /usr/share/doc/arpwatch-*/arpfetch /usr/local/bin/

.. _arpwatch: http://en.wikipedia.org/wiki/Arpwatch
.. _arp-scan: http://www.nta-monitor.com/wiki/index.php/Arp-scan_Documentation

Now you can inquire any SNMP device (in particular your Router_) about its ARP_ cache::

  arpfetch <IP-address> public

where *public* is just a default SNMP community name (you may be using a different community name).

Updating ethercodes.dat Ethernet vendor codes
.............................................

You may perhaps want to update the Ethernet vendor codes in ``/var/lib/arpwatch/ethercodes.dat`` (dated 2010) to a more recent version,
but unfortunately no up-to-date ``ethercodes.dat`` file seems to be available.

Update May 2015: Arpwatch ethercodes.dat have now become available from this site:

 * http://linuxnet.ca/ieee/oui/#arpwatch

Generating ethercodes.dat from IEEE OUI Data or Nmap MAC Prefixes
.................................................................

Updating ``ethercodes.dat`` is actually a little involved, since the official IEEE_OUI_ file has become somewhat inconsistent over the years.
In stead it is recommended to download from the `Sanitized IEEE OUI Data (oui.txt) <http://linuxnet.ca/ieee/oui/>`_ page.
Another possibility is to use the arp-scan_ tool ``get-oui`` (see ``man get-oui``)

.. _IEEE_OUI: http://standards.ieee.org/regauth/oui/oui.txt

The arpwatch_ requirement is similar to the `Nmap MAC Prefixes <http://linuxnet.ca/ieee/oui/nmap-mac-prefixes>`_ file,
so you can generate ``ethercodes.dat`` with these commands::

  wget --timestamping http://linuxnet.ca/ieee/oui/nmap-mac-prefixes
  awk '{ mac = substr($1,1,2) ":" substr($1,3,2) ":" substr($1,5,2); $1=""; printf("%s\t%s\n", mac, $0)}' < nmap-mac-prefixes > /var/lib/arpwatch/ethercodes.dat

For automated updating you can create this ``Makefile``::

  /var/lib/arpwatch/ethercodes.dat: nmap-mac-prefixes
          awk '{ mac = substr($$1,1,2) ":" substr($$1,3,2) ":" substr($$1,5,2); $$1=""; printf("%s\t%s\n", mac, $$0)}' < $< > $@
  nmap-mac-prefixes: FRC
          wget --timestamping http://linuxnet.ca/ieee/oui/nmap-mac-prefixes
  FRC:

and run ``make``.

Optional: There is also an official IEEE_IAB_ file (*Individual Address Blocks*).
Each block represents a total of 2^12 (4,096) Ethernet MAC addresses.
This file may be downloaded using the arp-scan_ tool ``get-iab`` (see ``man get-iab``).

.. _IEEE_IAB: http://standards.ieee.org/regauth/oui/iab.txt

The arpwatch daemon
...................

Note: This section is only valid on CentOS 6 / RHEL 6 systems.

Configure the file ``/etc/sysconfig/arpwatch``, changing the default recipient *root* to *-* in order to suppress E-mails::

  OPTIONS="-u arpwatch -e - -s 'root (Arpwatch)'"

Start the arpwatch_ daemon (also at boot time)::

  chkconfig arpwatch on
  service arpwatch start

ARP_ cache data will be collected in the files ``/var/lib/arpwatch/arp.dat*``,
and those files will be refreshed every 15 minutes by the arpwatch_ daemon (previous files are renamed with a "-" extension).

However, this only works if your server has a single default network interface, such as *eth0*.
If you have multiple network interfaces, you must modify the arpwatch_ init-script as described in
`arpwatch on multiple interfaces <http://sgros.blogspot.dk/2012/01/arpwatch-on-multiple-interfaces.html>`_.
Every network interface to be monitored requires a separate instance of the arpwatch_ daemon.
Download an improved `arpwatch init-script <http://www.zemris.fer.hr/~sgros/files/scripts/arpwatch>`_ to replace ``/etc/rc.d/init.d/arpwatch``.
For convenience we have attached a copy of the arpwatch-init__ file.

__ attachment: arpwatch-init

Add a new *INTERFACES* variable to ``/etc/sysconfig/arpwatch``, for example::

  INTERFACES="eth0 eth1" 

Now start the arpwatch_ service as above.

Configure NeDi_ in ``nedi.conf`` to read the ARP_ cache data::

 arpwatch        /var/lib/arpwatch/arp.dat*

arpwatch bugs
.............

The arpwatch_ code is dated around 2006, see the `LBL homepage <http://ee.lbl.gov/>`_, and therefore has a number of bugs that get fixed by various Linux distributions.
One annoying bug is that the arpwatch_ daemon will report all DHCP lease renewals in the syslog similar to::

  arpwatch: changed ethernet address 0.0.0.0 0:14:5e:55:70:25 (0:14:5e:55:c2:6a)

See `this report <http://www.clearfoundation.com/component/option,com_kunena/Itemid,232/catid,28/func,view/id,58948/>`_.

To remove this bug the following patch in the arpwatch_ code ``db.c`` added at line 95 seems to do the trick::

  /* Ignore 0.0.0.0 ip address */
  if (a == 0) return (1);

The db.c_patch__ file is attached.

__ attachment:db.c_patch

Hopefully this patch may be accepted by distributions.
See also the `Debian bug list for arpwatch <https://bugs.debian.org/cgi-bin/pkgreport.cgi?pkg=arpwatch>`_.

To patch and rebuild the CentOS .src RPM package::

  rpm -i arpwatch-2.1*.el6.src.rpm
  (to do)
  

Kernel ARP cache
----------------

If the number of network devices (cluster nodes plus switches etc.) approaches or exceeds 512, 
you must consider the Linux kernel's limited dynamic ARP_ cache size. 
Please read the man-page *man 7 arp* about the kernel's ARP_ cache.
Documentation on the net:

* `Linux arp cache timeout values <http://serverfault.com/questions/551688/linux-arp-cache-timeout-values>`_
* `Linux System Tuning Recommendations 
  <https://www.ibm.com/developerworks/community/wikis/home?lang=en#!/wiki/Welcome%20to%20High%20Performance%20Computing%20%28HPC%29%20Central/page/Linux%20System%20Tuning%20Recommendations>`_.
 
If the soft maximum number of entries to keep in the ARP_ cache, *gc_thresh2=512*, is exceeded, 
the kernel will try to remove ARP_ cache entries by a garbage collection process. 
This is going to hit you in terms of sporadic loss of connectivitiy between pairs of nodes. 
No garbage collection will take place if the ARP_ cache has fewer than *gc_thresh1=128* entries, 
so you should be safe if your network is smaller than this number.

The best solution to this ARP_ cache trashing problem is to increase the kernel's ARP_ cache garbage collection (gc) 
parameters by adding these lines to ``/etc/sysctl.conf``::

  # Don't allow the arp table to become bigger than this
  net.ipv4.neigh.default.gc_thresh3 = 8192
  # Tell the gc when to become aggressive with arp table cleaning.
  # Adjust this based on size of the LAN.
  net.ipv4.neigh.default.gc_thresh2 = 4096
  # Adjust where the gc will leave arp table alone
  net.ipv4.neigh.default.gc_thresh1 = 2048
  # Adjust to arp table gc to clean-up more often
  net.ipv4.neigh.default.gc_interval = 2000000
  # ARP cache entry timeout
  net.ipv4.neigh.default.gc_stale_time = 2000000

Please change the numbers according to your network size:
The value of *gc_thresh1* should be greater than the total number of nodes in your network,
and the other values *gc_thresh2* and *gc_thresh3* should be 2 and 4 times *gc_thresh1*.
The values of *gc_interval* and *gc_stale_time* (in seconds) should be large enough to retain ARP cache data for a useful period of time (several weeks).

Then run ``/sbin/sysctl -p`` to reread this configuration file.

Receiving SNMP traps
====================

Devices can be configured to send SNMP_traps_ to one or more SNMP servers whenever events occur.
An SNMP_ server can be configured to receive and process such traps, see the tutorial TUT:Configuring_snmptrapd_.

.. _TUT:Configuring_snmptrapd: http://www.net-snmp.org/wiki/index.php/TUT:Configuring_snmptrapd

.. _SNMP_traps: http://en.wikipedia.org/wiki/Simple_Network_Management_Protocol#Trap

The NeDi_ SNMP_ trap handler is ``/var/nedi/trap.pl``.
Configure it as follows:

* Put this in ``/etc/snmp/snmptrapd.conf`` for NeDi_ to receive traps for the *public* community::

    authCommunity   log,execute,net public
    traphandle      default   /var/nedi/trap.pl
    # Do not write traps to syslog (will be handled by NeDi trap.pl)
    doNotLogTraps yes

* Change the daemon options in file ``/etc/sysconfig/snmptrapd`` so that only critical (and higher) traps are logged::

    OPTIONS="-Ls2d -p /var/run/snmptrapd.pid"

  See *man snmpcmd* section *LOGGING OPTIONS*.

* Alternatively, *snmptrapd* may log to a separate syslog file by::

    OPTIONS="-Lf /var/log/snmptrapd.log -p /var/run/snmptrapd.pid"

  You must create this logfile and set its SELinux context::

    touch /var/log/snmptrapd.log
    chcon --reference=/var/log/messages /var/log/snmptrapd.log

* Start the service::

    chkconfig snmptrapd on
    service snmptrapd start

Incoming SNMP_traps_ will be added to *Monitoring-Events*.

Upon receiving a trap, the script will check whether a device with the source IP is a device monitored by NeDi_ 
The default event level will be set to 50 if the device is in NeDi_ otherwise it is set to the low value of 10.

Firewall configuration allowing SNMP traps to be received on port 162 must be configured in ``/etc/sysconfig/iptables``::

  -A INPUT -m state --state NEW -m tcp -p tcp --dport 162 -j ACCEPT
  -A INPUT -m state --state NEW -m udp -p udp --dport 162 -j ACCEPT

and the *iptables* service restarted.

Customizing trap.pl for SNMP trap alerts
----------------------------------------

Please note this comment by the author in ``trap.pl``::

  The script conaints some basic mappings to further raise authentication and configuration related events.
  Look at the source, if you want to add more mappings. Trap handling has not been further pursued in favour of syslog messages.

Here are some simple customizations of ``trap.pl`` which you may find useful:

* Use *level=0* to ignore selected events::

        if($info =~ s/IF-MIB::ifIndex/Ifchange/){
                # We want to ignore interface up/down events
                $level = 0;     
        ...
        if ($level > 0) {       # $level == 0 means: ignore this event
                my $mq = &mon::Event(1,$level,'trap',$tgt,$tgt,"$info","$info");
                &mon::AlertFlush("NeDi Trap Forward for $tgt",$mq);
        }

Test the trap functionality by sending a test trap, see the SNMP_ tutorial `TUT:snmptrap <http://www.net-snmp.org/wiki/index.php/TUT:snmptrap>`_::

  snmptrap -v 1 -c public <nedi-server> '1.2.3.4.5.6' '192.193.194.195' 6 99 '55' 1.11.12.13.14.15  s "teststring"

Configuring devices to send SNMP traps
--------------------------------------

Devices must be configured explicitly to send SNMP_traps_ to SNMP_ servers.
In these examples we use the default community *public*, but you may be using a different community name.

The syntax for HP *ProCurve* switches may be::

  snmp-server host <IP-of-server> community "public" trap-level not-info
  snmp-server host <IP-of-server> "public" not-info              # Used on some older ProCurve models
  snmp-server host <IP-of-server> "public" critical              # To avoid login/logout traps being sent

HP H3C/3Com switches may use this syntax::

  snmp-agent target-host trap address udp-domain <IP-of-server> params securityname public

NeDi maintenance
================

Database maintenance
--------------------

The NeDi_ database is continually filled with events and other data.
After some time it may be a good idea to clean up the database by deleting old events etc.

In the NeDi_ GUI's page *System->Database* under the *Execute* item there is a pull-down menu containing several::

  Delete Events Age > 30 days
  Delete iftrack Age > 30 days
  Delete iptrack Age > 30 days
  Delete chat Age > 30 days

Click the *Execute* item, select the desired action, and click the **Execute** button at the right.

The value 30 is defined in nedi.conf as::

  # Remove nodes (force IP, DNS and IF update) if inactive longer than this many days
  retire          30

There is also a database maintenance script in the nedi user's ``contrib`` directory::

  nedi_db_maintenance.sh
