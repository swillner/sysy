#!/bin/sh
### Repositories / Apt
# Keys
curl https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
# paper-themes
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D320D0C30B02E64C5B2BB2743766223989993A70
# spotify
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
# docker
sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
# Signal
curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
# # bazel
# curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -

# cleanup
find /usr/share/doc -depth -type f ! -name copyright ! -name texlive -exec sudo rm {} \;
find /usr/share/locale -mindepth 1 -maxdepth 1 ! -name 'en' ! -name 'de*' -exec sudo rm {} \;

**** /etc/apt/sources.list
**** /etc/apt/sources.list.d/skype-stable.list
**** /etc/apt/preferences.d/01pinning
**** /etc/apt/apt.conf.d/99local
**** /etc/dpkg/dpkg.cfg.d/99local

# Docker
sudo groupadd docker
sudo gpasswd -a sven docker
sudo service docker restart

# Tor Browser
echo "ExitNodes {us}" >> ~/.local/share/torbrowser/tbb/x86_64/tor-browser_en-US/Browser/TorBrowser/Data/Tor/torrc
mkdir .local/share/torbrowser/tbb/x86_64/tor-browser_en-US/Browser/browser/plugins
ln -s /usr/lib/flashplugin-nonfree/libflashplayer.so .local/share/torbrowser/tbb/x86_64/tor-browser_en-US/Browser/browser/plugins/
sudo mkdir /etc/adobe
echo "DisableSockets=1" | sudo tee /etc/adobe/mms.cfg
sudo update-flashplugin-nonfree --install

file_include_line /etc/NetworkManager/NetworkManager.conf "managed = true"
file_include_line /etc/dhcp/dhclient.conf "append domain-name-servers 8.8.8.8 8.8.4.4;"
file_include_lines /etc/networking/interfaces <<EOF
auto lo
iface lo inet loopback
iface lo inet6 loopback
allow-hotplug eth0
iface eth0 inet dhcp
iface eth0 inet6 dhcp
EOF

*** Power Management
edit /etc/systemd/logind.conf
edit /etc/UPower/UPower.conf

*** /etc/fstab
# For /
noatime,commit=500,errors=remount-ro
#
file_include_lines /etc/fstab <<EOF
tmpfs   /tmp         tmpfs   nodev,nosuid,size=2G          0  0
varlog   /var/log         tmpfs   nodev,nosuid,size=2G          0  0
EOF

*** Grub
**** /etc/default/grub (+sudo update-grub)
GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_HIDDEN_TIMEOUT=1
GRUB_HIDDEN_TIMEOUT_QUIET=true
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash elevator=noop i915.enable_fbc=1"
GRUB_CMDLINE_LINUX="security=selinux"
*** Firefox
In about:config create full-screen-api.ignore-widgets and set to true
https://wiki.archlinux.org/index.php/firefox_tweaks
*** SSD
?? Set "issue_discards" option in /etc/lvm/lvm.conf for LVM if you want LVM to discard on lvremove. See lvm.conf(5).
?? Set "discard" option in /etc/crypttab for dm-crypt.
sudo cp /usr/share/doc/util-linux/examples/fstrim.{service,timer} /etc/systemd/system
sudo systemctl enable fstrim.timer
*** /etc/udev/rules.d/usb-power.rules
#Lenovo Keyboard
ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0x17ef", ATTR{idProduct}=="0x6047", TEST=="power/control", ATTR{power/control}="on"
*** /etc/sysctl.d/local.conf
vm.swappiness=60
fs.inotify.max_user_watches=65536
*** Sudo
usermod -a -G sudo sven
**** /etc/sudoers.d/mount
%sudo ALL=(ALL) NOPASSWD: /bin/mount,/bin/umount
*** Python
curl -s https://bootstrap.pypa.io/get-pip.py | python3 - --user
curl -s https://bootstrap.pypa.io/get-pip.py | python - --user
*** Trackpoint
**** /etc/udev/rules.d/10-trackpoint.rules
SUBSYSTEM=="input", ATTR{name}=="*TrackPoint*", RUN+="/etc/conf.d/trackpoint"
**** /etc/conf.d/trackpoint
#!/bin/bash
## Trackpoint settings
#When run from a udev rule, DEVPATH should be set
if [ ! -z $DEVPATH ] ; then
    TPDEV=/sys/$( echo "$DEVPATH" | sed 's/\/input\/input[0-9]*//' )
