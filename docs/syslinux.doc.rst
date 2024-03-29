.. _syslinux.doc:

============
syslinux.doc
============

Version: syslinux-3.35 (update?)

.. Contents::

SYSLINUX
========

A suite of bootloaders for Linux

Copyright (C) 1994-2005 H. Peter Anvin

This program is provided under the terms of the GNU General Public
License, version 2 or, at your option, any later version.  There is no
warranty, neither expressed nor implied, to the function of this
program.  Please see the included file COPYING for details.

----------------------------------------------------------------------

      SYSLINUX now has a home page at http://syslinux.zytor.com/

----------------------------------------------------------------------

The SYSLINUX suite contains the following boot loaders
("derivatives"), for their respective boot media::

        SYSLINUX - MS-DOS/Windows FAT filesystem
        PXELINUX - PXE network booting
        ISOLINUX - ISO9660 CD-ROM
        EXTLINUX - Linux ext2/ext3 filesystem

For historical reasons, some of the sections in this document applies
to the FAT loader only; see pxelinux.doc, isolinux.doc and
extlinux.doc for what differs in these versions.

Help with cleaning up the docs would be greatly appreciated.


CREATING A BOOTABLE LINUX FLOPPY
================================

In order to create a bootable Linux floppy using SYSLINUX, prepare a
normal MS-DOS formatted floppy.  Copy one or more Linux kernel files to
it, then execute the DOS command::

        syslinux [-sfma][-d directory] a:

(or whichever drive letter is appropriate; the [] meaning optional.)

Use "syslinux.com" (in the dos subdirectory of the distribution) for
plain DOS (MS-DOS, DR-DOS, PC-DOS, FreeDOS...) or Win9x/ME.

Use "syslinux.exe" (in the win32 subdirectory of the distribution) for
WinNT/2000/XP.

Under Linux, execute the command::

        syslinux [-sf][-d directory][-o offset] /dev/fd0

(or, again, whichever device is the correct one.)

This will alter the boot sector on the disk and copy a file named
LDLINUX.SYS into its root directory (or a subdirectory, if the -d
option is specified.)

The -s option, if given, will install a "safe, slow and stupid"
version of SYSLINUX.  This version may work on some very buggy BIOSes
on which SYSLINUX would otherwise fail.  If you find a machine on
which the -s option is required to make it boot reliably, please send
as much info about your machine as you can, and include the failure
mode.

The -o option is used with a disk image file and specifies the byte
offset of the filesystem image in the file.

For the DOS and Windows installers, the -m and -a options can be used
on hard drives to write a Master Boot Record (MBR), and to mark the
specific partition active.

On boot time, by default, the kernel will be loaded from the image named
LINUX on the boot floppy.  This default can be changed, see the section
on the SYSLINUX config file.

If the Shift or Alt keys are held down during boot, or the Caps or Scroll
locks are set, SYSLINUX will display a LILO-style "boot:" prompt.  The
user can then type a kernel file name followed by any kernel parameters.
The SYSLINUX loader does not need to know about the kernel file in
advance; all that is required is that it is a file located in the root
directory on the disk.

There are two versions of the Linux installer; one in the "mtools"
directory which requires no special privilege (other than write
permission to the device where you are installing) but requires the
mtools program suite to be available, and one in the "unix" directory
which requires root privilege.


CONFIGURATION FILE
==================

All the configurable defaults in SYSLINUX can be changed by putting a
file called "syslinux.cfg" in the root directory of the boot disk.

This is a text file in either UNIX or DOS format, containing one or
more of the following items (case is insensitive for keywords; upper
case is used here to indicate that a word should be typed verbatim):

Starting with version 3.35, the configuration file can also be in
either the /boot/syslinux or /syslinux directories (searched in that
order.)  If that is the case, then all filenames are assumed to be
relative to that same directory, unless preceded with a slash or
backslash.

All options here applies to PXELINUX, ISOLINUX and EXTLINUX as well as
SYSLINUX unless otherwise noted.  See the respective .doc files:

# comment
---------

        A comment line.  The whitespace after the hash mark is mandatory.

