.. _RHEL_applications:

==================================
Applications on RHEL and clones
==================================

.. Contents::

.. _EPEL: https://fedoraproject.org/wiki/EPEL

Google Chrome browser
===============================

To install the Google Chrome browser see instructions in http://www.tecmint.com/install-google-chrome-on-redhat-centos-fedora-linux/ and https://wiki.centos.org/AdditionalResources/Repositories/GoogleYumRepos.

Create the file ``/etc/yum.repos.d/google.repo``::

  [google-chrome]
  name=google-chrome
  baseurl=http://dl.google.com/linux/chrome/rpm/stable/$basearch
  enabled=1
  gpgcheck=1
  gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub

and then do::

  yum install google-chrome-stable

**Warning:** If the user's home directory is NFS mounted, Chrome may fail to start with a message like::

  Failed to create /home/XXX/.pki/nssdb directory.

This is due to SE:ref:`Linux`, see https://bugzilla.redhat.com/show_bug.cgi?id=1184848.
Solution is unknown (except to set SELinux to permissive).'

Google Authenticator for Linux (MFA)
=============================================================

Google_Authenticator_ provides a two-step authentication procedure using one-time passcodes (OTP_). 
The OTP_ generator application is available for iOS, Android and Blackberry. 
Similar to S/KEY Authentication the authentication mechanism integrates into the Linux PAM system. 

Time-based One-time Password (TOTP_) is a computer algorithm that generates a one-time password (OTP_) which uses the current time as a source of uniqueness. 
TOTP_ is defined in RFC6238_.

Documentation:

* `Setting up multi-factor authentication on Linux systems <https://www.redhat.com/sysadmin/mfa-linux>`_ (Red Hat).
* `Set Up SSH Two-Factor Authentication (2FA) on CentOS/RHEL Server <https://www.linuxbabe.com/redhat/ssh-two-factor-authentication-centos-rhel>`_ 
* `Google Authenticator instructions <https://wiki.archlinux.org/title/Google_Authenticator>`_ (archlinux).

Summary:

* Install packages from EPEL_ and Base::

    dnf install google-authenticator qrencode qrencode-libs

* In ``/etc/ssh/sshd_config`` configure the use of password + one-time code::

    ChallengeResponseAuthentication yes

  To enforce the use of password + one-time code for all users, including **root**::

    AuthenticationMethods publickey,keyboard-interactive

  Restart the *sshd* service.

* Add to ``/etc/pam.d/sshd`` near the top of the file::

    # two-factor authentication via Google Authenticator
    auth     required     pam_google_authenticator.so secret=${HOME}/.ssh/google_authenticator

Users must do:

* Install the **Google Authenticator app**, the most well-known TOTP mobile app available via *Google Play* or Apple *App store* on mobile phones.
  In addition, the **Microsoft Authenticator app** works as well with the QR-codes generated here.

* Run the ``google-authenticator`` command to create a new secret key in the ``~/.ssh/`` directory (default is in ``~/.google_authenticator``)::

    google-authenticator -s ~/.ssh/google_authenticator

  Answer **y** (yes) to all questions to use the defaults.
  The *emergency scratch codes* are also in this file.

  See also the *pam_google_authenticator* man-page.

To redisplay the QR code of a previously generated key: 

* https://stackoverflow.com/questions/34520928/how-to-generate-a-qr-code-for-google-authenticator-that-correctly-shows-issuer-d

Users can use the ``qrencode`` command to generate ASCII output QR code with::

  qrencode -o- -t ANSI256 -d 300 -s 10 "otpauth://totp/$USER@`hostname`?secret=`head -1 $HOME/.ssh/google_authenticator`"

Sometimes, we just want to enable the 2FA capability just when we connect from outside our local network. 
To achieve this, create a file (e.g. ``/etc/security/access-local.conf``) and add the networks where you want to be able to bypass the 2FA from::

  # only allow from local IP range
  + : ALL : 192.168.20.0/24
  # Additional network: VPN tunnel ip range (in case you have one)
  + : ALL : 10.xx.yy.0/24
  + : ALL : LOCAL
  - : ALL : ALL

