#!/bin/bash -e

install -d "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d"
install -m 644 files/noclear.conf "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/noclear.conf"
install -v -m 644 files/fstab "${ROOTFS_DIR}/etc/fstab"

git clone https://github.com/BlueRockSoftware/rpilinux.git

cd rpilinux
: '
echo "!!!  Build RPi0 kernel and modules  !!!"
KERNEL=kernel
make -j 16 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcmrpi_defconfig
make -j 16 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs
env PATH=$PATH make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=${ROOTFS_DIR}/ modules_install
cp arch/arm/boot/zImage ${ROOTFS_DIR}/boot/$KERNEL.img
cp arch/arm/boot/dts/overlays/*.dtb* ${ROOTFS_DIR}/boot/overlays
cp arch/arm/boot/dts/overlays/README ${ROOTFS_DIR}/boot/overlays

echo "!!!  RPi0 build done  !!!"
echo "-------------------------"

echo "!!!  Build RPi3 kernel and modules  !!!"
KERNEL=kernel7
make -j 24 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcm2709_defconfig
make -j 24 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs
env PATH=$PATH make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=${ROOTFS_DIR}/ modules_install
cp arch/arm/boot/zImage ${ROOTFS_DIR}/boot/$KERNEL.img
cp arch/arm/boot/dts/overlays/*.dtb* ${ROOTFS_DIR}/boot/overlays
cp arch/arm/boot/dts/overlays/README ${ROOTFS_DIR}/boot/overlays


echo "!!!  RPi3 build done  !!!"
echo "-------------------------"

echo "!!!  Build RPi4 kernel and modules  !!!"
KERNEL=kernel7l
make -j 24 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcm2711_defconfig
make -j 24 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs
env PATH=$PATH make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=${ROOTFS_DIR}/ modules_install
cp arch/arm/boot/zImage ${ROOTFS_DIR}/boot/$KERNEL.img
cp arch/arm/boot/dts/overlays/*.dtb* ${ROOTFS_DIR}/boot/overlays
cp arch/arm/boot/dts/overlays/README ${ROOTFS_DIR}/boot/overlays

echo "!!!  RPi4 build done  !!!"
echo "-------------------------"
'

echo "!!!  Build 64-bit kernel and modules  !!!"
KERNEL=kernel8
make -j 24  ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2711_defconfig
make -j 24  ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image modules dtbs
env PATH=$PATH make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=${ROOTFS_DIR}/ modules_install
cp arch/arm64/boot/Image ${ROOTFS_DIR}/boot/$KERNEL.img
cp arch/arm64/boot/dts/overlays/*.dtb* ${ROOTFS_DIR}/boot/overlays
cp arch/arm64/boot/dts/overlays/README ${ROOTFS_DIR}/boot/overlays

rm -rf ${ROOTFS_DIR}/lib/modules/6.1.21+
rm -rf ${ROOTFS_DIR}/lib/modules/6.1.21-v7+
rm -rf ${ROOTFS_DIR}/lib/modules/6.1.21-v7l+
rm -rf ${ROOTFS_DIR}/lib/modules/6.1.21-v8+
rm -rf ${ROOTFS_DIR}/lib/modules/6.1.0-rpi4-rpi-2712
rm -rf ${ROOTFS_DIR}/lib/modules/6.1.0-rpi4-rpi-v8

echo "!!! All builds completed !!!"

on_chroot << EOF
if ! id -u ${FIRST_USER_NAME} >/dev/null 2>&1; then
	adduser --disabled-password --gecos "" ${FIRST_USER_NAME}
fi

if [ -n "${FIRST_USER_PASS}" ]; then
	echo "${FIRST_USER_NAME}:${FIRST_USER_PASS}" | chpasswd
fi
echo "root:root" | chpasswd
EOF


