#!/bin/bash -e

sed -i 's/; default-sample-rate = 44100/default-sample-rate = 48000/' ${ROOTFS_DIR}/etc/pulse/daemon.conf
touch ${ROOTFS_DIR}/etc/pulse/plusultra

on_chroot <<EOF
adduser "$FIRST_USER_NAME" lpadmin
EOF
