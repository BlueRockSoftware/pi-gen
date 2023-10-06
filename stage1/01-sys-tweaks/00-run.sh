#!/bin/bash -e

install -d "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d"
install -m 644 files/noclear.conf "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/noclear.conf"
install -v -m 644 files/fstab "${ROOTFS_DIR}/etc/fstab"
wget https://raw.githubusercontent.com/BlueRockSoftware/rpi-kernel-modules/main/archive/modules-rpi-6.1.21-interludeaudio.tar.gz
tar -xf modules-rpi-6.1.21-interludeaudio.tar.gz 
sudo rm -rf modules-rpi-6.1.21-interludeaudio.tar.gz 
sudo cp modules-rpi-6.1.21-interludeaudio/lib/modules/6.1.21+/kernel/sound/soc/bcm/snd-soc-rpi-wm8804-soundcard.ko ${ROOTFS_DIR}/lib/modules/6.1.21+/kernel/sound/soc/bcm/snd-soc-rpi-wm8804-soundcard.ko
sudo rm ${ROOTFS_DIR}/lib/modules/6.1.21+/kernel/sound/soc/bcm/snd-soc-rpi-wm8804-soundcard.ko.xz
sudo cp modules-rpi-6.1.21-interludeaudio/lib/modules/6.1.21-v7+/kernel/sound/soc/bcm/snd-soc-rpi-wm8804-soundcard.ko ${ROOTFS_DIR}/lib/modules/6.1.21-v7+/kernel/sound/soc/bcm/snd-soc-rpi-wm8804-soundcard.ko
sudo rm ${ROOTFS_DIR}/lib/modules/6.1.21-v7+/kernel/sound/soc/bcm/snd-soc-rpi-wm8804-soundcard.ko.xz
sudo cp modules-rpi-6.1.21-interludeaudio/lib/modules/6.1.21-v7l+/kernel/sound/soc/bcm/snd-soc-rpi-wm8804-soundcard.ko ${ROOTFS_DIR}/lib/modules/6.1.21-v7l+/kernel/sound/soc/bcm/snd-soc-rpi-wm8804-soundcard.ko
sudo rm ${ROOTFS_DIR}/lib/modules/6.1.21-v7l+/kernel/sound/soc/bcm/snd-soc-rpi-wm8804-soundcard.ko.xz
sudo cp modules-rpi-6.1.21-interludeaudio/boot/overlays/interludeaudio-analog.dtbo ${ROOTFS_DIR}/boot/overlays/
sudo cp modules-rpi-6.1.21-interludeaudio/boot/overlays/interludeaudio-digital.dtbo ${ROOTFS_DIR}/boot/overlays/
sudo rm -rf modules-rpi-6.1.21-interludeaudio

on_chroot << EOF
if ! id -u ${FIRST_USER_NAME} >/dev/null 2>&1; then
	adduser --disabled-password --gecos "" ${FIRST_USER_NAME}
fi

if [ -n "${FIRST_USER_PASS}" ]; then
	echo "${FIRST_USER_NAME}:${FIRST_USER_PASS}" | chpasswd
fi
echo "root:root" | chpasswd
EOF


