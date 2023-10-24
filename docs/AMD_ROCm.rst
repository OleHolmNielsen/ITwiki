========================
AMD ROCm
========================

.. Contents::

This page documents how to deploy an EL Linux server with AMD Instinct_ GPUs
using the ROCm_ HPC and AI software stack.

.. _Instinct: https://www.amd.com/en/graphics/instinct-server-accelerators
.. _ROCm: https://www.amd.com/en/graphics/servers-solutions-rocm
.. _ROCm_for_HPC: https://www.amd.com/en/graphics/servers-solutions-rocm-hpc

Compilers and libraries
========================

* HIP_ is a C++ Runtime API and Kernel Language that allows developers to create portable applications for AMD and NVIDIA GPUs from single source code.

* Numba_ is a just-in-time compiler for Python that works best on code that uses NumPy arrays and functions, and loops.

* clMathLibraries_
* clBLAS_ software library containing BLAS functions written in OpenCL.

.. _HIP: https://github.com/ROCm-Developer-Tools/HIP
.. _Numba: https://numba.readthedocs.io/en/stable/user/5minguide.html
.. _clMathLibraries: https://github.com/clMathLibraries/
.. _clBLAS: https://github.com/clMathLibraries/clBLAS

Software installation
=========================

The `Deploy ROCm on Linux <https://rocm.docs.amd.com/en/latest/deploy/linux/>`_
guide documents installation on RHEL.
You must enable the EPEL_ repository.
Install kernel packages::

  dnf install kernel-headers kernel-devel

Two new UNIX groups ``video,render`` should be created, 
and users must be added to those groups.

Install ROCm_ RPMs as documented in
`Installation via Package manager <https://rocm.docs.amd.com/en/latest/deploy/linux/os-native/index.html>`_.
Some Yum repositories ``amdgpu.repo, rocm.repo`` will beanabled for installation.

It may be a good idea to install 
`Multi-version <https://rocm.docs.amd.com/en/latest/deploy/linux/install_overview.html#installation-types>`_
of the ROCm stack on a system, for example::

  dnf install rocm-hip-sdk5.7.1 rocm-hip-sdk5.6.1

Read also the Linux_installation_ section *Post-install Actions and Verification Process*.

.. _Linux_installation: https://rocm.docs.amd.com/en/latest/deploy/linux/os-native/install.html
.. _EPEL: https://docs.fedoraproject.org/en-US/epel/
