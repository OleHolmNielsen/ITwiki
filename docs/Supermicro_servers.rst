.. _Supermicro_servers:

==================
Supermicro servers
==================

.. Contents:: 

4029GP-TRT2 servers
====================

We have some Supermicro servers 4029GP-TRT2_ including Nvidia GPU_ (installed in December 2020).

.. _4029GP-TRT2: https://www.supermicro.com/en/products/system/4U/4029/SYS-4029GP-TRT2.cfm
.. _GPU: https://en.wikipedia.org/wiki/Graphics_processing_unit

.. _supermicro-bios-configuration:

BIOS configuration
----------------------------------------

Startup menus:

* Press ESC or DEL at startup to enter BIOS settings menus.

* Press F11 at startup to enter the boot menu.

* Press F12 at startup to perform network booting.

* One-time boot settings may also be selected in the BIOS **Save&Exit** screen from the list below **Boot override**.

**Note:** The NIC MAC addresses must be read from the BMC web interface, or from the printed server configuration report.

Boot menu
---------

In the **Boot mode select** set **UEFI** to avoid *Legacy* booting.
The default is *Dual*.

In *FIXED BOOT ORDER priorities* the *Hard disk* should be first and the *Network:IBA* second (or if desired the other way around).

**NOTE:** UEFI network booting will not work immediately with this setup!
You must first configure *Onboard LAN Option ROM Type* as shown below!

Advanced menu
--------------

Boot Features
.............

* Quiet Boot: Enabled (to get a startup screen with information)
* Bootup Numlock State: Off

CPU configuration
.................

* Hyper-Threading: Enable (disable if desired).

Chipset configuration
.....................

To enable *Sub NUMA Cluster* (SNC_):

* Advanced->Chipset configuration->North bridge->UPI configuration->SNC=Enable

.. _SNC: https://software.intel.com/content/www/us/en/develop/articles/intel-xeon-processor-scalable-family-technical-overview.html

PCIe/PCI/PnP Configuration
..........................

**NOTE:** This is where you must configure **UEFI network booting** for the LAN adapter:

* Onboard LAN1 Option ROM (OROM): EFI

* Network stack configuration:

  * IPv6 PXE support: Disabled.

IPMI
----

BMC Network Configuration
.........................

* IPMI LAN Selection: Dedicated

Connect a BMC LAN cable to the dedicated BMC port.

BMC controller
----------------------------------------

The BMC network port is by default set to **Shared**, and this should be changed to **Dedicated** in the *IPMI* BIOS setup menu.

Read the BMC Ethernet MAC address from the BIOS interface or from the label on the chassis.

From 2019 Supermicro servers no longer ship with the ADMIN/ADMIN BMC login, see
https://www.supermicro.com/en/support/BMC_Unique_Password

The system unique password for the ADMIN user is located on the top cover of the cabinet in the front left corner.

**Note:** Servers delivered by Nextron have a modified BMC password: *Nextronipmi1*

BMC reboot
------------

The menu item for rebooting the BMC is under the web GUI item *Maintenance->Unit Reset*.

BMC Remote Console
----------------------

In the BMC web GUI go to the *Remote control - > Remote console* window.
Click on the *here* link::

  To set the Remote Console default interface, please click. here
  Current interface: HTML5

and set the interface to HTML5_ (default seems to be Java plug-in).
Strangely, HTML5_ only works after the BMC has been rebooted (if you changed this option),
and you can do this from the *Maintenance->IVKM Reset* menu or with the Linux CLI command::

  ipmitool bmc reset cold

.. _HTML5: https://en.wikipedia.org/wiki/HTML5

Firmware update licenses
------------------------

It is possible to upgrade BIOS and BMC/IPMI firmware from the BMC web interface.
Check the *Miscellaneous->Activate Licenses* screen where *Node Product Key status* should be **Activated**.
Otherwise you must buy an **Out of Band (OOB)** license, which can then be typed in here.

Firmware and BIOS update can be performed under the *Maintenance* pull-down menu.

BIOS and BMC firmware upgrades
----------------------------------------

BIOS and BMC firmware can be downloaded from the above product page.
Unzip the firmware files.

Any remote BMC console sessions will be terminated when the firmware updates start!

Log into the BMC web page and go to the **Maintenance** tab:

