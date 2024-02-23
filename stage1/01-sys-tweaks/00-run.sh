#!/bin/bash -e

install -d "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d"
install -m 644 files/noclear.conf "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/noclear.conf"
install -v -m 644 files/fstab "${ROOTFS_DIR}/etc/fstab"

rm -rf ${ROOTFS_DIR}/lib/modules/*

# Download and install kernel artifacts
####################
repo_owner="InterludeAudio"
repo_name="rpilinux"

# Fetch the latest release tag using GitHub API
release_tag=$(curl -s "https://api.github.com/repos/$repo_owner/$repo_name/releases/latest" | jq -r .tag_name)

# Check if release tag is empty
if [ -z "$release_tag" ]; then
    echo "Failed to fetch the latest release tag. Please check your repository details."
    exit 1
fi

# Define the download URL pattern for GitHub releases
download_url="https://github.com/$repo_owner/$repo_name/releases/download/$release_tag"

# Define the assets you want to download
assets=("bcm2711_build" "bcm2712_build")

# Function to download a file
download_and_untar_file() {
    local file_name="$1"
    local url="$download_url/$file_name"
    echo "Downloading $file_name..."

    curl -LJO "$url"
    tar -xvf ${file_name}
}

# Download each specified asset
for asset in "${assets[@]}"; do
    download_and_untar_file "$asset"
done
echo "Downloads completed!"

echo "Installing kernel artifacts..."
mv boot/firmware/*.dtb ${ROOTFS_DIR}/boot/firmware/.
mv boot/firmware/*.img ${ROOTFS_DIR}/boot/firmware/.
mv boot/firmware/overlays/* ${ROOTFS_DIR}/boot/firmware/overlays/.
mv lib/modules/* ${ROOTFS_DIR}/lib/modules/.
####################

on_chroot << EOF
if ! id -u ${FIRST_USER_NAME} >/dev/null 2>&1; then
	adduser --disabled-password --gecos "" ${FIRST_USER_NAME}
fi

if [ -n "${FIRST_USER_PASS}" ]; then
	echo "${FIRST_USER_NAME}:${FIRST_USER_PASS}" | chpasswd
fi
echo "root:root" | chpasswd
EOF


