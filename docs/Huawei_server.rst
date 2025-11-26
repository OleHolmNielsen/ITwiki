.. _Huawei_server:

===================
Huawei server setup
===================

.. Contents::

This page contains information for selected Huawei servers: XH620_ and RH2288H_.

Documentation and software
==========================

XH620 V3 server
---------------

* XH620_ product information.From
* XH620_Documentation_.
* XH620_Downloads_.
* iBMC_ management processor.

.. _XH620_Documentation: http://support.huawei.com/enterprise/productNewOffering?idAbsPath=7919749|9856522|21782478|21149952|21456501&pid=21456501&tab=doc&docType=DOCTYPE0&productname=XH620%20V3
.. _XH620_Downloads: http://support.huawei.com/enterprise/en/server/xh620-v3-pid-21456501/software
.. _XH620: http://e.huawei.com/en/products/cloud-computing-dc/servers/x-series/xh620-v3

RH2288H V3 server
-----------------

* RH2288H_User_Guide_.
* RH2288H_Software_downloads_ are at the bottom of the RH2288H_ page *Technical Support* section.
  The latest software (topmost on the list) *Version and Patch Number* should be used.
  The software includes drivers for supported OSes, and BIOS and iBMC_ firmware updates.

.. _RH2288H: http://e.huawei.com/en/products/cloud-computing-dc/servers/rh-series/rh2288h-v3
.. _RH2288H_User_Guide: http://support.huawei.com/enterprise/docinforeader.action?contentId=DOC1000054727&partNo=10072
.. _RH2288H_Software_downloads: http://support.huawei.com/enterprise/productNewOffering?tab=software&pid=9901881&lang=en

X6800 chassis
-------------

* FusionServer X6800_ Data Center Server.
* X6800_White_paper_.
* X6800_Documentation_.
* X6800_Software_ downloads.

Rack cabinet requirements from the X6800_White_paper_:

* The depth of an X6800 chassis is 898 mm, and therefore the cabinet depth must be no less than 1200 mm.

.. _X6800: http://e.huawei.com/en/products/cloud-computing-dc/servers/x-series/x6800
.. _X6800_Documentation: http://support.huawei.com/enterprise/en/server/x6800-pid-21149487/
.. _X6800_Software: http://support.huawei.com/enterprise/en/server/x6800-pid-21149487/software/
.. _X6800_White_paper: http://e.huawei.com/en/marketing-material/onLineView?MaterialID={FA9AF2F4-FB8A-4157-95B5-4B4AD20A6157}

SUMMARY: How to manage a Huawei server
======================================

This is a summary of the steps required to configure a factory default Huawei server so that it becomes manageable. 

The most important steps are to reconfigure the BIOS and the iBMC_ management processor.
The sections below provide full details.

Assumptions:

* Your server as well as management networks use a DHCP_ server to manage IP addresses.

The following steps must be taken in numerical order:

1. Attach a console screen and keyboard and boot the server into BIOS Setup mode (press DEL).

2. Remove the useless BIOS setup (supervisor) password installed by Huawei.

3. Read the server's port 1 Ethernet MAC address.

4. Go into the iBMC_ Configuration menu and read the iBMC_ Ethernet MAC address.

   -  Configure the iBMC_ Ethernet for DHCP_ IP address assignment (a static IP address is the factory default).

   - For a X6800_ chassis only: Configure the *Aggregation* chassis management Ethernet port.

5. In BIOS Setup press F10 to save the changes and exit to reset the server.

6. Connect Ethernet cables to the server port 1 and the iBMC_ *Mgmt* ports.

   - For a X6800_ chassis only: Connect an Ethernet cable to the chassis management *Aggregation* Ethernet port in stead of the server's *Mgmt* port.

7. Configure your network's DHCP_ server with the MAC addresses learned in steps 3 and 4.

   - Make sure that the iBMC_ responds to network ping_ packets.

8. Use the Huawei *uMate* tool (from the FusionServer_tools_ web page) to reconfigure BIOS settings as required (*uMate* works through the iBMC_).

   - It is a good idea to update also the BIOS and iBMC_ firmware.

   - Note: The *uMate* is unable to set **all** required BIOS parameters, so some parameters may have to be set manually in the BIOS Setup.

9. Reboot the server and perform a PXE_ network installation of operating system.

.. _DHCP: https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol
.. _ping: https://en.wikipedia.org/wiki/Ping_%28networking_utility%29
.. _PXE: https://en.wikipedia.org/wiki/Preboot_Execution_Environment

Booting and BIOS configuration
==============================

A boot menu will be presented:

