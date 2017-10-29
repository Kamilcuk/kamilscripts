# Monitor
http://www.benq.co.uk/product/monitor/gw2765ht


# DDC/CI

## Usage

```
ddccontrol -r 0x10 -w 10  dev:/dev/i2c-5 # btighensss 10 %
ddccontrol -r 0x10 -w 100 dev:/dev/i2c-5 # brightness 100 %
ddccontrol -r 0x12 -w 10  dev:/dev/i2c-5 # brightness 10 %
ddccontrol -r 0x12 -w 50 dev:/dev/i2c-5 # brightness 50 %
ddccontrol -r 0x62 -w 10 dev:/dev/i2c-5 # sound volume 10%
ddccontrol -r 0x8d -w 2 dev:/dev/i2c-5 # unmute
ddccontrol -r 0x8d -w 1 dev:/dev/i2c-5 # mute

ddcutil  capabilities # print all info
ddcutil --model "BenQ GW2765" capabilities # print capabalities info
ddcutil --model "BenQ GW2765" setvcp 0x8d 2 # unmute
ddcutil --model "BenQ GW2765" setvcp 0x8d 1 # mute

ddcutil detect | grep -B5 "BenQ GW2765" | grep "I2C bus:" | sed 's/.*\/dev\///' # detect I2C bus device file

```