Then edit your ``/etc/pam.d/sshd`` and add the line at the top::

  #%PAM-1.0
  auth [success=1 default=ignore] pam_access.so accessfile=/etc/security/access-local.conf

.. _Google_Authenticator: https://github.com/google/google-authenticator
.. _OTP: https://en.wikipedia.org/wiki/One-time_password
.. _TOTP: https://en.wikipedia.org/wiki/Time-based_One-Time_Password
.. _RFC6238: https://datatracker.ietf.org/doc/html/rfc6238

MATLAB
==============

We can install MATLAB from https://downloads.cc.dtu.dk using the FIK key file method.
The installation may take about 28 GB of disk space, in addition to the 17 GB ISO image.

CentOS 8 systems need this package for the GUI to work correctly::

  dnf install libcanberra-gtk2 

and users need to set this environment variable to avoid GTK warnings::

  export GTK_PATH=/usr/lib64/gtk-2.0 

NVIDIA graphics cards on desktops
========================================

Desktop PCs and workstations which have an NVIDIA graphics card should have drivers installed in a different way, because the GPU instructions do not work with X11 displays.

* Read RHEL8 instructions in https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html

  Install prerequisites::

    dnf install gcc kernel-devel kernel-headers

  Disable SE:ref:`Linux` in ``/etc/selinux/config``::

    SELINUX=permissive

  Blacklist the Nouveau driver.
  Create a file at ``/etc/modprobe.d/blacklist-nouveau.conf`` with the following contents::

    blacklist nouveau
    options nouveau modeset=0

  Regenerate the kernel initramfs::

    sudo dracut --force

  Update and reboot::

    dnf update
    reboot

  Set the system to mode 3::

    init 3

  Verify that the Nouveau driver is **not** loaded.
  The Nouveau drivers are loaded if the following command prints anything::

    lsmod | grep nouveau

  Finally install Nvidia drivers.

See instructions in:

* CentOS 8: https://linuxconfig.org/how-to-install-the-nvidia-drivers-on-centos-8

* CentOS 8 in https://developer.nvidia.com/cuda-downloads::

    dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo
    dnf clean all
    dnf module install nvidia-driver:latest-dkms
    dnf install cuda

* See `Streamlining NVIDIA Driver Deployment on RHEL 8 with Modularity Streams <https://developer.nvidia.com/blog/streamlining-nvidia-driver-deployment-on-rhel-8-with-modularity-streams/>`_.
  When migrating the EL8 release, remove the driver and reinstall it::

    dnf remove nvidia-driver
    dnf module reset nvidia-driver
    dnf module install nvidia-driver:latest-dkms

  Install the latest CUDA_ repo::

    dnf install https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-11-5-11.5.1-1.x86_64.rpm

  Reboot the system
     

* CentOS 7: https://linuxconfig.org/how-to-install-the-nvidia-drivers-on-centos-7-linux

NVIDIA GPUs
==============

**Note:** Desktop PCs and workstations should be installed as shown in the above section.

Install prerequisites from EPEL_::

  yum install epel-release
  yum install dkms

Download NVIDIA software from http://www.nvidia.com/Download/index.aspx:

* Select the appropriate GPU driver for **Linux 64-bit RHEL7**.

* Installation instructions are::

    yum install nvidia-driver-local-repo-rhel7-*.x86_64.rpm
    yum clean all
    yum install cuda-drivers
    reboot

To view the NVIDIA driver version::

  modinfo nvidia 

Check the status of the GPUs with nvidia-smi_  *NVIDIA System Management Interface program*::

  nvidia-smi

There is an on-line manial-page at https://man.archlinux.org/man/nvidia-smi.1.en