* F5 to select keyboard: Only US English and French are available!
* DEL to enter BIOS setup
* F11 to Boot Manager
* F12 to PXE boot

The server like RH2288H will first spend some time configuring storage connected to the LSI MegaRAID_ controller, then proceed with the booting.

.. _MegaRAID: http://www.avagotech.com/products/server-storage/raid-controllers/

BIOS keyboard layout
--------------------

Using F5 at startup, the BIOS can configured to accept one of the following national keyboard layouts: 

* US English, French.

In order to enter the BIOS setup initially, you have to type the default password: Huawei12#$

However, this won't work with many national keyboards because the characters # and $ will be placed on different keys.

The trick for national keyboards is to type this default password as:

* Huawei12(shift)3(shift)4

For newer servers such as XH321 V5 the Administrator password is: Admin@9000 

The trick for national keyboards is to type this default password with (shift)2 for "@" as:

* Admin(shift)2(un-shift)9000

Since BIOS thinks the keyboard uses a US layout, this will work correctly.

Configure BIOS settings
-----------------------

Press DELETE to enter the BIOS setup.
The (silly) Huawei password **Huawei12#$** is required to enter BIOS setup!
Press F9 to set defaults, F10 to Save and Exit.

Consider changing the defaults:

* Go to the **Security** submenu and select **Clear supervisor password** (see below).

* Go to the **Boot** submenu and select appropriate boot devices, for example:

  * **Boot Type** = **Legacy Boot Type**.

  * Go to the **Boot Type Order** submenu and select appropriate boot order:

    * **PXE, CD, Hard Disk** (use F5/F6 to move down/up).

* Go to the **Advanced** submenu:

  * In **Intel RC Group**:

    * Go to **Advanced Power Management Configuration** and set **Power Policy Select** to **Performance** for HPC computing.
      **Notice:** Setting this will (unexpectedly) reset other unrelated parameters such as Hyper-Threading!
    * Go to *Processor Configuration*.  Set **Hyper-Threading** to **Disabled** for HPC computing.

  * Go to **PXE configuration** to write down the on-board **Ethernet MAC address**.
    Also verify the PXE enabled/disabled settings.
    Note: On the XH620_ V3 server, the Ethernet MAC address seems to be defined by the small mini-board containing the LAN ports at the server's front.

  * Go to **IPMI iBMC configuration** to update the iBMC_ management controller configuration:

    * Write down the **iBMC Ethernet MAC address**.
    * Set **Restore on AC Power Loss** to **Last state**.
    * Verify the *Set iBMC services* which actually means the SSH_ login service (enabled by default).
    * In **iBMC Configuration** configure:

      - The iBMC_ network port **iBMC&NCSI Select** is set to *Dedicated* by default.  Select the appropriate value for your installation:

        - **Dedicated**: Use the server's front port.
        - **Aggregation**: Use the X6800 chassis consolidated management port (cannot be selected with *Auto*).
        - **Shared-LOM**: Share the server's Ethernet port.
        - **Auto**: If you select this option, the iBMC automatically selects a network port as the iBMC management network port based on the connection status of optional network ports.
          You need to specify optional network ports by selecting check boxes.
          If multiple network ports are connected, the iBMC selects a network port as the iBMC management network port based on the following priority: dedicated network port > LOM network port > PCIe extern port.
          The aggregation network port cannot be automatically selected.

      - You *may* change the **iBMC password**. (**Note:** special characters will be used - remember that BIOS uses US keyboard layout!)
      - Set the IPv4/IPv6 *IP Source* configuration for **DHCP**.

  * In *Misc configuration* you should set **Wake on LAN** to **enabled**.

.. _iBMC: http://e.huawei.com/en/products/cloud-computing-dc/servers/accessories/ibmc
.. _SSH: https://en.wikipedia.org/wiki/Secure_Shell

Missing BIOS configuration items
................................

The following desired BIOS settings are unavailable (as of BIOS V350):

* Keyboard NUMLOCK = Enabled/Disabled

* There does not seem to be any way to display the iBMC_ Event Log within the BIOS setup.
  In stead you may use the iBMC_ GUI, or the command ``ipmitool sel elist`` in Linux.

BIOS settings for Intel OmniPath network adapter
................................................

If you install an Intel OmniPath network adapter, there is an Intel recommendation (BIOS dependent) to set the PCIe bus speed to **Gen2**,
see our `OmniPath page <https://wiki.fysik.dtu.dk/niflheim/OmniPath>`_.
The default BIOS setting may be that the PCIe speed is set to Auto (may vary with BIOS). 
For a PCIe Gen3 x16 adapter the PCIe bus speed should be 8 GT/s, whereas Gen2 speed would only be 5 GT/s. 
Please verify your adapter's speed.

