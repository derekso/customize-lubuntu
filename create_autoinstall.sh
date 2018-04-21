#!/bin/bash -ex

# This script will download the lubuntu-alternate.iso and libreoffice.tar.gz
# bundle them together to generate a new auto-installer called "lubuntu-auto.iso"

# install tooling
sudo apt-get install genisoimage

# We need alternate ISO of Lubuntu
# http://cdimage.ubuntu.com/lubuntu/releases/16.04/release/lubuntu-16.04-alternate-amd64.iso
ISO_LUBUNTU_ALTERNATE=lubuntu-16.04-alternate-amd64.iso

# download the file
wget -q -c http://cdimage.ubuntu.com/lubuntu/releases/16.04/release/lubuntu-16.04-alternate-amd64.iso

# we need to mount ISO
mkdir -p /tmp/lubuntu_iso
sudo mount -r -o loop $ISO_LUBUNTU_ALTERNATE /tmp/lubuntu_iso
# now we need to unpack ISO to temporary folder
mkdir /tmp/auto_lubuntu_iso
cp -r /tmp/lubuntu_iso/. /tmp/auto_lubuntu_iso/
# and change its ownership so we can write to it
chown -R $USER:$USER /tmp/auto_lubuntu_iso/
chmod -R 755 /tmp/auto_lubuntu_iso

# now we can unmount ISO
sudo umount /tmp/lubuntu_iso

# And LibreOffice
wget -q -c https://download.documentfoundation.org/libreoffice/stable/5.4.6/deb/x86_64/LibreOffice_5.4.6_Linux_x86-64_deb.tar.gz
cp LibreOffice_5.4.6_Linux_x86-64_deb.tar.gz /tmp/auto_lubuntu_iso

rm -rf /tmp/lubuntu_iso

# now we need to copy our KickStart files to ISO
cp {ks.cfg,lubuntu-auto.seed} /tmp/auto_lubuntu_iso

# We need to modify isolinux config file, so we start our auto-installer
sed -i '/default install/r txt.cfg.add' /tmp/auto_lubuntu_iso/isolinux/txt.cfg
# Now we need to decrease timeout so autoinstallation will start quickly, but we have opportunity to break the process if neccessary
sed -i -r 's/timeout\s+[0-9]+/timeout 3/g' /tmp/auto_lubuntu_iso/isolinux/isolinux.cfg

# Now it's time to create ISO image
sudo genisoimage -D -r -V "lubuntu-auto" -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -input-charset utf-8 -cache-inodes -quiet -o lubuntu-auto.iso /tmp/auto_lubuntu_iso/

# And finally we can remove temporary directory
rm -rf /tmp/auto_lubuntu_iso
