.. _Dell_DSU_and_racadm:

===============================================
Dell System Update (DSU) and racadm
===============================================

.. Contents::

===============================================================================================

The *Dell System Update* (DSU_) is a script optimized update deployment tool for applying *Dell Update Packages* (DUP) to Dell EMC PowerEdge servers. 
See the `DSU manuals <https://www.dell.com/support/home/us/en/04/product-support/product/system-update-v1.6.0/manuals>`_.

The DSU_ may also be configured as a Yum_ repository, see the DSU_ page.  
The commands are::

  curl -O https://linux.dell.com/repo/hardware/dsu/bootstrap.cgi
  bash bootstrap.cgi

Alternatively, download the latest ``Systems-Management_Application_*``
file from the server's download category *Systems Management* and execute it, for example::

  ./Systems-Management_Application_N2H86_LN64_2.1.2.0_A00.BIN

This will create the Yum_ repository file::

  /etc/yum.repos.d/dell-system-update.repo

Now you can install RPM packages including iDRAC_ tools::

  yum install dell-system-update 

or you can extract the RPM package::

  ./Systems-Management_Application_MPVTK_LN64_2.1.0.0_A00.BIN --extract /tmp
  ls -l /tmp/dell-system-update-2.1.0.0-24.09.00.x86_64.rpm
  -rwxr-xr-x. 1 root root 6430762 Dec  3 08:21 /tmp/dell-system-update-2.1.0.0-24.09.00.x86_64.rpm
  dnf install /tmp/dell-system-update-2.1.0.0-24.09.00.x86_64.rpm

Using DSU_ to preview Dell upgrades::

  /usr/sbin/dsu -n -p

To apply Dell upgrades::

    /usr/sbin/dsu -u

.. _DSU: http://linux.dell.com/repo/hardware/dsu/
.. _Yum: https://en.wikipedia.org/wiki/Yum_(software)

Installing the racadm package
----------------------------------

The ``racadm`` package is no longer contained in the dell-system-update.repo (Dec. 2024).
You have to download the ``Dell iDRAC Tools for Linux`` tar-ball file (currently v11.2.1.0) 
file from the server's download category *Systems Management*.

Unpack the tar-ball::

  tar xzvf Dell-iDRACTools-Web-LX-11.2.1.0-528_A00.tar.gz

and go to the ``iDRACTools/racadm`` folder.
Unfortunately, the ``install_racadm.sh`` script doesn't work on Rocky and other EL8/EL9 clones.
Go to the appropriate subfolder and install the RPM packages::

  cd iDRACTools/racadm/RHEL8/x86_64/
  dnf install srvadmin-*rpm
  ln -s /opt/dell/srvadmin/bin/idracadm7 /usr/local/bin/racadm  # Provides a "racadm" command

Systems Management Managed Node Core and CLI
--------------------------------------------

Install the package::

  yum install srvadmin-omacore

Disk reports::

  omreport storage vdisk                      # List of Virtual Disks in the System
  omreport storage pdisk controller=1         # List of Physical Disks on Controller 1
  omreport storage pdisk controller=1 vdisk=0 # List of Physical Disks belonging to Virtual Disk0

The racadm command
-------------------------

Make a soft link for the ``racadm`` command::

  ln -s /opt/dell/srvadmin/bin/idracadm7 /usr/local/bin/racadm

Read the `Integrated Dell Remote Access Controller 9 RACADM CLI Guide <https://www.dell.com/support/manuals/en-us/oth-t140/idrac9_5.xx_racadm_pub>`_.

There is a useful `racadm cheat sheet <https://www.gooksu.com/2015/04/racadm-quick-dirty-cheatsheet/>`_.

Some examples are:

* Get Health LED status::

    racadm getled

* Make the LED blink::

    racadm setled -l 1

* Stop the LED from blinking::

    racadm setled -l 0