In the Huawei BIOS configure this in the *Advanced->Intel RC Group->IIO Config -> IIO1*:

* Select the correct PCIe slot, it may be the Port3A x16 port.
* Set the link speed to **Auto**.

Optimized BIOS settings
.......................

Download the manual *Intel® Omni-Path Performance Tuning User Guide*.
See Chapter **2.0 BIOS Settings** about recommended settings, which are likely important for any type of network fabric.

For the Huawei server BIOS configuration please first perform the above standard configurations for HPC servers.
Then go to the **Advanced->Intel RC Group** and configure:

* **Advanced Power Management Configuration**:

  - EIST Support (Enhanced Intel SpeedStep_ Technology) = **Enabled**.
  - Turbo Mode = **Enabled**.
  - CPU C-State  = **Enabled**.
  - Processor C3 report = **Disabled**.
  - Processor C6 report = **Enabled**.

* **IIO Configuration**:

  - **IIO1 Configuration**:

    - All ports: Link Speed = **Auto**
    - All ports: PCI-E Port Max Payload Size = **Auto**
    - IOU Non-posted Prefetch = **Disabled** (available with BIOS V350 or later).

  - Intel VT for Directed I/O (VT-d) = **Disabled**.

* **QPI Configuration:**

  - Snoop Mode Select = **HomeSnoop+OSB** (improved memory bandwidth)

* **Memory Configuration:** Numa (NUMA_ Optimized) = **Enabled**.

.. _SpeedStep: https://en.wikipedia.org/wiki/SpeedStep
.. _NUMA: https://en.wikipedia.org/wiki/Non-uniform_memory_access

To save the settings and reboot:

* Press F10 **Save and Exit**.

BIOS password protection
------------------------

Many BIOS functions are password protected, making normal server operation quite cumbersome.
For example, PXE booting is only permitted after typing the BIOS password!

Huawei servers seem to have a factory default BIOS as well as iBMC_ password which is printed on a label on top of the chassis::

  Huawei12#$

which you can easily find by this `Google search <https://www.google.com/search?q=huawei+server+bios+default+password>`_ or with some effort look up in the system *User Guide*.
system
In the BIOS setup you should select *Clear supervisor password* in order to disable this annoying password.

UEFI Secure Boot configuration
----------------------------------

The UEFI_ Secure_Boot_ configuration can be set using the system console:

1. Reboot the system and press F11 *Boot Manager* during startup.

2. In the *Boot Manager* menu press the Esc_key_ to ignore the *EFI* device list,
   returning to a *Boot Manager* main menu with a list of items.

3. Here select the *Administer Secure Boot* item,
   which causes the system to restart into the *Administer Secure Boot* menu.

4. Important: If enabling Secure_Boot_ for the first time, 
   you must select the menu item *Restore Secure Boot to Factory Settings* 
   and select *Enabled* from the pull-down menu.

5. Press F10 *Save and exit* and the system will restart in Secure_Boot_ mode.

See also Huawei's 
`Setting UEFI Secure Boot <https://info.support.huawei.com/hedex/api/pages/EDOC1000053358/YEF0907R/25/resources/en-us_topic_0000001193429384.html>`_ page.

.. _UEFI: https://en.wikipedia.org/wiki/UEFI
.. _Secure_Boot: https://en.wikipedia.org/wiki/UEFI#Secure_Boot
.. _Esc_key: https://en.wikipedia.org/wiki/Esc_key

iBMC network configuration
--------------------------

Go to the XH620_Documentation_ page and find the document entitled *X6800 Server Node V100R003 iBMC User Guide*,
this contains the full iBMC_ documentation.

The server's factory default is for the iBMC_ to connect to the *Dedicated port* on the server cabinet (label: *Mgmt*).
You can connect a network cable to that port.

The factory default iBMC_ network uses a fixed IP address.
The factory default static IP address of each iBMC_ is 172.31.1.128 + slot-number, where slot-number=1..8.
The netmask is 255.255.255.0.

You may change the IP configuration to DHCP_, provided you have configured the iBMC_'s MAC-address in your DHCP_ server.
This is described above under BIOS configuration.
Alternatively, from the Linux OS you can configure the iBMC_ to use DHCP_::

  ipmitool lan set 1 ipsrc dhcp

If you want to use the X6800_ chassis consolidated management port (label: *Mgmt* on the chassis "ears"), you have to change the iBMC configuration.
This is described above under BIOS configuration.

Alternatively, connect a cable temporarily to the *Dedicated* port so that the iBMC_ connects to the network and uses DHCP_.
Now you can use SSH_ to login to the iBMC_ IP address as user *root* with the (silly) Huawei password.