## Source:
```
# LANG= LC_ALL= ddccontrol -p -c -d
ddccontrol version 0.4.2
Copyright 2004-2005 Oleg I. Vdovikin (oleg@cs.msu.su)Copyright 2004-2006 Nicolas Boichat (nicolas@boichat.ch)
This program comes with ABSOLUTELY NO WARRANTY.
You may redistribute copies of this program under the terms of the GNU General Public License.

Probing for available monitorsradeon_open: mmap failed: Invalid argument
..Can't convert value to int, invalid CAPS (buf=0405080B8��, pos=90).
I/O warning : failed to load external entity "/usr/share/ddccontrol-db/monitor/BNQ78D6.xml"
Document not parsed successfully.
I/O warning : failed to load external entity "/usr/share/ddccontrol-db/monitor/BNQlcd.xml"
Document not parsed successfully.
......
Detected monitors :
 - Device: dev:/dev/i2c-5
   DDC/CI supported: Yes
   Monitor Name: VESA standard monitor
   Input type: Digital
  (Automatically selected)
Reading EDID and initializing DDC/CI at bus dev:/dev/i2c-5...
Can't convert value to int, invalid CAPS (buf=0405080B�"��, pos=90).
I/O warning : failed to load external entity "/usr/share/ddccontrol-db/monitor/BNQ78D6.xml"
Document not parsed successfully.
I/O warning : failed to load external entity "/usr/share/ddccontrol-db/monitor/BNQlcd.xml"
Document not parsed successfully.

EDID readings:
    Plug and Play ID: BNQ78D6 [VESA standard monitor]
    Input type: Digital
=============================== WARNING ===============================
There is no support for your monitor in the database, but ddccontrol is
using a basic generic profile. Many controls will not be supported, and
some controls may not work as expected.
Please update ddccontrol-db, or, if you are already using the latest
version, please send the output of the following command to
ddccontrol-users@lists.sourceforge.net:

LANG= LC_ALL= ddccontrol -p -c -d

Thank you.
=============================== WARNING ===============================

Capabilities:
Can't convert value to int, invalid CAPS (buf=0405080B(%��, pos=90).
Raw output: (prot(monitor)type(lcd)model(GW2765HT)cmds(01 02 03 07 0C 4E E3 F3)vcp(020405080B0C101214(0405080B)16181A6C6E70ACAEB6C0C6C8C9CACC(01020304050608090A0B0D12141A1E1F20)D6(0104)DF 60(01 03 11 0F) 62 8D(01 02)FF)mswhql(1)mccs_ver(2.1)asset_eep(32)mpu_ver(01))
Parsed output:
    VCP: 02 04 05 08 0b 0c 10 12 14
    Type: LCD

Controls (valid/current/max) [Description - Value name]:
Control 0x02: +/2/255 C [Secondary Degauss]
Control 0x04: +/0/1 C [Restore Factory Defaults]
Control 0x05: +/0/1 C [Restore Brightness and Contrast]
Control 0x08: +/0/1 C [Restore Factory Default Color]
Control 0x0b: +/50/65535 C [???]
Control 0x0c: +/70/126 C [???]
Control 0x10: +/100/100 C [Brightness]
Control 0x12: +/50/100 C [Contrast]
Control 0x14: +/5/11 C [???]
Control 0x16: +/100/100   [???]
Control 0x18: +/100/100   [???]
Control 0x1a: +/100/100   [???]
Control 0x52: +/0/255   [???]
Control 0x60: +/3/3   [???]
Control 0x62: +/100/100   [???]
Control 0x6c: +/50/100   [???]
Control 0x6e: +/50/100   [???]
Control 0x70: +/50/100   [???]
Control 0x8d: +/2/2   [???]
Control 0xac: +/23364/65281   [???]
Control 0xae: +/6000/65535   [???]
Control 0xb2: +/1/8   [???]
Control 0xb5: +/0/255   [???]
Control 0xb6: +/3/4   [???]
Control 0xc0: +/298/65535   [???]
Control 0xc6: +/60/65535   [???]
Control 0xc8: +/18/65535   [???]
Control 0xc9: +/4/65535   [???]
Control 0xca: +/2/2   [???]
Control 0xcc: +/2/255   [???]
Control 0xd6: +/1/4   [???]
Control 0xdf: +/513/65535   [???]
Control 0xfe: +/0/255   [???]
Control 0xff: +/0/1   [???]
# uname -a
Linux leonidas 4.9.11-1-ARCH #1 SMP PREEMPT Sun Feb 19 13:45:52 UTC 2017 x86_64 GNU/Linux
# cat /etc/arch-release

------------------- btw: ------------------

# ddcutil  capabilities
(create_parsed_edid) Invalid initial EDID bytes: 00 00 00 00 00 00 00 00
(ddc_open_display) No EDID for device on bus /dev/i2c-6
(store_bytehex_list) Invalid hex value in list: 0405080B
Error processing VCP feature value list into bva_values: 0405080B
(store_bytehex_list) Invalid hex value in list: 0405080B
Error processing VCP feature value list into bbf_values: 0405080B
(store_bytehex_list) Invalid hex value in list: 01020304050608090A0B0D12141A1E1F20
Error processing VCP feature value list into bva_values: 01020304050608090A0B0D12141A1E1F20
(store_bytehex_list) Invalid hex value in list: 01020304050608090A0B0D12141A1E1F20
Error processing VCP feature value list into bbf_values: 01020304050608090A0B0D12141A1E1F20
(store_bytehex_list) Invalid hex value in list: 0104
Error processing VCP feature value list into bva_values: 0104
(store_bytehex_list) Invalid hex value in list: 0104
Error processing VCP feature value list into bbf_values: 0104
MCCS version: 2.1
Commands:
  Command: 01 (VCP Request)
  Command: 02 (VCP Response)
  Command: 03 (VCP Set)
  Command: 07 (Timing Request)
  Command: 0c (Save Settings)
  Command: 4e (unrecognized command)
  Command: e3 (Capabilities Reply)
  Command: f3 (Capabilities Request)
VCP Features:
  Feature: 02 (New control value)
  Feature: 04 (Restore factory defaults)
  Feature: 05 (Restore factory brightness/contrast defaults)
  Feature: 08 (Restore color defaults)
  Feature: 0B (Color temperature increment)
  Feature: 0C (Color temperature request)
  Feature: 10 (Brightness)
  Feature: 12 (Contrast)
  Feature: 14 (Select color preset)
    Values:
  Feature: 16 (Video gain: Red)
  Feature: 18 (Video gain: Green)
  Feature: 1A (Video gain: Blue)
  Feature: 6C (Video black level: Red)
  Feature: 6E (Video black level: Green)
  Feature: 70 (Video black level: Blue)
  Feature: AC (Horizontal frequency)
  Feature: AE (Vertical frequency)
  Feature: B6 (Display technology type)
  Feature: C0 (Display usage time)
  Feature: C6 (Application enable key)
  Feature: C8 (Display controller type)
  Feature: C9 (Display firmware level)
  Feature: CA (OSD)
  Feature: CC (OSD Language)
    Values:
  Feature: D6 (Power mode)
    Values:
  Feature: DF (VCP Version)
  Feature: 60 (Input Source)
    Values:
       01: VGA-1
       03: DVI-1
       11: HDMI-1
       0f: DisplayPort-1
  Feature: 62 (Audio speaker volume)
  Feature: 8D (Audio Mute)
    Values:
       01: Mute the audio
       02: Unmute the audio
  Feature: FF (manufacturer specific feature)
```
