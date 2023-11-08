#!/bin/bash -e

# Install script that runs on first boot to install 3rd party apps
install -m 755 files/install-3rd-party-apps "${ROOTFS_DIR}/usr/local/sbin/install-3rd-party-apps"

# Install systemd service to run install-3rd-party-apps on first boot
install -m 644 files/install-3rd-party-apps.service "${ROOTFS_DIR}/etc/systemd/system/install-3rd-party-apps.service"
ln -svf "/etc/systemd/system/install-3rd-party-apps.service" "$ROOTFS_DIR/etc/systemd/system/multi-user.target.wants/install-3rd-party-apps.service"

# Install systemd service to run pulseaudio as a system service
install -m 644 files/pulseaudio.service "${ROOTFS_DIR}/etc/systemd/system/pulseaudio.service"
ln -svf "/etc/systemd/system/pulseaudio.service" "$ROOTFS_DIR/etc/systemd/system/multi-user.target.wants/pulseaudio.service"

# Install systemd service to run shairport-sync
install -m 644 files/shairport-sync.service "${ROOTFS_DIR}/etc/systemd/system/shairport-sync.service"
ln -svf "/etc/systemd/system/shairport-sync.service" "$ROOTFS_DIR/etc/systemd/system/multi-user.target.wants/shairport-sync.service"
