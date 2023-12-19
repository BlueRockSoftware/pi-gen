#!/bin/bash -e

# Install script and files that detects active hat and sets pulseaudio config accordingly
install -m 755 files/hat-detection "${ROOTFS_DIR}/usr/local/sbin/hat-detection"
install -m 644 files/daemon-brs-digital.conf "${ROOTFS_DIR}/etc/pulse/daemon-brs-digital.conf"
install -m 644 files/daemon-brs-analog.conf "${ROOTFS_DIR}/etc/pulse/daemon-brs-analog.conf"
install -m 644 files/99-hat-detection.rules "${ROOTFS_DIR}/etc/udev/rules.d/99-hat-detection.rules"
