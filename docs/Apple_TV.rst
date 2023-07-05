.. _Apple_TV:

==========================
Apple TV for meeting rooms
==========================

.. Contents::

Apple's `Apple TV media player <https://en.wikipedia.org/wiki/Apple_TV>`_  is a small network appliance and entertainment device 
that can receive digital data from a number of sources and stream it to a capable TV for playing on the TV screen.

With the `4th generation Apple TV <http://www.apple.com/tv/specs/>`_ you can also mirror your not-too-old MacBook, iPad or iPhone screens onto the TV.
A Windows PC or older Macs can be mirrored as well if you buy additional software (see below).

.. _TV: http://www.apple.com/tv/experience/

This page describes the use of multiple Apple TV_ units on a university-wide campus network at DTU_, mainly used for presentation purposes in meeting rooms and in offices.

.. _DTU: http://www.dtu.dk

Setting up a new Apple TV
=========================

Connect the Apple TV_ to a TV screen using a HDMI cable, and connect to your cabled Ethernet.
Then connect the power cable.

The initial setup of the Apple TV_:

* **Requires network access** in order to complete.
* First connect the Apple TV_ to cabled Ethernet.
* If the device must be authorized in DHCP, discover its MAC-address in the DHCP server's log files (the MAC address can be verified on the Apple TV_ after installation has been completed).
* Select language.
* Select *Manual setup*.
* **Do not** enter any Apple_ID_ when asked, but select **Skip this step**.
  You may enter your Apple_ID_ during setup if this is a personal TV_ device.

Further configuration
---------------------

In the |Settings| **Settings app**:

* Make sure to update the Apple TV_ software immediately in the *System->Software Updates* menu.
* Verify the system version etc. in the *General->About* menu.
* Verify the currently active network settings (Ethernet or WiFi_) in the *System->Network* menu.
* Select the AirPlay_ item and configure the **Apple TV Name** (the default name is *Apple TV*).

  It is recommended that you use a descriptive name such as the location of the Apple TV_, for example: **B345-123**.

.. |Settings| image:: attachments/Settings.png

Connect to the WiFi network
---------------------------

Once the Apple TV_ has been set up using cabled Ethernet, you may connect it to your WiFi_ network.
First disconnect the Ethernet cable.

In the |Settings| **Settings app**:

* Go to *Network* and select the *Wi-Fi* menu.
* A list of available WiFi_ networks will be presented.
* Select the desired network and enter its password.

.. _WiFi: https://en.wikipedia.org/wiki/Wi-Fi

DTU device WiFi network
.......................

At DTU_ your Apple TV_ should be connected to the *device* WiFi_ network.
Send the MAC-address of the Apple TV_ to the *AIT Helpdesk* and request it to be registered.

.. _Apple_ID: https://en.wikipedia.org/wiki/Apple_ID

Screen mirrroring
=================

With with AirPlay_ Mirroring_, you can "mirror" (display a copy of) your iOS or Mac device screen onto your Apple TV_ screen.

.. _AirPlay: https://en.wikipedia.org/wiki/AirPlay
.. _Mirroring: https://support.apple.com/en-us/HT204289

There are some useful pages about this feature:

* `How to Mirror your Mac or iOS Screen to Your Apple TV <http://www.howtogeek.com/213990/how-to-mirror-your-mac-or-ios-screen-to-your-apple-tv/>`_.

* `AirPlay from imore <http://www.imore.com/airplay-iphone-ipad>`_

Using AirPlay from Windows PCs or older Macs
--------------------------------------------

Older Macs are not compatible with AirPlay_, see:

* `AirPlay Mirroring compatibility <http://www.imore.com/how-airplay-mirror-your-mac-screen-your-apple-tv>`_.
* `The Real Reason Why Macs Before 2011 Can’t Use AirPlay Mirroring In Mountain Lion  <http://www.cultofmac.com/178460/the-real-reason-why-macs-before-2011-cant-use-airplay-mirroring-in-mountain-lion-feature/>`_.

Windows PCs as well as older Macs will require a software solution to work with AirPlay_.
The following software will do this:

* AirParrot_ 2 (with a free 7-day trial).
* 5KPlayer_

.. _AirParrot: http://www.airsquirrels.com/airparrot
.. _5KPlayer: http://www.5kplayer.com/airplay/5kplayer-apple-tv-mirroring.htm