1. The BMC firmware upgrade menu is **Firmware Update**.
   There will be a warning message::

     Do you want to enter update mode? You will not be able to perform any other tasks until firmware upgrade is complete and the device is rebooted.

   Browse for the firmware file, it may be like ``BMC_X11AST2500-4101MS_20240624_01.74.15_STDsp.bin``, and start the upgrade.

   **NOTE:** The *IPMI Firmware Update* PDF document states::

     NOTE !!! Uncheck preserve configuration box during flashing (very important step for FW to work properly). All settings will be reset to default.
     Uncheck "Preserve configuration" and "Preserve SDR".

   **Uncheck** this box::

     Preserve configuration

   Unfortunately, this means that the BMC login and password are reset to the **factory default values** printed on the cabinet label!   
   You must run the *Kickstart* script ``55_ipmi``
   (copied from the niflnet2 server) again which sets our BMC password!

   **Keep** these checked settings::

      Preserve SDR
      Preserve SSL certificate (Unchecking this option will restore the default SSL certificate.) 

2. The BIOS upgrade menu is **BIOS Upgrade**.
   The BIOS firmware file name may be like ``BIOS_X11DPG-OT-1A06_20240716_4.4_STD.bin``.

   The following check boxes are displayed (the meaning is undocumented)::

     Preserve ME Region  (do not check)
     Preserve NVRAM      (do not check)
     Preserve SMBIOS     (checked by default)

   If you check the first 2 boxes, the server may be unable to boot.
   In this case you must reflash the BIOS upgrade!

   Then **all** BIOS settings will get **reset to default**!! 
   There does not seem to be any way to preserve BIOS settings.

   When the update is completed, a popup windows asks for confirmation of
   *BIOS update complete. Do you wish to reset the system?*
   Curiously, it seems that you need to restart the server or reset the power manually!

   After the BIOS has been upgraded, connect to the system console 
   (the BMC's *Remote HTML5 Console*)
   and make all the *BIOS configuration* settings again shown above for a new server.

Nvidia RTX3090 GPUs
=======================

Drivers for Nvidia GPUs can be downloaded from https://www.nvidia.com/en-us/drivers/unix/
The Latest Production Branch Version: 450.80.02 (or greater) is required for the RTX3090_.

.. _RTX3090: https://www.nvidia.com/en-gb/geforce/graphics-cards/30-series/rtx-3090/

Defective GPUs
----------------

If a GPU is defective, it may be missing from the hardware list.
There are two places to see this:

* The DMI_ command dmidecode_ lists all devices and a *Current Usage: Available* slot may indicate a GPU not registering with the system,
  for example::

    System Slot Information
        Designation: CPU1 Slot2 PCI-E 3.0 X16
        Type: x16 PCI Express 3 x16
        Current Usage: In Use
        ...

    System Slot Information
        Designation: CPU1 Slot3 PCI-E 3.0 X16
        Type: x16 PCI Express 3 x16
        Current Usage: Available
        ...

* The BMC web interface menu *System->Hardware Information* should list all GPUs and their status.
  Check for missing GPUs.

.. _DMI: https://en.wikipedia.org/wiki/Desktop_Management_Interface
.. _dmidecode: https://linux.die.net/man/8/dmidecode

Nvidia drivers
-------------------

Download Nvidia drivers from https://www.nvidia.com/Download/index.aspx and select the appropriate GPU_ version and host operating system.
Installation instructions are provided on the download page::

  rpm -i nvidia-diag-driver-local-repo-rhel7-375.66-1.x86_64.rpm
  yum clean all
  yum install cuda-drivers
  reboot

You can also download and install Nvidia `UNIX drivers <https://www.nvidia.com/en-us/drivers/unix/>`_,
and the CUDA toolkit from https://developer.nvidia.com/cuda-downloads.

To verify the availability of GPU_ accelerators in a node run the command::

  nvidia-smi -L

which is installed with the *xorg-x11-drv-nvidia* RPM package.

Verify the loaded kernel module version::

  $ cat /proc/driver/nvidia/version
  NVRM version: NVIDIA UNIX x86_64 Kernel Module  535.86.05  Fri Jul 14 20:46:33 UTC 2023
  GCC version:  gcc version 8.5.0 20210514 (Red Hat 8.5.0-18) (GCC) 

CUDA
----

The CUDA_ toolkit can be downloaded from https://developer.nvidia.com/cuda-downloads.
There is an installation guide at http://docs.nvidia.com/cuda/cuda-installation-guide-linux

Download the repo file and install the CUDA_ tools::

  yum install cuda-repo-rhel7-8.0.61-1.x86_64.rpm
  yum clean all
  yum install cuda

Installation instructions for a static version::

  wget https://developer.download.nvidia.com/compute/cuda/12.2.0/local_installers/cuda_12.2.0_535.54.03_linux.run
  sudo sh cuda_12.2.0_535.54.03_linux.run

.. _CUDA: https://developer.nvidia.com/cuda-zone