DEFAULT kernel options
----------------------

        Sets the default command line.  If SYSLINUX boots automatically,
        it will act just as if the entries after DEFAULT had been typed
        in at the "boot:" prompt.

        If no configuration file is present, or no DEFAULT entry is
        present in the config file, the default is "linux auto".

        NOTE: Earlier versions of SYSLINUX used to automatically
        append the string "auto" to whatever the user specified using
        the DEFAULT command.  As of version 1.54, this is no longer
        true, as it caused problems when using a shell as a substitute
        for "init."  You may want to include this option manually.

APPEND options
--------------

        Add one or more options to the kernel command line.  These are
        added both for automatic and manual boots.  The options are
        added at the very beginning of the kernel command line,
        usually permitting explicitly entered kernel options to override
        them.  This is the equivalent of the LILO "append" option.

IPAPPEND flag_val [PXELINUX only]
---------------------------------

        The IPAPPEND option is available only on PXELINUX.  The
        flag_val is an OR of the following options:

        1: indicates that an option of the following format
        should be generated and added to the kernel command line::

                ip=<client-ip>:<boot-server-ip>:<gw-ip>:<netmask>

        ... based on the input from the DHCP/BOOTP or PXE boot server.

        THE USE OF THIS OPTION IS NOT RECOMMENDED.  If you have to use
        it, it is probably an indication that your network configuration
        is broken.  Using just "ip=dhcp" on the kernel command line
        is a preferrable option, or, better yet, run dhcpcd/dhclient,
        from an initrd if necessary.

        2: indicates that an option of the following format
        should be generated and added to the kernel command line::

                BOOTIF=<hardware-address-of-boot-interface>

        ... in dash-separated hexadecimal with leading hardware type
        (same as for the configuration file; see pxelinux.doc.)

        This allows an initrd program to determine from which
        interface the system booted.

LABEL label
-----------

  KERNEL image

  APPEND options...

  IPAPPEND flag_val                     [PXELINUX only]

        Indicates that if "label" is entered as the kernel to boot,
        SYSLINUX should instead boot "image", and the specified APPEND
        and IPAPPEND options should be used instead of the ones
        specified in the global section of the file (before the first
        LABEL command.)  The default for "image" is the same as
        "label", and if no APPEND is given the default is to use the
        global entry (if any).

        Starting with version 2.20, LABEL statements are compressed
        internally, therefore the maximum number of LABEL statements
        depends on their complexity.  Typical is around 600.  SYSLINUX
        will print an error message if the internal memory for labels
        is overrun.

        Note that LILO uses the syntax::

          image = mykernel
            label = mylabel
            append = "myoptions"

        ... whereas SYSLINUX uses the syntax::

          label mylabel
            kernel mykernel
            append myoptions

        Note: The "kernel" doesn't have to be a Linux kernel; it can
        be a boot sector or a COMBOOT file (see below.)

        Since version 3.32 label names are no longer mangled into DOS
        format (for SYSLINUX.)

  APPEND -

        Append nothing.  APPEND with a single hyphen as argument in a
        LABEL section can be used to override a global APPEND.

  LOCALBOOT type                        [ISOLINUX, PXELINUX]

        On PXELINUX, specifying "LOCALBOOT 0" instead of a "KERNEL"
        option means invoking this particular label will cause a local
        disk boot instead of booting a kernel.

        The argument 0 means perform a normal boot.  The argument 4
        will perform a local boot with the Universal Network Driver
        Interface (UNDI) driver still resident in memory.  Finally,
        the argument 5 will perform a local boot with the entire PXE
        stack, including the UNDI driver, still resident in memory.
        All other values are undefined.  If you don't know what the
        UNDI or PXE stacks are, don't worry -- you don't want them,
        just specify 0.

        On ISOLINUX, the "type" specifies the local drive number to
        boot from; 0x00 is the primary floppy drive and 0x80 is the
        primary hard drive.  The special value -1 causes ISOLINUX to
        report failure to the BIOS, which, on recent BIOSes, should
        mean that the next boot device in the boot sequence should be
        activated.

IMPLICIT flag_val
-----------------

        If flag_val is 0, do not load a kernel image unless it has been
        explicitly named in a LABEL statement.  The default is 1.

ALLOWOPTIONS flag_val
---------------------

        If flag_val is 0, the user is not allowed to specify any
        arguments on the kernel command line.  The only options
        recognized are those specified in an APPEND statement.  The
        default is 1.

