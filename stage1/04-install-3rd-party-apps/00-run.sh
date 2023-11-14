#!/bin/bash -e

on_chroot << EOF
#
#  S H A I R P O R T

# Build and Install nqptp
git clone https://github.com/mikebrady/nqptp.git
cd nqptp
autoreconf -fi
./configure --with-systemd-startup
make
make install
cd ..

# Enable and Start nqptp
systemctl enable nqptp

# Build and Install Shairport
git clone https://github.com/mikebrady/shairport-sync.git
cd shairport-sync
autoreconf -fi
./configure --sysconfdir=/etc --with-pa \
    --with-soxr --with-avahi --with-ssl=openssl --with-systemd --with-airplay-2
make
make install
cd ..


#
#  R A S P O T I F Y
curl -sL https://dtcooper.github.io/raspotify/install.sh | sh

# Set card for Raspotify to use
sed -i "s\#LIBRESPOT_DEVICE=\"default\"\LIBRESPOT_DEVICE=\"pulse\"\g" /etc/raspotify/conf

# set Raspotify to use system wide PulseAudio
sed -i '/\[Service\]/a\User=pulse' /lib/systemd/system/raspotify.service


#
#  R O O N  B R I D G E
curl -O https://download.roonlabs.net/builds/roonbridge-installer-linuxarmv7hf.sh
chmod +x roonbridge-installer-linuxarmv7hf.sh
yes Y | ./roonbridge-installer-linuxarmv7hf.sh
EOF

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
