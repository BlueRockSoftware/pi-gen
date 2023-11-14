#!/bin/bash -e

if [ "$RELEASE" != "bullseye" ]; then
	echo "WARNING: RELEASE does not match the intended option for this branch."
	echo "         Please check the relevant README.md section."
fi

if [ ! -d "${ROOTFS_DIR}" ] || [ "${USE_QCOW2}" = "1" ]; then
	bootstrap ${RELEASE} "${ROOTFS_DIR}" http://raspbian.raspberrypi.org/raspbian/
	# bootstrap ${RELEASE} "${ROOTFS_DIR}" http://mirrors.gigenet.com/raspbian/raspbian/ # Optional mirror if http://raspbian.raspberrypi.org/raspbian/ doesn't work
fi