TIMEOUT timeout
---------------

        Indicates how long to wait at the boot: prompt until booting
        automatically, in units of 1/10 s.  The timeout is cancelled as
        soon as the user types anything on the keyboard, the assumption
        being that the user will complete the command line already
        begun.  A timeout of zero will disable the timeout completely,
        this is also the default.

TOTALTIMEOUT timeout
--------------------

        Indicates how long to wait until booting automatically, in
        units of 1/10 s.  This timeout is *not* cancelled by user
        input, and can thus be used to deal with serial port glitches
        or "the user walked away" type situations.  A timeout of zero
        will disable the timeout completely, this is also the default.

        Both TIMEOUT and TOTALTIMEOUT can be used together, for
        example::

                # Wait 5 seconds unless the user types something, but
                # always boot after 15 minutes.
                TIMEOUT 50
                TOTALTIMEOUT 9000

ONTIMEOUT kernel options
------------------------

        Sets the command line invoked on a timeout.  Normally this is
        the same thing as invoked by "DEFAULT".  If this is specified,
        then "DEFAULT" is used only if the user presses <Enter> to
        boot.

ONERROR kernel options
----------------------

        If a kernel image is not found (either due to it not existing,
        or because IMPLICIT is set), run the specified command.  The
        faulty command line is appended to the specified options, so
        if the ONERROR directive reads as::

                ONERROR xyzzy plugh

        ... and the command line as entered by the user is::

                foo bar baz

        ... SYSLINUX will execute the following as if entered by the
        user::

                xyzzy plugh foo bar baz

SERIAL port [[baudrate] flowcontrol]
------------------------------------

        Enables a serial port to act as the console.  "port" is a
        number (0 = /dev/ttyS0 = COM1, etc.) or an I/O port address
        (e.g. 0x3F8); if "baudrate" is omitted, the baud rate defaults
        to 9600 bps.  The serial parameters are hardcoded to be 8
        bits, no parity, 1 stop bit.

        "flowcontrol" is a combination of the following bits::

          0x001 - Assert DTR
          0x002 - Assert RTS
          0x010 - Wait for CTS assertion
          0x020 - Wait for DSR assertion
          0x040 - Wait for RI assertion
          0x080 - Wait for DCD assertion
          0x100 - Ignore input unless CTS asserted
          0x200 - Ignore input unless DSR asserted
          0x400 - Ignore input unless RI asserted
          0x800 - Ignore input unless DCD asserted

        All other bits are reserved.

        Typical values are::

              0 - No flow control (default)
          0x303 - Null modem cable detect
          0x013 - RTS/CTS flow control
          0x813 - RTS/CTS flow control, modem input
          0x023 - DTR/DSR flow control
          0x083 - DTR/DCD flow control

        For the SERIAL directive to be guaranteed to work properly, it
        should be the first directive in the configuration file.

        NOTE: "port" values from 0 to 3 means the first four serial
        ports detected by the BIOS.  They may or may not correspond to
        the legacy port values 0x3F8, 0x2F8, 0x3E8, 0x2E8.

CONSOLE flag_val
----------------

        If flag_val is 0, disable output to the normal video console.
        If flag_val is 1, enable output to the video console (this is
        the default.)

        Some BIOSes try to forward this to the serial console and
        sometimes make a total mess thereof, so this option lets you
        disable the video console on these systems.

FONT filename
-------------

        Load a font in .psf format before displaying any output
        (except the copyright line, which is output as ldlinux.sys
        itself is loaded.)  SYSLINUX only loads the font onto the
        video card; if the .psf file contains a Unicode table it is
        ignored.  This only works on EGA and VGA cards; hopefully it
        should do nothing on others.

KBDMAP keymap
-------------

        Install a simple keyboard map.  The keyboard remapper used is
        *very* simplistic (it simply remaps the keycodes received from
        the BIOS, which means that only the key combinations relevant
        in the default layout -- usually U.S. English -- can be
        mapped) but should at least help people with AZERTY keyboard
        layout and the locations of = and , (two special characters
        used heavily on the Linux kernel command line.)

        The included program keytab-lilo.pl from the LILO distribution
        can be used to create such keymaps.  The file keytab-lilo.doc
        contains the documentation for this program.

DISPLAY filename
----------------

        Displays the indicated file on the screen at boot time (before
        the boot: prompt, if displayed).  Please see the section below
        on DISPLAY files.

        NOTE: If the file is missing, this option is simply ignored.

