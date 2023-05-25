===================================
HPE Proliant SmartArray
===================================

.. Contents::

Management of HPE Proliant SmartArray RAID controllers
=======================================================

SmartArray software
========================

Install Linux software::

  rpm --import http://downloads.linux.hpe.com/SDR/hpePublicKey2048_key1.pub

Add Yum repository file ``/etc/yum.repos.d/HPE-MCP.repo``::

  [HPE-MCP]
  baseurl = http://downloads.linux.hpe.com/repo/mcp/centos/8/x86_64/current/
  enabled = 1
  gpgcheck = 1
  gpgkey = https://downloads.linux.hpe.com/SDR/repo/mcp/GPG-KEY-mcp
  name = HPE Management Component Pack

Install packages and OS prerequisites::

  yum install net-snmp net-snmp-utils net-snmp-libs net-snmp-agent-libs
  yum install ssa ssacli ssaducli hponcfg

A *Smart Storage Adminstrator CLI* command ``/usr/sbin/ssacli`` is installed.

A useful script is smartshow_ from GitHub.

.. _smartshow: https://github.com/OleHolmNielsen/HPE_Proliant


