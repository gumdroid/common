WiLink8 Driver---Kernel Support
===============================
This source can be used to generate kernel modules for the WiLink8 wireless
chip that are compatible with the 3.2 Androidized Linux Kernel used for these
boards.  These backports have been generated according to the
"Building R8.3 SP1" section [1]:
 $ ./wl18xx_build.sh wl18xx_modules build

The generated 'compat-wireless' directory is extracted, cleaned and then
maintained independently.  Note that platform data (whether in device tree
format or as structures in the board file) must still be present in the base
kernel for boards wanting to use the Wilink8 drivers generated here.  The base
kernel configuration is also significant.  By way of example, support for
CFG80211 and MAC8011 must be disabled in the kernel configuration such that the
compatibility layer provided here doesn't create symbol conflicts.

Significatn changes to the kernel (i.e. the version used) would invalidate the
code in this repository---the backport would need to be re-generated.

[1] http://processors.wiki.ti.com/index.php/WL18xx_System_Build_Scripts