SAY message
-----------

        Prints the message on the screen.

PROMPT flag_val
---------------

        If flag_val is 0, display the boot: prompt only if the Shift or Alt
        key is pressed, or Caps Lock or Scroll lock is set (this is the
        default).  If flag_val is 1, always display the boot: prompt.

NOESCAPE flag_val
-----------------

        If flag_val is set to 1, ignore the Shift/Alt/Caps Lock/Scroll
        Lock escapes.  Use this (together with PROMPT 0) to force the
        default boot alternative.

Fn buttons
----------

  F1 filename

  F2 filename

  ...etc...

  F9 filename

  F0 filename

        Displays the indicated file on the screen when a function key is
        pressed at the boot: prompt.  This can be used to implement
        pre-boot online help (presumably for the kernel command line
        options.)  Note that F10 MUST be entered in the config file as
        "F0", not "F10", and that there is currently no way to bind
        file names to F11 and F12.  Please see the section below on
        DISPLAY files.

        When using the serial console, press <Ctrl-F><digit> to get to
        the help screens, e.g. <Ctrl-F><2> to get to the F2 screen,
        and <Ctrl-F><0> for the F10 one.

Blank lines are ignored.

Note that the configuration file is not completely decoded.  Syntax
different from the one described above may still work correctly in this
version of SYSLINUX, but may break in a future one.


DISPLAY FILE FORMAT
===================

DISPLAY and function-key help files are text files in either DOS or UNIX
format (with or without <CR>).  In addition, the following special codes
are interpreted:

<FF>                                    <FF> = <Ctrl-L> = ASCII 12

        Clear the screen, home the cursor.  Note that the screen is
        filled with the current display color.

<SI><bg><fg>                            <SI> = <Ctrl-O> = ASCII 15

        Set the display colors to the specified background and
        foreground colors, where <bg> and <fg> are hex digits,
        corresponding to the standard PC display attributes::

          0 = black               8 = dark grey
          1 = dark blue           9 = bright blue
          2 = dark green          a = bright green
          3 = dark cyan           b = bright cyan
          4 = dark red            c = bright red
          5 = dark purple         d = bright purple
          6 = brown               e = yellow
          7 = light grey          f = white

        Picking a bright color (8-f) for the background results in the
        corresponding dark color (0-7), with the foreground flashing.

        Colors are not visible over the serial console.

<CAN>filename<newline>                  <CAN> = <Ctrl-X> = ASCII 24

        If a VGA display is present, enter graphics mode and display
        the graphic included in the specified file.  The file format
        is an ad hoc format called LSS16; the included Perl program
        "ppmtolss16" can be used to produce these images.  This Perl
        program also includes the file format specification.

        The image is displayed in 640x480 16-color mode.  Once in
        graphics mode, the display attributes (set by <SI> code
        sequences) work slightly differently: the background color is
        ignored, and the foreground colors are the 16 colors specified
        in the image file.  For that reason, ppmtolss16 allows you to
        specify that certain colors should be assigned to specific
        color indicies.

        Color indicies 0 and 7, in particular, should be chosen with
        care: 0 is the background color, and 7 is the color used for
        the text printed by SYSLINUX itself.

<EM>                                    <EM> = <Ctrl-Y> = ASCII 25

        If we are currently in graphics mode, return to text mode.

<DLE>..<ETB>                            <Ctrl-P>..<Ctrl-W> = ASCII 16-23

        These codes can be used to select which modes to print a
        certain part of the message file in.  Each of these control
        characters select a specific set of modes (text screen,
        graphics screen, serial port) for which the output is actually
        displayed::

          Character                       Text    Graph   Serial
          ------------------------------------------------------
          <DLE> = <Ctrl-P> = ASCII 16     No      No      No
          <DC1> = <Ctrl-Q> = ASCII 17     Yes     No      No
          <DC2> = <Ctrl-R> = ASCII 18     No      Yes     No
          <DC3> = <Ctrl-S> = ASCII 19     Yes     Yes     No
          <DC4> = <Ctrl-T> = ASCII 20     No      No      Yes
          <NAK> = <Ctrl-U> = ASCII 21     Yes     No      Yes
          <SYN> = <Ctrl-V> = ASCII 22     No      Yes     Yes
          <ETB> = <Ctrl-W> = ASCII 23     Yes     Yes     Yes

        For example::

        <DC1>Text mode<DC2>Graphics mode<DC4>Serial port<ETB>

        ... will actually print out which mode the console is in!