* Get system and version information::

    Service Tag: racadm getsvctag
    System info: racadm getsysinfo -s
    Versions:    racadm getversion
    BIOS:        racadm getversion -b
    CPLD:        racadm getversion -c
    iDRAC:       racadm getversion -f idrac

* Get system logs::

    SEL Event Log: racadm getsel
    Lifecycle Log: racadm lclog view

* Get hardware inventory information::

    racadm hwinventory

Clone system configuration with racadm
......................................

The ``racadm`` command can be used to get and set the system configuration using::

  --clone Gets the configuration .xml files without system-related details such as service tag. The .xml file received does not have any virtual disk creation option.

For example::

  racadm get --clone -t xml -f config.xml

In the ``config.xml`` you may possibly want to delete the line setting the iDRAC password so that your current password is preserved::

  <Attribute Name="Users.2#Password">Calvin#SCP#CloneReplace1</Attribute>

To use the config.xml on another server and **reboot automatically by default**::

  racadm set -t xml -f config.xml

To postpone the reboot::

  racadm set -t xml -f config.xml -b NoReboot

Add the ``--preview`` to just check the operation.

You can also reconfigure just a single setting component with the ``-c`` flag, for example::

  racadm set -t xml -f config.xml -c NIC.Integrated.1-1-1 -b NoReboot

To configure the UEFI_ boot order::

  racadm set bios.biosbootsettings.UefiBootSeq NIC.PxeDevice.1-1,Disk.SATAEmbedded.A-1

or configure this setting in the `config.xml` file::

  <Attribute Name="UefiBootSeq">NIC.PxeDevice.1-1, Disk.SATAEmbedded.A-1</Attribute>

The server will need to be rebooted, see the ``racadm set -b NoReboot|Graceful|Forced`` options in::

  racadm help set

The ``racadm set`` operation launches an iDRAC job which must complete before you reboot the server.
See the job status by::

  racadm jobqueue view -i JID_xxxxxx

Setting system parameters with racadm
-------------------------------------------

Set the E-mail alerts destination::

  racadm set iDRAC.EmailAlert.Address.1 <some-email-address>

View the BIOS_ boot mode::

  racadm get BIOS.BiosBootSettings

To set the boot mode to UEFI_ at the next reboot::

  racadm set BIOS.BiosBootSettings.BootMode Uefi
  racadm jobqueue create BIOS.Setup.1-1

Note: It seems that additional UEFI_ parameters also need to be set (TBD)::

  UefiBootSeq NIC.PxeDevice.1-1,Disk.SATAEmbedded.A-1
  HddPlaceholder Enabled

To enable **IPMI over LAN**::

  racadm set iDRAC.IPMILan.Enable 1

The server needs to be rebooted in order for the new setting to take effect.

Get a list of settings::

  racadm get BIOS

To read some current values::

  racadm get iDRAC.IPMILan
  racadm get BIOS.ProcSettings
  racadm get BIOS.SysProfileSettings
  racadm get BIOS.SysProfileSettings.WorkloadProfile

See the manual `Configuring IPMI over LAN using RACADM <https://www.dell.com/support/manuals/da-dk/oth-r750/idrac9_4.00.00.00_ug_new/configuring-ipmi-over-lan-using-racadm?guid=guid-e84fe7b0-1d24-470d-a09a-2e2d009bc0bb&lang=en-us>`_.

To enable **WakeOnLan** first check the installed NICs (network adapters), for example::

  racadm get NIC.NICConfig
  NIC.NICConfig.1 [Key=NIC.Embedded.1-1-1#NICConfig]
  NIC.NICConfig.2 [Key=NIC.Embedded.2-1-1#NICConfig]

View the NIC settings::

  racadm get NIC.NICConfig.1

Set the WakeOnLan::

  racadm set NIC.NICConfig.1.WakeOnLan Enabled

Then you must create a job for this NIC::

  racadm jobqueue create NIC.Embedded.1-1-1

A new setting will only take effect after a system reboot.