Read the *iBMC User Guide* sections:

* Setting the Network Port Mode (netmode)
* Setting the active port (activeport)

Query the iBMC_ network port mode::

  iBMC:/->ipmcget -d ipinfo

Change the iBMC_ port configuration::

  ipmcset -d netmode -v 1
  ipmcset -d activeport -v 3 

If you have many nodes to configure, this is a very time-consuming process.
You can reconfigure many iBMC's using a script ibmc_consolidated_port.sh_,
it requires the command sshpass_ to be installed with this RPM::

  yum install sshpass

.. _ibmc_consolidated_port.sh: ftp://ftp.fysik.dtu.dk/pub/Huawei/ibmc_consolidated_port.sh
.. _sshpass: https://sourceforge.net/projects/sshpass/
.. _DHCP: https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol

iBMC security warning
---------------------

If the iBMC_ is connected to a network (see above), 
anyone with access to login using SSH_ or the web GUI (port 443) as the default user *root* and the default Huawei password can take over the iBMC_ controller and thereby control the server remotely!
This is documented in the system *User Guide* section *Accessing the CLI of the iBMC Management Software*.

It is strongly recommended to:

* Make sure the iBMC_ network is completely private with no possibility of any unauthorized access by SSH_.
* Change the default iBMC_ password (see above).

Obviously, Huawei ought to configure random iBMC_ passwords from the factory and print them on labels attached to the servers.

SSH login to iBMC
-----------------

The integrated management module (referred to as the **iMana**) is a control unit used to manage servers.
When the iBMC_ network interface has been configured correctly, it is possible to login to the iBMC_ CLI using SSH.

**Note:** If you have several SSH authentication key files ($HOME/.ssh/id_*) they will be tried in turn, and since the iBMC_ accepts a maximum of 3 login attempts,
SSH logins may fail with the error::

  Received disconnect from 10.x.x.x port 22:2: Too many authentication failures

Workaround: Specify only 1 of the keys to the SSH command, for example::

  ssh -i $HOME/.ssh/id_rsa <iBMC_hostname>

iBMC operation
==============

See the HUAWEI Server iMana_200_User_Guide_ which explains iBMC_ GUI and CLI operations.

.. _iMana_200_User_Guide: http://support.huawei.com/enterprise/docinforeader.action?contentId=DOC1000038843&partNo=10072