Protecting Apple TV against rogue users
=======================================

If your wireless network hosting the Apple TV_ contains many users, as is the case on a campus-wide WiFi_ network, everyone will potentially be able to use AirPlay_ to take over your TV_!

**Problem:** 

* You want guests to be able to use the Apple TV_ easily, but you do not want pranksters to send images to your Apple TV_ from elsewhere.  
* In particular, you do not want your presentations to be interrupted by other people connecting to your TV_.  
* On the other hand, if someone forgets to disconnect from the TV_, you want to be able to kick them off.  

AirPlay_ settings are configured in the Apple TV_ **Settings** app under the AirPlay_ menu item.
The *Access Control* functional settings are `almost entirely undocumented <https://support.apple.com/en-us/HT202618>`_ by Apple, 
and are quite complex to configure to achieve your desired security level.
At this time, the correct *Access Control* settings must be determined by experiment!

Important Access Control settings
---------------------------------

Open the |Settings| **Settings** app (this is for TvOS version 11).
The **AirPlay** item has an **AirPlay** sub-heading with important **Security** items whose recommended settings are:

* **Require Code: Every Time**

These settings are explained in detail below:

Require Device Verification
...........................

* **Require Device Verification: Off**

  This setting should definitely be set to **Off**.

* **Require Device Verification: On**

  If you choose the *On* setting, it will cause two unrelated effects, but the help text does not document it properly:

  - Firstly, it makes   *Security: None* behave almost like *Security: Passcode*.

  - Secondly, it makes the Apple TV_ check software versions of all devices attempting to connect to it (possibly also other devices it sees on the net).
    Older devices and AirParrot_ devices trigger an error message on the Apple TV_.
    *These error messages will interrupt presentations!*

  Therefore it is very important to turn this setting *Off*.

Security
........

.. _Remote: https://www.apple.com/support/appletv/remote/
  
* **Security: Passcode**

  **This is probably the best setting.**
  When accessing the Apple TV_, a four-digit passcode is displayed on the screen, and you have to type that on your device, thus proving that you are present in the same room.

  Once connected, you have exclusive access to the Apple TV_ and other people cannot connect to it.
  If somebody forgets to disconnect after their presentation, they can be forced to disconnect with the Apple TV_ Remote_ control unit (press **MENU**).
  Usually you can also just wait: after a minute of inactivity the AirPlay_ connection will be dropped.

* **Security: Password**.

  Probably **not a good idea**.
  We have not tested it yet, but it looks like if you set a password, anyone who has used the Apple TV_
  and thus learned the password can force a take-over of your Apple TV_ at any later time from **anywhere on the network**.

* **Security: None**

  Probably **not a good idea**.
  With this setting the security depends in an undocumented way on the above setting *Require Device Verification*.

  * If *Require Device Verification* is *Off*, your Apple TV_ is **completely open**.
    Anyone on DTU's wireless network can begin transmitting to your Apple TV_, by mistake or as a prank.

  * If *Require Device Verification* is on, then *Security: None* behaves almost like *Security: Passcode*.

    Your Apple TV_ is still protected by a passcode, but the main difference is that access to the Apple TV_ is **not exclusive**.

    While you are connected to the Apple TV_, other people *anywhere on the DTU wireless network* may attempt to connect as well.
    This will interrupt your presentation with a passcode being displayed on the screen.

    Of course, people who are not watching the Apple TV_ screen cannot type the passcode and take over the screen,
    but they will still **interrupt your presentation** with the passcode message.
    This *will* be triggered inadvertently by people elsewhere on the network selecting the wrong Apple TV_ by mistake.

If the TV turns on by itself
----------------------------

If the Apple TV is connected to a TV screen, you may have the problem that the sceen apparently turns on spontaneously.  
The screen will often be on in the morning, and may turn on during several times during the day, without anyone touching the TV remote or the panel controlling the TV screen.

This happens when the Apple TV is sleeping, and someone accidentally tries to connect to it from elsewhere on DTU.  
The Apple TV wakes up, and automaticaly wakes the screen.  
*Depending on your setup, this may be what you want, or it may be undesired.*

To turn this off, go to the |Settings| **Settings app**, choose "Remotes and Devices".  
Near the bottom under the *Home theater control* you can find the point:

* **Control TVs and Receivers: Off**

  Set this to Off to prevent the Apple TV from waking the TV screen.