<SUB>                                   <SUB> = <Ctrl-Z> = ASCII 26

        End of file (DOS convention).

<BEL>                                   <BEL> = <Ctrl-G> = ASCII 7

        Beep the speaker.


COMMAND LINE KEYSTROKES
=======================

The command line prompt supports the following keystrokes::

  <Enter>         boot specified command line
  <BackSpace>     erase one character
  <Ctrl-U>        erase the whole line
  <Ctrl-V>        display the current SYSLINUX version
  <Ctrl-W>        erase one word
  <Ctrl-X>        force text mode
  <F1>..<F10>     help screens (if configured)
  <Ctrl-F><digit> equivalent to F1..F10
  <Ctrl-C>        interrupt boot in progress
  <Esc>           interrupt boot in progress


COMBOOT IMAGES AND OTHER OPERATING SYSTEMS
==========================================

This version of SYSLINUX supports chain loading of other operating
systems (such as MS-DOS and its derivatives, including Windows 95/98),
as well as COMBOOT-style standalone executables (a subset of DOS .COM
files; see separate section below.)

Chain loading requires the boot sector of the foreign operating system
to be stored in a file in the root directory of the filesystem.
Because neither Linux kernels, boot sector images, nor COMBOOT files
have reliable magic numbers, SYSLINUX will look at the file extension.
The following extensions are recognized (case insensitive)::

  none or other Linux kernel image
  .0            PXE bootstrap program (NBP) [PXELINUX only]
  .bin          "CD boot sector" [ISOLINUX only]
  .bs           Boot sector [SYSLINUX only]
  .bss          Boot sector, DOS superblock will be patched in [SYSLINUX only]
  .c32          COM32 image (32-bit COMBOOT)
  .cbt          COMBOOT image (not runnable from DOS)
  .com          COMBOOT image (runnable from DOS)
  .img          Disk image [ISOLINUX only]

For filenames given on the command line, SYSLINUX will search for the
file by adding extensions in the order listed above if the plain
filename is not found.  Filenames in KERNEL statements must be fully
qualified.


BOOTING DOS (OR OTHER SIMILAR OPERATING SYSTEMS)
================================================

This section applies to SYSLINUX only, not to PXELINUX or ISOLINUX.
See isolinux.doc for an equivalent procedure for ISOLINUX.

This is the recommended procedure for creating a SYSLINUX disk that
can boot either DOS or Linux.  This example assumes the drive is A: in
DOS and /dev/fd0 in Linux; for other drives, substitute the
appropriate drive designator.

Linux procedure
---------------

1. Make a DOS bootable disk.  This can be done either by specifying
   the /s option when formatting the disk in DOS, or by running the
   DOS command SYS (this can be done under DOSEMU if DOSEMU has
   direct device access to the relevant drive)::

        format a: /s

   or::

        sys a:

2. Boot Linux.  Copy the DOS boot sector from the disk into a file::

        dd if=/dev/fd0 of=dos.bss bs=512 count=1

3. Run SYSLINUX on the disk::

        syslinux /dev/fd0

4. Mount the disk and copy the DOS boot sector file to it.  The file
   *must* have extension .bss::

        mount -t msdos /dev/fd0 /mnt
        cp dos.bss /mnt

5. Copy the Linux kernel image(s), initrd(s), etc to the disk, and
   create/edit syslinux.cfg and help files if desired::

        cp vmlinux /mnt
        cp initrd.gz /mnt

6. Unmount the disk (if applicable.)::

        umount /mnt

DOS/Windows procedure
---------------------

To make this installation in DOS only, you need the utility copybs.com
(included with SYSLINUX) as well as the syslinux.com installer.  If
you are on an WinNT-based system (WinNT, Win2k, WinXP or later), use
syslinux.exe instead:

1. Make a DOS bootable disk.  This can be done either by specifying
   the /s option when formatting the disk in DOS, or by running the
   DOS command SYS::

        format a: /s

   or::

        sys a:

2. Copy the DOS boot sector from the disk into a file.  The file
   *must* have extension .bss::

        copybs a: a:dos.bss

3. Run SYSLINUX on the disk::

        syslinux a:

4. Copy the Linux kernel image(s), initrd(s), etc to the disk, and
   create/edit syslinux.cfg and help files if desired::

        copy vmlinux a:
        copy initrd.gz a:


COMBOOT EXECUTABLES
===================

SYSLINUX supports simple standalone programs, using a file format
similar to DOS ".com" files.  A 32-bit version, called COM32, is also
provided.  A simple API provides access to a limited set of filesystem
and console functions.

See the file comboot.doc for more information on COMBOOT and COM32
programs.


NOVICE PROTECTION
=================

SYSLINUX will attempt to detect booting on a machine with too little
memory, which means the Linux boot sequence cannot complete.  If so, a
message is displayed and the boot sequence aborted.  Holding down the
Ctrl key while booting disables this feature.

Any file that SYSLINUX uses can be marked hidden, system or readonly
if so is convenient; SYSLINUX ignores all file attributes.  The
SYSLINUX installed automatically sets the readonly/hidden/system
attributes on LDLINUX.SYS.


NOTES ON BOOTABLE CD-ROMS
=========================

SYSLINUX can be used to create bootdisk images for El
Torito-compatible bootable CD-ROMs.  However, it appears that many
BIOSes are very buggy when it comes to booting CD-ROMs.  Some users
have reported that the following steps are helpful in making a CD-ROM
that is bootable on the largest possible number of machines:

        a) Use the -s (safe, slow and stupid) option to SYSLINUX;
        b) Put the boot image as close to the beginning of the
           ISO 9660 filesystem as possible.

A CD-ROM is so much faster than a floppy that the -s option shouldn't
matter from a speed perspective.

Of course, you probably want to use ISOLINUX instead.  See isolinux.doc.


BOOTING FROM A FAT FILESYSTEM PARTITION ON A HARD DISK
======================================================

SYSLINUX can boot from a FAT filesystem partition on a hard disk
(including FAT32).  The installation procedure is identical to the
procedure for installing it on a floppy, and should work under either
DOS or Linux.  To boot from a partition, SYSLINUX needs to be launched
from a Master Boot Record or another boot loader, just like DOS itself
would.

Under DOS, you can install a standard simple MBR on the primary hard
disk by running the command::

        FDISK /MBR

Then use the FDISK command to mark the appropriate partition active.

A simple MBR, roughly on par with the one installed by DOS (but
unencumbered), is included in the SYSLINUX distribution.  To install
it under Linux, simply type::

        cat mbr.bin > /dev/XXX

... where /dev/XXX is the device you wish to install it on.

Under DOS or Win32, you can install the SYSLINUX MBR with the -m
option to the SYSLINUX installer, and use the -a option to mark the
current partition active::

        syslinux -ma c:

Note that this will also install SYSLINUX on the specified partition.


HARDWARE INFORMATION
====================

I have started to maintain a web page of hardware with known
problems.  There are, unfortunately, lots of broken hardware out
there; especially early PXE stacks (for PXELINUX) have lots of
problems.

A list of problems, and workarounds (if known), is maintained at:

        http://syslinux.zytor.com/hardware.php


BOOT LOADER IDS USED
====================

The Linux boot protocol supports a "boot loader ID", a single byte
where the upper nybble specifies a boot loader family (3 = SYSLINUX)
and the lower nybble is version or, in the case of SYSLINUX, media::

        0x31 (49) = SYSLINUX
        0x32 (50) = PXELINUX
        0x33 (51) = ISOLINUX
        0x34 (52) = EXTLINUX

In recent versions of Linux, this ID is available as
/proc/sys/kernel/bootloader_type.


BUG REPORTS

I would appreciate hearing of any problems you have with SYSLINUX.  I
would also like to hear from you if you have successfully used SYSLINUX,
*especially* if you are using it for a distribution.

If you are reporting problems, please include all possible information
about your system and your BIOS; the vast majority of all problems
reported turn out to be BIOS or hardware bugs, and I need as much
information as possible in order to diagnose the problems.

There is a mailing list for discussion among SYSLINUX users and for
announcements of new and test versions.  To join, or to browse the
archive, go to:

   http://www.zytor.com/mailman/listinfo/syslinux

Please DO NOT send HTML messages or attachments to the mailing list
(including multipart/alternative or similar.)  All such messages will
be bounced.
