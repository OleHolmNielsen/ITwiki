Converting your DATA when upgrading MoinMoin
============================================

Post 1.5.3 new style migration
==============================

If you are migrating from a moin version older than 1.5.3, you first you have
to do all steps described in the sections below or it won't work.

After you have switched to new style migration, the procedure will be the same
with every moin upgrade, simply follow these steps:

  a) First switch to the user of your data directory (www-data normally):
      e. g. sudo -u www-data sh
      or su www-data

  b) Invoke the following command:
      moin --config-dir=/path/to/config_dir --wiki-url=wiki.example.org/ migration data 

      Note: If you did not use setup.py, you can call the moin script directly. It is
      located in MoinMoin/script/moin.py

The new style mig stuff will then load the config for that wiki, get into its
data_dir, read the meta file content and determine what it has to do internally.

1.5.3 migration
===============

First make sure you have run all the old mig scripts ONCE (and only once) on
your data dirs.

The old style stuff moved here: MoinMoin/script/old/migration/

In that directory, there is also a new 152_to_1050300.py mig script - you
need to run it as the last mig script to switch to new style mig scripts.
It puts a file "meta" in your data dirs that hold the data_format_revision
value. The new style mig scripts use that value to make it much simpler for
you in future.

After this, please continue in section "Post 1.5.3 new style migration".

1.3.4/1.3.5 migration
=====================
We added some mig scripts in moin 1.3.4. So if you have done the 1.2 to 1.3
migration with some earlier moin version (like 1.3.3), then please run the
new scripts, too:
 * 12_to_13_mig10.py
 * 12_to_13_mig11.py

1.2 to 1.3 migration
====================

Migration from 1.2 to 1.3 is done by those basic steps:
 1. make a backup
 2. install new moin code
 3. install new moin.cgi (if you use CGI) or other glue script
 4. install new moin static data (css, icons, etc.)
 5. convert your 1.2 data_dir using the migration scripts (see below)
 6. fix your configuration (begin with new sample config and modify as needed)
  * especially make sure that data_dir and data_underlay_dir is correct


1. Making a backup
==================
Make a backup of your current stuff:
 * CONFIG: moin_config.py, maybe also some farmconfig if you run a wiki farm
   Also backup the moin.cgi script (if you use CGI) or other glue script.
 * CODE: backup your MoinMoin/ directory (see sys.path.append at start of
   moin.cgi or standard location like /usr/lib/python2.x/site-packages)
 * DATA: backup your data/ directory (see data_dir in moin_config.py) -
   this is the most important stuff: your wiki pages, your wiki user accounts
   etc. - you want to keep this for quite a while even if the migration looks
   successful.


2. + 3. + 4. Install new moin code, new moin.cgi script, new moin static data
=============================================================================

See INSTALL.html.


5. Converting your data/ directory
==================================

Scripts see MoinMoin/script/old/migration/12_to_13_migN.py (in your MoinMoin
code directory, e.g. /usr[/local]/lib/python2.x/site-packages/MoinMoin).

Those are some scripts that convert your wiki data to the current MoinMoin
version. You must use them AFTER stopping your old wiki code and BEFORE
starting your new wiki code.

Make sure you have enough free space on your hard disk (every mig script makes
a new copy, so you need N+1 times the space your data dir needs, if you do not
remove the pre-migX dirs after running migX script).

When upgrading, choose your entry point depending on your version:

 version you use         start with mig script
 ---------------------------------------------
 before 1.2              first upgrade to 1.2.4 and test for a while
 1.2.x                   mig01 - check from_encoding in script!
 1.3 <patch-78           mig02
 1.3 <patch-101          mig03
 1.3 <patch-196, =beta2  mig04
 1.3 <patch-221, =beta3  mig05
 1.3 <patch-248          mig06 - check from_encoding in script!
 1.3 <patch-275, =beta5  mig07
 1.3 <patch-305, =beta6  mig08
 1.3 <patch-332, =beta7  mig09
 1.3rc1                  -
 any later               mig10

 Modifying from_encoding setting in the scripts is necessary if your old moin
 installation did not use iso-8859-1 encoding (as it was the default in moin
 1.2.x and before. If you had changed that, e.g. to utf-8 or other encoding
 (see moin_config.py, charset = '...'), you need to change it in the mig
 scripts, too.

Of course, in the end you must have run ALL mig scripts once, in correct
order, the table is only to help your memory in case you forgot what you
have done already.

To start, copy your data/ directory to the directory where the migration
scripts are located and then start with the script according to the table
above and also run ALL scripts with a higher number - one after the other,
in ascending order.

After that, you should have a data/ directory suitable for new moin version.
Maybe some stuff that didn't need conversion is missing, see the comments on
top of the scripts for details.

Read the comments in the scripts for details, especially in mig5.

After conversion, maybe rename your old data/ dir in the original location to
data.12 (or similar) and copy your new data/ directory from the scripts
directory to that original location. Check permissions as the conversion
scripts have changed them (on UNIX: mode, owner, group, fix by chown -R and
chmod -R).

Note that the migration scripts only convert your data, they do NOT magically
convert your plugin scripts to new APIs of moin 1.3. So if your plugins do not
work any more, look out for updates compatible with 1.3.

Furthermore, they do not convert macro calls or other wiki markup which broke
because the parser was changed to conform to the documentation more intensely.
Especially check the calls to the search macros and look at HelpOnSearching.


6. Fix your configuration
=========================

1.3 configuration looks similar, but works quite different than 1.2 config.
1.3 uses a class based configuration, the easiest way to convert is maybe to
start from a fresh sample config and change it to fit your needs.

Please be careful about indentation, keep it the same way as in the samples!
If you add additional config items, indent them by the same amount.

Especially make sure that:
 * data_dir is really pointing to your converted data directory
 * data_underlay_dir is pointing to your underlay directory (just use a copy
   of the directory underlay/ in the moin distribution)
 * both directories have appropriate user, group and mode so that moin is
   able to access them.

See also HelpOnConfiguration page.


7. FAQ
======

Q: Wiki works, but it looks extremly simply styled. All simple blue text,
   no icons, all menu items look like simple text aligned to left border...

A: Access to /wiki is not working.
   Try accessing http://.../wiki/modern/img/moin-edit.png, that should show a
   small icon.
   Check your /wiki alias, web server configuration, file system rights
   directory where /wiki points to, etc. - see web server log for more info.

Q: I see a wiki, looks ok, but all pages are empty. I can't even create new
   pages.

A: This usually happens with an empty data/ directory and a non-working
   underlay directory. Check underlay_data_dir config.

Q: I only see my own pages, but no RecentChanges. I can't create new pages.

A: This is also a non-working underlay dir, see previous question.

If your question isn't answered by above FAQ, maybe just re-check following
items:
 * file system access rights. user, group, mode - can the running web server /
   moin code access all stuff needed?
 * is your web server allowed to access the "/wiki" directory with img and css?
   Some web server default configurations disallow access to most directories
   and you have to explicitely allow by a <Directory ...> section.
 * is your web server allowed to read and execute moin.cgi? Can you run another
   cgi script from same directory? Options +ExecCGI for Apache?
 * Is your Python at least v2.2.2?

If you still have problems, it is best to ask on our IRC channel #moin on
server irc.freenode.net.

