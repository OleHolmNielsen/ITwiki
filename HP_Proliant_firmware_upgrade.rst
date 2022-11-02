.. _HP_Proliant_firmware_upgrade:

===================================
HP Proliant firmware upgrade issues
===================================

.. Contents::

Firmware upgrades may be important in maintaining the health of your servers.
While we're generally happy with `HP Proliant <http://www.hp.com/sbso/busproducts_servers.html>`_ servers,
some issues invariable appear as with any complex system.

.. _LO100: http://h18004.www1.hp.com/products/servers/management/remotemgmt/lightsout100i-advanced/index.html

Disk firmware upgrades
======================

If you run *any* disk firmware upgrade script on an RHEL system using the *sh* shell, you'll get an error as in this example::

  # sh CP018205.scexe
  CP018205.scexe: line 92: .: CPINIT: file not found
  Internal error cannot continue.  See log for details

HP's installation instructions are incomplete and ambiguous::

  From the same directory, execute the Smart Component. For example: ./CPXXXXXX.scexe

I offer complete and unambiguous installation instructions which should replace HP's instructions::

  From the same directory, you MUST execute the Smart Component as follows:
    chmod +x ./CPXXXXXX.scexe; ./CPXXXXXX.scexe.
  Do NOT execute the Smart Component using "sh ./CPXXXXXX.scexe" as this may fail on newer operating systems.

An alternative workaround is to add "." (current working directory) to your path before executing HP's firmware update script::

  export PATH=$PATH:.

This PATH is insecure and should be undone immediately after the upgrade (just logging out is the easiest way).

Firmware upgrade prerequisite packages
--------------------------------------

HP's tools usually have undocumented prerequisite packages RPM packages.

You may need to install these prerequisite packages (some must be in i686 **32-bit versions**)::

  yum install expect net-snmp redhat-rpm-config kernel-devel kernel-headers rpm-build rpm-devel binutils gcc glibc glibc-devel gawk sed pciutils
  yum install libXrender.i686 freetype.i686 libXrandr.i686 libXcursor.i686 fontconfig.i686 zlib.i686
  yum install libuuid.i686 libSM.i686 libXi.i686 libstdc++.i686 ncurses-libs.i686

Not all of these packages may be required for all HP firmware tools, but it may be best to have all of them.

Programming error in disk firmware update scripts
-------------------------------------------------

Tracing the firmware update scripts always show the error *CPINIT: file not found* at the following line in the script::

     #if a CPINIT script exists, source it in
     if test -f CPINIT; then
     {
         . CPINIT
     }
     fi

The line in error is the *sourcing* of the file component ``CPINIT`` (the shell command "." is equivalent to the command "source", see *man bash*).
According to the bash_ manual page, the *source* command will only search the PATH variable for locations of the file to read, unless the file contains the "/" character, or if bash_ is running in *non-POSIX* mode.
The correct script programming would replace the above line by::

  . ./CPINIT

