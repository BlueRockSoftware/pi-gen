#!/bin/bash -e

install -d "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d"
install -m 644 files/noclear.conf "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/noclear.conf"
install -v -m 644 files/fstab "${ROOTFS_DIR}/etc/fstab"

git clone --depth=1 https://github.com/InterludeAudio/rpilinux.git

cd rpilinux

echo "!! build 64 bit kernel and modules For Raspberry Pi 3, 3+, 4, 400 and Zero 2 W, and Raspberry Pi Compute Modules 3, 3+ and 4  !!"

KERNEL=kernel8
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2711_defconfig
make -j32 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image modules dtbs
sudo env PATH=$PATH make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=${ROOTFS_DIR} modules_install
sudo cp arch/arm64/boot/dts/broadcom/*.dtb ${ROOTFS_DIR}/boot/firmware/
sudo cp arch/arm64/boot/dts/overlays/*.dtb* ${ROOTFS_DIR}/boot/firmware/overlays/
sudo cp arch/arm64/boot/dts/overlays/README ${ROOTFS_DIR}/boot/firmware/overlays/
sudo cp arch/arm64/boot/Image ${ROOTFS_DIR}/boot/firmware/$KERNEL.img

echo "!! build complete all files copied over !!"

echo "!! cleaning environment for pi 5 build"

make clean 

echo "!! Clean complete !!"

echo "!! Building For Raspberry Pi 5 default 64-bit build configuration !!"
KERNEL=kernel_2712
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2712_defconfig
make -j32 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image modules dtbs
sudo env PATH=$PATH make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=${ROOTFS_DIR} modules_install
sudo cp arch/arm64/boot/dts/broadcom/*.dtb ${ROOTFS_DIR}/boot/firmware/
sudo cp arch/arm64/boot/dts/overlays/*.dtb* ${ROOTFS_DIR}/boot/firmware/overlays/
sudo cp arch/arm64/boot/dts/overlays/README ${ROOTFS_DIR}/boot/firmware/overlays/
sudo cp arch/arm64/boot/Image ${ROOTFS_DIR}/boot/firmware/$KERNEL.img

echo "!! build complete all files copied over !!"

on_chroot << EOF
if ! id -u ${FIRST_USER_NAME} >/dev/null 2>&1; then
	adduser --disabled-password --gecos "" ${FIRST_USER_NAME}
fi

if [ -n "${FIRST_USER_PASS}" ]; then
	echo "${FIRST_USER_NAME}:${FIRST_USER_PASS}" | chpasswd
fi
echo "root:root" | chpasswd
EOF


