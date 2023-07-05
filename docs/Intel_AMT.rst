.. _Intel_AMT:

========================================
Intel Active Management Technology (AMT)
========================================

.. Contents::

About AMT
=========

Intel® *Active Management Technology* (Intel® AMT_) is a feature of Intel® Core™ processors with Intel® vPro_ technology and workstation platforms based on select Intel® Xeon® processors. 
Intel® AMT_ uses integrated platform capabilities and popular third-party management and security applications, to allow IT or managed service providers to better discover, repair, and help protect their networked computing assets.
Intel® AMT_ also saves time with remote maintenance and wireless manageability for your mobile workforce, and secure drive wiping to simplify PC lifecycle transitions.

See also Wikipedia articles on:

* `Intel AMT <https://en.wikipedia.org/wiki/Intel_Active_Management_Technology>`_.
* Intel vPro_
* Intel ME_ (*Intel Management Engine*)


.. _vPro: https://en.wikipedia.org/wiki/Intel_vPro
.. _ME: https://en.wikipedia.org/wiki/Intel_Management_Engine
.. _AMT: https://www.intel.com/content/www/us/en/architecture-and-technology/intel-active-management-technology.html

Documentation
-------------

* The book `Active Platform Management Demystified: Unleaching the power of Intel™ vPro Technology <http://www.meshcommander.com/active-management>`_ written by Arvind Kumar, Purushottam Goel, and Ylian Saint-Hilaire in 2009.

AMT management tools
====================

* MeshCommander_ is an entirely web based tool for remote management of your Intel® AMT computers. 

.. _MeshCommander: http://www.meshcommander.com/

AMT firmware updates
====================

A number of security holes in AMT firmware have been reported.
If you have activated AMT_, it is **mandatory** to install the latest AMT_ firmware updates from your PC vendor.

A partial list of AMT_ security holes includes:

* CVE-2017-5712_ (see INTEL-SA-00086_)
* CVE-2017-5689_ (see INTEL-SA-00075_)
* CVE-2017-5705_ and similar CVE-2017-5706_ CVE-2017-5707_ CVE-2017-5708_ CVE-2017-5709_ CVE-2017-5710_ CVE-2017-5711_

Software tools for AMT_ security:

* Intel-SA-00086-software_ for vendor firmware updates and tools
* `Intel-SA-00086 Detection Tool <https://downloadcenter.intel.com/download/27150?v=t>`_ for Linux and Windows
* INTEL-SA-00075-Linux-Detection-And-Mitigation-Tools: https://github.com/intel/INTEL-SA-00075-Linux-Detection-And-Mitigation-Tools
* AMT status checker for Linux: https://github.com/mjg59/mei-amt-check
* AMT Forensics: Retrieve Intel AMT's Audit Log from a Linux machine without knowing the admin user's password: https://github.com/google/amt-forensics


.. _CVE-2017-5712: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-5712
.. _INTEL-SA-00086: https://security-center.intel.com/advisory.aspx?intelid=INTEL-SA-00086&languageid=en-fr
.. _Intel-SA-00086-software: https://www.intel.com/content/www/us/en/support/articles/000025619/software.html
.. _CVE-2017-5689: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-5689
.. _INTEL-SA-00075: https://security-center.intel.com/advisory.aspx?intelid=INTEL-SA-00075&languageid=en-fr
.. _CVE-2017-5705: http://www.cve.mitre.org/cgi-bin/cvename.cgi?name=2017-5705
.. _CVE-2017-5706: http://www.cve.mitre.org/cgi-bin/cvename.cgi?name=2017-5706
.. _CVE-2017-5707: http://www.cve.mitre.org/cgi-bin/cvename.cgi?name=2017-5707
.. _CVE-2017-5708: http://www.cve.mitre.org/cgi-bin/cvename.cgi?name=2017-5708
.. _CVE-2017-5709: http://www.cve.mitre.org/cgi-bin/cvename.cgi?name=2017-5709
.. _CVE-2017-5710: http://www.cve.mitre.org/cgi-bin/cvename.cgi?name=2017-5710
.. _CVE-2017-5711: http://www.cve.mitre.org/cgi-bin/cvename.cgi?name=2017-5711

Management Engine BIOS Extension (MEBX)
=======================================

Intel ME_ configuration is included in the BIOS by the Intel® *Management Engine BIOS Extension* (MEBX_). 
The Intel MEBX_ provides the ability to change and/or collect the system hardware configuration, passes it to the management firmware and provides the Intel ME configuration user interface.

.. _MEBX: https://www.intel.com/content/www/us/en/support/articles/000006720/boards-and-kits/desktop-boards.html

Accessing MEBX
--------------

If the PC has AMT_ hardware, you can enter the MEBX_ setup just after the POST start-up by pressing::

  Control-P

This option is usually not displayed on the PC boot screen.

When entering the MEBX_ login screen, the factory default password is **admin**.
You will then be asked to set a new MEBX_ password.

MEBX password
-------------

When creating an MEBX_ **admin password**, it is important to note that the BIOS will interpret keystrokes assuming a **US keyboard layout**.

The documented **default password** for user *admin* is also *admin*.
If AMT_ is enabled, this password must be changed.

Since non-alphanumeric characters are required in MEBX passwords, it is important to take note the actual characters typed into the BIOS,
since they may be different when you login to the AMT_ from a web-browser or other tool!
In BIOS setup, a **US keyboard layout** is assumed.

AMT security links
==================

* Talk: *Intel AMT: Using & Abusing the Ghost in the Machine* by Parth Shukla - timevortex@google.com:

  - Video: https://www.youtube.com/watch?v=aiMNbjzYMXo
  - Slides: https://goo.gl/HJASb8 

* F-Secure security alert:

  - https://press.f-secure.com/2018/01/12/intel-amt-security-issue-lets-attackers-bypass-login-credentials-in-corporate-laptops/
  - https://business.f-secure.com/intel-amt-security-issue (see **FAQ** at the end)
  - Full advisory: https://sintonen.fi/advisories/intel-active-management-technology-mebx-bypass.txt

* EFF story: https://www.eff.org/deeplinks/2017/05/intels-management-engine-security-hazard-and-users-need-way-disable-it

* Wired story: https://www.wired.com/story/intel-management-engine-vulnerabilities-pcs-servers-iot/

* Slashdot story: https://yro.slashdot.org/story/18/01/12/201200/researcher-finds-another-security-flaw-in-intel-management-firmware

* Arstechnica story: https://arstechnica.com/information-technology/2018/01/researcher-finds-another-security-flaw-in-intel-management-firmware/
