#!/bin/bash -e

install -d "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d"
install -m 644 files/noclear.conf "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/noclear.conf"
install -v -m 644 files/fstab "${ROOTFS_DIR}/etc/fstab"

rm -rf ${ROOTFS_DIR}/lib/modules/*

KERNEL_VER=v5.15
cp -r files/rpilinux/${KERNEL_VER}/arch/arm/lib/modules/* ${ROOTFS_DIR}/lib/modules/.
cp    files/rpilinux/${KERNEL_VER}/arch/arm/boot/kernel*.img ${ROOTFS_DIR}/boot/.
cp    files/rpilinux/${KERNEL_VER}/arch/arm/boot/dts/overlays/* ${ROOTFS_DIR}/boot/overlays/.

cp -r files/rpilinux/${KERNEL_VER}/arch/arm64/lib/modules/* ${ROOTFS_DIR}/lib/modules/.
cp    files/rpilinux/${KERNEL_VER}/arch/arm64/boot/kernel*.img ${ROOTFS_DIR}/boot/.
cp    files/rpilinux/${KERNEL_VER}/arch/arm64/boot/dts/overlays/* ${ROOTFS_DIR}/boot/overlays/.

on_chroot << EOF
if ! id -u ${FIRST_USER_NAME} >/dev/null 2>&1; then
	adduser --disabled-password --gecos "" ${FIRST_USER_NAME}
fi

if [ -n "${FIRST_USER_PASS}" ]; then
	echo "${FIRST_USER_NAME}:${FIRST_USER_PASS}" | chpasswd
fi
echo "root:root" | chpasswd
EOF