else
#Otherwise just look in / sys /
    TPDEV=$(find /sys/devices/platform/i8042 -name name | xargs grep -Fl TrackPoint | sed 's/\/input\/input[0-9]*\/name$//')
fi

#http://www.thinkwiki.org/wiki/How_to_configure_the_TrackPoint
#http://wwwcssrv.almaden.ibm.com/trackpoint/files/ykt3eext.pdf
#-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
if [ -d "$TPDEV" ]; then
    echo "Configuring Trackpoint"
    echo -n 255     > $TPDEV/sensitivity     # Integer  128   Sensitivity
    echo -n 110     > $TPDEV/speed           # Integer  97   Cursor speed
    echo -n 4       > $TPDEV/inertia         # Integer  6   Negative intertia
else
    echo "Couldn't find trackpoint device $TPDEV"
fi
*** autologin
**** /etc/lightdm/lightdm.conf
autologin-user=sven
autologin-user-timeout=0
*** Mails
mbsync -a
find . -type f | xargs sed -i -e '1!b' -e '/^>From/d'
mu mkdir ~/Maildir/queue
touch ~/Maildir/queue/.noindex
mu index
*** Misc
qtconfig
edit /etc/java-8-openjdk/accessibility.properties
sudo gpasswd -a sven systemd-journal
sudo sh -c "echo 'Dpkg::Progress-Fancy \"1\";' > /etc/apt/apt.conf.d/99progressbar"
dconf write /org/gnome/evince/default/fullscreen true
dconf write /org/gnome/evince/default/show-sidebar false
dconf write /org/gnome/evince/default/show-toolbar false
dconf write /org/gnome/evince/default/sizing-mode "'fit-page'"
*** Libreoffice
Under Memory:
Reduce the number of Undo steps to a figure lower than 100, to something like 20 or 30 steps
Under Graphics cache, set Use for LibreOffice to 128 MB (up from the original 20 MB)
Set Memory per object to 20 MB (up from the default 5 MB).
If LibreOffice is used often, check Enable systray Quickstarter
Under Advanced, uncheck Use a Java runtime environment
*** Keyboard
sudo ln -s /home/sven/.custom.xkb /usr/share/X11/xkb/symbols/custom
**** /etc/default/keyboard
XKBMODEL="pc105"
XKBLAYOUT="custom"
XKBVARIANT=""
XKBOPTIONS="ctrl:nocaps"
BACKSPACE="guess"
*** GTK Theming
GTK_DEBUG=interactive ...
*** Syncthing
On akator:
Sync Protocol Listen Addresses = tcp://0.0.0.0:22000
*** Plymouth
sudo plymouth-set-default-theme -R text
sudo update-initramfs -u
**** /etc/initramfs-tools/modules
intel_agp
drm
i915 modeset=1
*** dock/undock
**** /etc/udev/rules.d/85-dock.rules
SUBSYSTEM=="hidraw", KERNEL=="hidraw1", ACTION=="add",    RUN+="/home/sven/.dock.sh 1"
SUBSYSTEM=="hidraw", KERNEL=="hidraw1", ACTION=="remove", RUN+="/home/sven/.dock.sh 0"
*** Jupyter
jupyter nbextensions_configurator enable --user
jupyter contrib nbextension install --user
ipcluster nbextension enable --user
*** SELinux
sudo selinux-activate
**** /etc/default/rcS
FSCKFIX=yes
*** Chromium
chrome://flags/#enable-manual-fallbacks-filling
