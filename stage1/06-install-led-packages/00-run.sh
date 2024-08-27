#!/bin/bash -e

repo_owner="InterludeAudio"
repo_name="digihat_display"

# Fetch the latest release tag using GitHub API
release_tag=$(curl -s "https://api.github.com/repos/$repo_owner/$repo_name/releases/latest" | jq -r .tag_name)

# Check if release tag is empty
if [ -z "$release_tag" ]; then
    echo "Failed to fetch the latest release tag. Please check your repository details."
    exit 1
fi

# Define the download URL pattern for GitHub releases
download_url="https://github.com/$repo_owner/$repo_name/archive/refs/tags/$release_tag.tar.gz"

curl -sLJO "$download_url"
tar -xf $repo_name-$release_tag.tar.gz

INSTALL_DIR=${ROOTFS_DIR}/usr/interlude_audio/digihat_display
mkdir -p $INSTALL_DIR

install -v -m 755    $repo_name-$release_tag/display.py $INSTALL_DIR/display.py
install -v -m 755 -D $repo_name-$release_tag/scripts/display_start.sh $INSTALL_DIR/scripts/display_start.sh
install -v -m 644 -D $repo_name-$release_tag/BRS_SSD1306/SSD1306.py $INSTALL_DIR/BRS_SSD1306/SSD1306.py
install -v -m 644 -D $repo_name-$release_tag/BRS_SSD1306/__init__.py $INSTALL_DIR/BRS_SSD1306/__init__.py
install -v -m 644 -D $repo_name-$release_tag/assets/Questrial-Regular.ttf $INSTALL_DIR/assets/Questrial-Regular.ttf
install -v -m 644 -D $repo_name-$release_tag/assets/logo3.png $INSTALL_DIR/assets/logo3.png
install -v -m 644    $repo_name-$release_tag/scripts/interludeaudio.service ${ROOTFS_DIR}/lib/systemd/system

on_chroot << EOF
systemctl enable interludeaudio.service
EOF
