.. _Dell_servers_and_storage:

#########################
Dell servers and storage
#########################

This page contains information about DellEMC_ servers and storage deployed in our cluster:

.. toctree::
   :maxdepth: 1

   Dell_BIOS_settings
   Dell_iDRAC
   Dell_DSU_and_racadm
   Dell_R650
   Dell_R640
   Dell_C6420
   C8220_server
   Dell_ME484

DellEMC_ firmware and software download pages:

* `R760 <https://www.dell.com/support/home/en-us/product-support/product/poweredge-r760/drivers>`_
* `R760xd2 <https://www.dell.com/support/home/en-us/product-support/product/poweredge-r760xd2/drivers>`_
* `R650 <https://www.dell.com/support/home/en-us/product-support/product/poweredge-r650/drivers>`_
* `R750 <https://www.dell.com/support/home/en-us/product-support/product/poweredge-r750/drivers>`_
* `R7525 <https://www.dell.com/support/home/en-us/product-support/product/poweredge-r7525/drivers>`_
* `R640 <https://www.dell.com/support/home/en-us/product-support/product/poweredge-r640/drivers>`_
* `R740xd2 <https://www.dell.com/support/home/en-us/product-support/product/poweredge-r740xd2/drivers>`_
* `C6420 <https://www.dell.com/support/home/en-us/product-support/product/poweredge-c6420/drivers>`_
* `C6400 <https://www.dell.com/support/home/en-us/dkbsdt1/product-support/product/poweredge-c6400/drivers>`_

Dell OpenManage
===============

Download the OpenManage_ software ISO image from the server model's download page in the *Systems Management* download category.

Download the *Dell EMC OpenManage Deployment Toolkit (Linux)* DTK ISO file and mount it on ``/mnt``.

.. _OpenManage: https://www.dell.com/support/article/us/en/04/sln310664/dell-emc-openmanage-systems-management-portfolio-overview?lang=en

Monitoring CPU and power
========================

The turbostat_ command reports  processor  topology,  frequency, idle power-state statistics, temperature and power on X86 processors.
Examples of usage are::

  turbostat --Summary --quiet
  turbostat --show CoreTmp,PkgTmp,PkgWatt,Bzy_MHz

.. _turbostat: https://www.linux.org/docs/man8/turbostat.html

.. _DellEMC: https://www.dell.com/

