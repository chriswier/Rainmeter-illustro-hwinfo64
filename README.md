# Rainmeter-illustro-hwinfo64
Powershell script to build a hwinfo64 registry interface extension to Rainmeter's illustro theme.

--------

This powershell script generates multiple Rainmeter Illustro theme skins to enable pulling from HWiNFO64's registry interface.  I wanted to extend the already
existing Illustro theme/skin, and add a *LOT* of sensors from HWiNFO64.  See https://docs.rainmeter.net/tips/hwinfo/ for how to enable this in HWiNFO64.

By default, this Powershell script creates 4 different Illustro skins; CPU, Motherboard, Disk, and GPU.  This is totally configurable -- you can add more.
(See the $configs and $yvalues arrays; and add any other category into there.)  HWiNFO64 exports all the sensors in large groupings; each of these needs to be mapped
specifically to one of these $config categories.  Update the $map variable with the *EXACT* names of your HWiNFO64 categories, and set the $config name where they 
will be sent to.

NOTE: anytime you update which HWiNFO64 sensors are enabled, you'll need to re-run this script to regenerate the skin configuration files and refresh them within Rainmeter.

See the example.png in this repo for how it looks fully configured.