For example, iBMC_ and BIOS upgrades can be performed using the iBMC_ CLI interface via SSH login.
The guide instructions in *3.4.11 Upgrading the Software (upgrade)* are::

  iBMC:/->ipmcset -d upgrade -v /tmp/*.hpm [option]
  option: 0: Do not restart the iMana.
  You need to upload the upgrade files to the tmp directory on the target server over file transmit tool (just as SFTP), and then upgrade the iMana software in CLI mode.

Display the iBMC_ LAN configuration::

  iBMC:/->ipmcget -d ipinfo
  EthGroup ID           :  1
  Net Mode              :  Manual
  Net Type              :  Dedicated
  IPv4 Information      :
  IP Mode               :  dhcp
  IP Address            :  10.5.135.94
  Subnet Mask           :  255.255.0.0
  Default Gateway       :  scp
  MAC Address           :  20:3d:b2:20:bf:e5
  ...

Modify the LAN configuration to *Manual* and *Aggregated*::

  ipmcset -d netmode -v 1
  ipmcset -d activeport -v 3

where the modes are:

* 1: manual
* 2: adaptive

and the network ports are:

* 0: indicates dedicated network port
* 1: indicates LOM
* 2: indicates PCIe extern port
* 3: indicates aggregation network port

IRC: iBMC remote console
------------------------

In the iBMC_ web page you can start a system console as a Java client.

Alternatively install the **Independent Remote Console** (IRC_) which is a remote control tool developed by Huawei based on the server management software iBMC_. 
The IRC_ offers the same functions as the Remote Virtual Control function of the iBMC_ WebUI. 
With the IRC_, you can access and manage the server in real time. 
The IRC_ does not depend on the browser or JRE version, but comes with its own JRE environment.

.. _IRC: http://support.huawei.com/onlinetoolsweb/itexpress/kvmclient/en.html

Download IRC_ Linux package ``kvm_client_linux.zip`` from the FusionServer_tools_ page.
Unpack the files to a new directory::

  mkdir kvm_client_linux
  cd kvm_client_linux
  unzip .../kvm_client_linux.zip

The script ``KVM.sh`` contains the KVM console JRE application.

iBMC power control
------------------

The server power may be controlled using the iBMC CLI::

  ipmcset -d powerstate -v <option>
  Options are:
    0    Normal Power Off, deactivate FRU
    1    Power on, activate FRU
    2    Forced Power Off, deactivate FRU

To read the power status::

  ipmcget -d powerstate


iBMC configuration using IPMI
-----------------------------

From the server's Linux OS, or from a remote Linux server, you can use the ipmitool_ command to configure the iBMC_.

.. _ipmitool: https://sourceforge.net/projects/ipmitool/

Change the iBMC_'s IP configuration to use DHCP_::

  ipmitool lan set 1 ipsrc dhcp

Display the iBMC_ LAN configuration::

  # ipmitool lan print 1
  Set in Progress         : Set Complete
  IP Address Source       : DHCP Address
  IP Address              : 10.5.135.2
  Subnet Mask             : 255.255.0.0
  MAC Address             : 20:3d:b2:44:d3:79
  SNMP Community String   : TrapAdmin12#$
  IP Header               : TTL=0x40 Flags=0x40 Precedence=0x00 TOS=0x10
  Default Gateway IP      : 0.0.0.0
  802.1q VLAN ID          : Disabled
  RMCP+ Cipher Suites     : 0,1,2,3,17
  Cipher Suite Priv Max   : XuuaXXXXXXXXXXX
                        :     X=Cipher Suite Unused
                        :     c=CALLBACK
                        :     u=USER
                        :     o=OPERATOR
                        :     a=ADMIN
                        :     O=OEM

You can list the Ethernet MAC address of all iBMCs using pdsh_::

  pdsh -w <node-list> "ipmitool lan print 1 | grep MAC | awk '{print \$4}'" | sort

.. _pdsh: https://code.google.com/archive/p/pdsh/

Display the IPMI user list, where userid 2 is the root user::

  # ipmitool user list 1
  ID  Name	     Callin  Link Auth	IPMI Msg   Channel Priv Limit
  1                    true    true       true       NO ACCESS
  2   root             true    true       true       ADMINISTRATOR
  3                    true    true       true       NO ACCESS
  4                    true    true       true       NO ACCESS
  ...

Configure our own BMC password for user 2 (root)::

  ipmitool user set password 2 <some-password>

When the password complexity check function is enabled, the password must meet the following requirements:

* Must contain 8 to 20 characters.

* Must contain at least one space or one of the following special characters::

   `~!@#$%^&*()-_=+\|[{}];:'",<.>/?

* Must contain at least two types of the following characters:

  - Letters: a to z
  - Letters: A to Z
  - Digits: 0 to 9

One-Click Info Collect
----------------------

If iBMC_ logfiles are requested by Huawei, it is easy to create them on the iBMC_ front web page:

* Click the button **One-Click Info Collect**.
* The web page will ask you to download the data file ``dump_info.tar.gz``.
  You can send this file to Huawei.
* An iBMC_ pop-up windows says: *Please delete the collected data file after you have downloaded it* (**How??**).

Diagnostics information in iBMC dump_info file
----------------------------------------------

Some errors are **not logged** correctly by the iBMC.  
You can download the dump_info file from the iBMC web interface *One-Click Info Collect* menu item.
Unpack the dump_info tar-ball file.

Examine the dump_info log files for errors, for example, looking for DIMM errors::

  [dump_info]# grep DIMM100 LogDump/maintenance_log
  2020-09-27 19:43:39 WARN : SVR-0029020,BIOS, mainboard DIMM100 Failure detected by Memory_CE_Bucket,Suggest to replace mainboard DIMM100.

Firmware upgrades
=================

From the XH620_downloads_ page get the firmware upgrade document named HUAWEI Rack Server *Upgrade Guide (iBMC)*.
Unpack the zip-file to get the PDF document.
Also download the iBMC_ and BIOS upgrade files and unzip them to separate directories (because of a conflicting file *version.xml*) on your PC (not the server).

The *Upgrade Guide (iBMC)* instructs the user to log in to the iBMC_ GUI.
Use a web browser and enter the iBMC_ IP address or hostname.
Login to the GUI web page with user name *root* and password are discussed above.

**WARNING**: 

* Performing firmware upgrades may require the server to be in a OS shutdown mode, since upgrades are performed through the iBMC_ interface.
* It is apparently not possible to update BIOS, for example, while the server is operating.

iBMC IP address
---------------

To determine the iBMC_ IP address, see the server's boot screen.
From Linux you can inquire like this::

  service ipmi start
  ipmitool lan print 1

which will display the IP address.

There is also some documentation in the *Upgrade Guide (iBMC)* appendix *A.1 Querying the IP Address of the iBMC Management Network Port*.

Perform firmware upgrade
------------------------

Read the *Upgrade Guide (iBMC)* instructions:

* In the GUI press *System->Firmware Upgrade*.
* In *Select Target Version:* use *Browse* to select the iBMC_ firmware file ``image.hpm``.
* Press *Start Update*.
* An iBMC_ upgrade may take 5-10 minutes, after which the iBMC_ (not the server) will be restarted.
  Do not restart the server or the iBMC_ manually during the update.
* After a couple of minutes (when the fans go high) login to the GUI again.

Subsequently upgrade the BIOS:

* In the GUI press *System->Firmware Upgrade*.
* In *Select Target Version:* use *Browse* to select the BIOS firmware file ``biosimage.hpm``.
* Press *Start Update*.
* The BIOS upgrade takes about 8 minutes.
* If the *Upgrade Progress* shows 0% (not 100%) after completion, the upgrade has failed.
* Check *System->Operation Logs*.
* If the logs say *Upgrade (BIOS) with (biosimage.hpm) failed*, the *Upgrade Guide (iBMC)* says:

  * Power off the server (from the console) and then upgrade the BIOS (repeat the above).

* After the upgrade power on the server from the console or the GUI *Power* pane.

The manual also says:

* In the top navigation tree, choose *Power*.
* In the left navigation tree, choose *Power Control*.
* Select *Reset*.  The server will reboot.

Verify firmware versions:

* In the GUI go to the *Information* pane to view *iBMC Firmware Version* and *BIOS Firmware Version*.
* If the firmware updates were not successful, look in the iBMC_ logs.  Then try to repeat the above.

Notice: The iBMC_ GUI may log you out automatically after a certain time, even if you're actively using the GUI!
Then you have to login again and start over.
The timeout value can be configured in the GUI *Config->System Settings*.

X6800 chassis management
========================

The X6800_ chassis containing a number of independent server nodes also has an *Hyper Management Module* (HMM).
However, the chassis HMM module has no GUI interface, but only CLI access through its serial port or the network port.

NOTICE from the X6800_White_paper_:

* The active/standby switchover feature of the X6800 HMMs is not available at present. 
  Therefore, the X6800 comes with only one HMM.

Documentation:

* X6800_Documentation_.
* X6800_Software_ downloads.
* Locate the *HMM Command Reference* manual under X6800_Documentation_.

X6800 Management Principles
---------------------------

This section is from the *X6800 Server User Guide* document.

The X6800 uses the HMM and iBMC to perform node management and out-of-band aggregation management:

* The X6800 uses the HMM to perform management board hot swap, out-of-band aggregation management, and system power consumption managements.
* The X6800 uses Huawei proprietary iBMC intelligent management system to implement remote server management.
  The iBMC complies with IPMI 2.0 specifications and provides reliable hardware monitoring and management.

Management principles of the X6800 are as follows:

* The iBMC and HMM implement management and monitoring of the X6800.
  The iBMC on each node implements node management through the Intelligent Platform Management Interface (IPMI), KVM, or virtual DVD-ROM drive.
  The HMM implements chassis management, which includes fan management, PSU management, and chassis asset management.
* The HMM and iBMC implement aggregation management through LAN switches (LSWs).
  The LSWs provide external GE port, through which users can access the HMM and iBMC to manage the chassis and server nodes.
* The HMM works with the fan switch boards to implements fan management.
  The fan switch board provides five independent pulse-width modulation (PWM) control signals to control the fan speed and ten tachometer (TACH) signals to detect the fan speed.
  Based on the ambient temperature and temperature of the temperature-sensitive components on the boards, the HMM uses Huawei speed adjustment algorithms to determine a proper rotation speed, and then sends it to the fan switch board.
  The fan switch board receives fan speed signals from the fan modules and reports the fan module status to the HMM.
* PSU monitoring and management: The HMM provides one inter-integrated circuit (I2C) for managing the PSUs and general purpose input/output (GPIO) pins for detecting the PSU installation status and PwrOk state.
  The HMM supports queries on PSU output power, PSU installation status, and PSU alarms.

Connecting to the chassis HMM via serial port
---------------------------------------------

The chassis rear side has a **serial port** RJ45 connector on the management module labelled **IOIOI**.
This is the most convenient way to log in to the HMM.
Use a USB-to-serial adapter with your PC.
Connect a serial port cable with an RJ45 adapter between the PC and the chassis serial port.

Key communication parameters::

    Serial Line to connect to: COMn
    Speed (baud): 115200
    Data bits: 8
    Stop bits: 1
    Parity: None
    Flow control: None

This also enables log in to the U-Boot_ command-line interface (CLI).

.. _U-Boot: https://en.wikipedia.org/wiki/Das_U-Boot

Connecting to the chassis HMM via network
-----------------------------------------

Connect a PC to the available chassis Ethernet port (either front or back) with a direct UTP cable.
Configure the PC's IP address appropriately:

* IP-address 10.10.1.X (example: 10.10.1.2) and netmask 255.0.0.0

Log in to the chassis IP address:

* SSH to 10.10.1.200 (HMM V1.62 and later).
* Login: root
* Password: Huawei12#$ (yes, the publicly known Huawei password!)

**Note:** If you have several SSH authentication key files ($HOME/.ssh/id_*) they will be tried in turn, and since the iBMC_ accepts a maximum of 3 login attempts,
SSH logins may fail with the error::

  Received disconnect from 10.x.x.x port 22:2: Too many authentication failures

Workaround: Specify only 1 of the keys to the SSH command, for example::

  ssh -i $HOME/.ssh/id_rsa <iBMC_hostname>

HMM commands
------------

When logged in to the HMM, the on-line help displays help information::

  iBMC:/->help
  iBMC:/->ipmcget help
  iBMC:/->ipmcset help

For example, list the *System Event List*::

  iBMC:/->ipmcget -d sel -v list

Change the root user's password by::

  ipmcset -d password -v root

where the response to *Input your password* is the publicly known Huawei password *Huawei12#$*,
then select your own password.

Resetting the HMM
.................

If you must reset the HMM, use this command::

  ipmcset -d reset

This operation will reboot HMM system, but the servers in the chassis will continue to operate without interruption.

You can reconfigure multiple HMMs using a script similar to the ibmc_consolidated_port.sh_ discussed above.

Add SSH public key
..................

It is possible to add a SSH user certificate for password-less login, see::

  ipmcset -d addpublickey -v <username> <localpath/URL>
  Localpath  e.g.: /tmp/key.pub
  URL            : protocol://[username:password@]IP[:port]/directory/filename
    The parameters in the URL are described as follows:
        The protocol must be https,sftp,cifs,scp or nfs.
        The URL can contain only letters, digits, and special characters. The directory or file name cannot contain @.
        Use double quotation marks (") to enclose the URL that contains a space or double quotation marks ("). Escape the double quotation marks (") and back slash (\) contained in the URL.
        For example, if you want to enter:
        a b\cd"
        Enter:
        "a b\\cd\""

You should first copy a SSH public-key file to the HMM using SFTP_, for example::

  # sftp root@<chassis_address>
  sftp> put id_rsa.pub /tmp/id_rsa.pub
  sftp> quit

Then log in with SSH and add the SSH public-key to the *root* user (the password must be entered)::

  iBMC:/->ipmcset -t user -d addpublickey -v root /tmp/id_rsa.pub
  Input your password:
  Add user public key successfully.

Chassis IP address
------------------

When logged into the X6800_ chassis iBMC_ show the MAC address and set the IP address mode to DHCP_::

  iBMC:/->ipmcget -d ipinfo

Read the chassis iBMC MAC address from the output.
The MAC address must be configured in your DHCP_ server.

**Warning:** After the following point **network contact will be lost to the chassis** until it receives a response from a DHCP_ server on the network!

Now configure the iBMC as a DHCP client::

  iBMC:/->ipmcset -d ipmode -v dhcp

Connect the chassis to the network whose DHCP_ server will offer IP configuration to the X6800 chassis.

Disable login security banner
-----------------------------

By default the HMM prints an annoying login security banner at every login::

  WARNING! This system is PRIVATE and PROPRIETARY and may only be accessed by authorized users. Unauthorized use of the system is prohibited.
  The owner, or its agents, may monitor any activity or communication on the system. The owner, or its agents, may retrieve any information stored within the system.
  By accessing and using the system, you are consenting to such monitoring and information retrieval for law enforcement and other purposes.

Fortunately, this security banner can be disabled::

  ipmcset -t securitybanner -d state -v disabled

X6800 firmware upgrade
----------------------

The firmware upgrade *Release Notes* document describes enhancements, as well as security issue resolved (there are several CVE issues, for example `CVE-2016-6898 <http://www.cvedetails.com/cve/CVE-2016-6898/>`_).

The *HMM Upgrade Guide* describes HMM upgrade impact on system as:

* Impact on services: None
* Impact on O&M: No other operation is allowed during the upgrade. You should restart the HMM immediately or later after the upgrade. Services are interrupted during the restart

Points to note:

* The system user name and password remain unchanged after the HMM upgrade.
* The active and standby images of the HMM must be upgraded individually.
* Upgrade the standby image first. After the standby image is upgraded, restart the server and upgrade the original active image.

Firmware upgrade procedure
..........................

Quoting the *HMM Upgrade Guide*, first upgrade the standby HMM image:

* Verify the firmware versions by::

    iBMC:/->ipmcget -d version

* Copy the firmware image file from a Linux server to the iBMC using SFTP_::

    # sftp root@<chassis_address>
    sftp> put /tmp/image.hpm /tmp/image.hpm
    sftp> quit

  Windows users may use *WinSCP* and configure it to use SFTP_ transfers.

* Log in and disable logout on timeout::

    ipmcset -d notimeout -v enabled 

* Upgrade the HMM software::

    ipmcset -d upgrade -v /tmp/image.hpm

After the upgrade is complete, the HMM system automatically restarts.

**Important:** Log in after the restart and **repeat all steps** (SFTP_, notimeout, upgrade) in order to upgrade the original HMM image.

.. _SFTP: https://www.ssh.com/ssh/sftp/

Power management
----------------

To inquire the chassis and node power info::

  iBMC:/->ipmcget -t powercapping -d info

To inquire the power supply information::

  iBMC:/-> ipmcget -d psuinfo

Chassis health information
--------------------------

To inquire the chassis HMM Alarm Information health info::

  iBMC:/->ipmcget -d healthevents

FusionServer tools
==================

In the *Support > Product Support > IT > Server > TaiShan* web page you may find the FusionServer_tools_ page.
Se documentation files under the *Documentation* tab.

.. _FusionServer_tools: http://support.huawei.com/enterprise/productNewOffering?idAbsPath=7919749|9856522|9856629|21015513&pid=21015513

Under the *Downloads* tab select the latest *Version and Patch Number*.
Here there will be a list of *FusionServer Tools V100R002C00SPC301*, for example:

* FusionServer Tools-uMate-Linux-V128.tar.gz 

  In the Linux operating system, for batch inspection, log collection, upgrade firmware, BIOS configuration, BMC configuration, HMM configuration, the power control operation. 

uMate tool
----------

The *uMate* is a Java-based tool used for log collection, firmware upgrade, configuration of BIOS, iBMC, HMM, and System.

**WARNING:** It seems that *uMate* does not work on EL8 Linux, and that CentOS/RHEL 7 is required!

The following prerequisites must be installed (this is for CentOS/RHEL)::

  yum install java-1.8.0-openjdk ipmitool net-snmp-utils python glibc.i686 libXext.i686

If prerequisites are missing, the *uMate* tool may freeze without any error message.

Unpack the ``FusionServer Tools-uMate-Linux-Vxxx.tar.gz`` tar-ball, creating a subdirectory ``uMate-Linux-V128``.
Go to this subdirectory and run the *uMate* GUI or CLI tool::

  uMate.sh
  uMate_CLI.sh

Remember: For upgrading the BIOS, the server must be rebooted after the BIOS update.

The GUI tool includes a documentation *Help window* at the ? icon.

In case of errors, look at the log files in the `log` subdirectory, or temporary files in the `work` subdirectory.

Issues with uMate
.................

uMate (version V126) has several issues:

* The GUI window very often appears to be **frozen**.
  This occurs on Linux when you use a remote X11 display, for example using SSH login to the server.
  It often helps to **resize or refresh the window** in order to update the window contents.

* A number of performance related BIOS settings are **not available** in the uMate *BIOS Config* tool:

  1. QPI Configuration: Snoop Mode Select

  2. IIO Configuration->IIO1 Configuration->Port 3A:

     - Link Speed
     - PCI-E Port Max Payload Size

  3. IIO Configuration->IIO1 Configuration (and IIO2)

     - IOU0, IOU1, IOU2 Non-Posted Prefetch

InfoCollect
-----------

FusionServer Tools InfoCollect_ is used to collect server hardware log files for locating server faults.

However, it is **easier** to use the iBMC_ web page *One-Click Info Collect* as described above.

If you want to collect hardware log(iBMC, iMana, MM board, Switch), please use *InfoCollect_BMC_MM_Switch*.

Read the *FusionServer Tools V2R2 InfoCollect User Guide* from the FusionServer_tools_ page.


.. _InfoCollect: http://support.huawei.com/enterprise/SoftwareVersionAction!getSoftwareInfo.action?nodePath=fixnode01|7919749|9856522|9856629|21015513|21802824|21802825|21964551&idAbsPath=fixnode01|7919749|9856522|9856629|21015513&version=FusionServer+Tools+V2R2C00RC2SPC200&hidExpired=&contentId=SW1000185794