To view the GPU connection topology matrix::

  nvidia-smi topo --matrix 

When the driver is loaded, the driver version can be found by executing the command::

  cat /proc/driver/nvidia/version

.. _nvidia-smi: https://developer.nvidia.com/nvidia-system-management-interface

NVIDIA official repository
--------------------------

See https://ahelpme.com/linux/centos7/install-cuda-and-nvidia-video-driver-under-centos-7/.

Install the Nvidia repo::

  yum install -y yum-utils
  yum-config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-rhel7.repo

Install the driver and CUDA::

  yum install nvidia-driver-latest-dkms cuda
  yum install cuda-drivers
  reboot

CUDA
----

The CUDA_ toolkit can be downloaded from https://developer.nvidia.com/cuda-downloads.
There is an installation guide at http://docs.nvidia.com/cuda/cuda-installation-guide-linux

Download the repo file and install the CUDA_ tools::

  yum install cuda-repo-rhel7-8.0.61-1.x86_64.rpm
  yum clean all
  yum install cuda

Installation instructions for a static CUDA_ version::

  wget https://developer.download.nvidia.com/compute/cuda/12.2.0/local_installers/cuda_12.2.0_535.54.03_linux.run
  sudo sh cuda_12.2.0_535.54.03_linux.run

.. _CUDA: https://developer.nvidia.com/cuda-zone

NVIDIA Persistence Daemon
-------------------------

NVIDIA is providing a user-space daemon on Linux to support persistence of driver state across CUDA job runs. 
The daemon approach provides a more elegant and robust solution to this problem than persistence mode. 
See:

* https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#post-installation-actions
* http://docs.nvidia.com/deploy/driver-persistence/index.html#persistence-daemon

On CentOS 8 you can start this service::

  rpm -q nvidia-persistenced
  systemctl enable nvidia-persistenced
  systemctl start nvidia-persistenced

One may alternatively put htis in ``/etc/rc.local``::

  if test -x /usr/bin/nvidia-smi
  then
	echo Checking NVIDIA driver
	/usr/bin/nvidia-smi
	echo Start the nvidia-persistenced daemon
	/usr/bin/nvidia-persistenced --verbose
  fi

Nvidia process accounting
-------------------------

Enable Nvidia process accounting using nvidia-smi_::

  /usr/bin/nvidia-smi --accounting-mode=1
  /usr/bin/nvidia-smi --query --display=ACCOUNTING

Now you can query Nvidia process accounting, see::

  nvidia-smi --help-query-accounted-apps

for example::

  nvidia-smi --query-accounted-apps=gpu_name,pid,time,gpu_util,mem_util,max_memory_usage --format=csv

Nvidia Data Center GPU Manager (DCGM)
-------------------------------------

Nvidia has a new *Data Center GPU Manager* (DCGM_) suite of tools which includes NVIDIA Validation Suite (NVVS_).
Download of DCGM_ requires membership of the Data Center GPU Manager (DCGM_) Program.
Install the RPM by::

  yum install datacenter-gpu-manager-1.7.1-1.x86_64.rpm

Run the NVVS_ tool::

  nvvs -g -l /tmp/nvvs.log

The (undocumented?) log file (-l) seems to be required.

.. _DCGM: https://developer.nvidia.com/dcgm
.. _NVVS: https://docs.nvidia.com/deploy/nvvs-user-guide/index.html

Oracle VirtualBox
===========================

See the :ref:`Oracle_VirtualBox` page.

VLC media player
==============--

VLC_ media player for Red Hat Enterprise Linux is a free and open source cross-platform multimedia player and framework that plays most multimedia files as well as DVDs, Audio CDs, VCDs, and various streaming protocols. 
Installation requires EPEL_ and RPM_Fusion_ repositories.

.. _VLC: https://www.videolan.org/vlc/download-redhat.html
.. _RPM_Fusion: https://rpmfusion.org/Configuration/