(yes, it's that simple!).

.. _bash: http://en.wikipedia.org/wiki/Bash

LO100 firmware upgrade
======================

The HP Lights-Out 100 (LO100) Remote Management: LO100_ firmware upgrade 
`version 4.23 (6 Mar 2012) <http://h20000.www2.hp.com/bizsupport/TechSupport/SoftwareDescription.jsp?lang=en&cc=us&prodTypeId=15351&prodSeriesId=3884343&prodNameId=3884344&swEnvOID=4004&swLang=8&mode=2&taskId=135&swItem=MTX-902ae2105fdb4e45a6ad1365f5>`_ fails on RHEL6::

  # ./CP017117.scexe
  ./hpsetup: line 2: .: lo100.sh: file not found
  Parameters are: --source /root
  ./hpsetup: line 7: lo100main: command not found

The best workaround is to add "." (current working directory) to your path before executing HP's firmware update script::

  export PATH=$PATH:.

See also these webpages (in Japanese): http://jfut.integ.jp/2012/03/18/update-hp-firmware-error-on-rhel6/ and 
http://jfut.integ.jp/2012/04/20/update-hp-firmware-error-on-rhel6-another/.

Programming error in LO100 firmware update scripts
--------------------------------------------------

Unpacking the LO100 firmware update scripts::

  ./CP017117.scexe --unpack=setup

creates a subdirectory ``setup`` containing some script files.
Line 2 of the script ``hpsetup`` contains the erroneous line::

  . lo100.sh

Changing line 2 into::

  . ./lo100.sh

corrects the error, and you can execute successfully the ``hpsetup`` script to update the LO100 firmware.
Just as for the disk firmware scripts, the problem is that the script ``lo100.sh`` is **not** in the shell's PATH.

Correct usage of the bash source command
========================================

To understand why it is required to source files using the relative file path in bash_, for example, 
``./CPINIT`` in stead of just the file name ``CPINIT``, please read the analysis below.

As a simple reproducer of the above error I have attached two tiny scripts CPtest.scexe__ and CPINIT__ which mimic the error in CP016469.scexe. 
Please save these scripts to the same working directory on an RHEL system and invoke them as follows::

  # sh CPtest.scexe
  CPtest.scexe: line 4: .: CPINIT: file not found
  ERROR sourcing script CPINIT

__ attachment:CPtest.scexe
__ attachment:CPINIT

This table shows the results of invoking CPtest.scexe in different ways on RHEL5 and RHEL6 systems::

  Invocation:                RHEL5 result    RHEL6 result
  -----------------          ------------    ------------
  sh CPtest.scexe            SUCCESS         ERROR
  bash CPtest.scexe          SUCCESS         SUCCESS
  bash --posix CPtest.scexe  SUCCESS         ERROR
  ./CPtest.scexe             SUCCESS         SUCCESS

The reason why some invocations have an ERROR can be learned from the bash_ manual-page ("man bash") under the SHELL BUILTIN COMMANDS section::

  .  filename [arguments]
  source filename [arguments]
  Read and execute commands from filename in the current shell environment and return the exit status of the last command executed from filename.  If filename does not contain a slash, file names in PATH are used to find the directory containing filename.  The file searched for in PATH need not be executable. When bash is not in posix mode, the current directory is searched if no file is found in PATH.

and furthermore in the section INVOCATION it is explained how scripts may run in POSIX_ mode::

  When invoked as sh, bash enters posix mode after the startup files are read.

.. _POSIX: http://www.gnu.org/software/bash/manual/html_node/Bash-POSIX-Mode.html

**Summary:** In POSIX_ mode (for example, when bash_ is invoked as the command ``sh``) the *source* command must only look for files in the shell's PATH and **not** in the current working directory!

Conclusions
-----------

1. It is obvious from the bash_ manual page that the script to be sourced (for example, CPINIT) is **required** to be in the shell's PATH whenever the bash_ shell runs in POSIX_ mode.
   This explains why the above workaround of appending the current directory "." to PATH works correctly!!

2. The bash_ shell, when invoked as ``sh``, is always running in POSIX_ mode.

3. The bash_ shell on RHEL5, when running in POSIX_ mode, **erroneously** sources the script files (for example, CPINIT) from the current directory in contradiction with the bash_ manual page.
   The fact that HP firmware update scripts can be invoked as ``sh CP016469.scexe`` on RHEL5 systems is therefore due to a **bug** in the bash_ shell version 3.2 on RHEL5 systems!

The *sourcing* bug in bash_ version 3.2 has been fixed according to the bash_ version 4.1 ``ChangeLog`` file::

  general.c
          - change posix_initialize to turn off source/. searching $PWD when 
            the file sourced is not found in $PATH.  Fixes bug reported by
            Paolo Bonzini <bonzini@gnu.org> and Eric Blake <ebb9@byu.net>

Owing to this bug fix, HP's firmware scripts may fail as described above.
