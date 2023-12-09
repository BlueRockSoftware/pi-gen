#!/bin/bash -e

install -d "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d"
install -m 644 files/noclear.conf "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/noclear.conf"
install -v -m 644 files/fstab "${ROOTFS_DIR}/etc/fstab"

rm -rf ${ROOTFS_DIR}/lib/modules/*

# Download and install kernel artifacts
####################
REPO_OWNER="BlueRockSoftware"
REPO_NAME="rpilinux"
BRANCH_NAME="rpi-6.1.21"
WORKFLOW="kernel-build.yml"

# ACCESS_TOKEN="" # Set via environment variable

# GitHub API endpoint to get the latest workflow run on the specified branch
WORKFLOW_RUN_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/workflows/kernel-build.yml/runs?branch=${BRANCH_NAME}"
echo "WORKFLOW_RUN_URL: ${WORKFLOW_RUN_URL}"

# Get the latest workflow run ID
WORKFLOW_RUN_ID=$(curl -s -H "Accept: application/vnd.github.v3+json" -H "Authorization: token ${ACCESS_TOKEN}" ${WORKFLOW_RUN_URL} | jq -r '.workflow_runs[0].id')
echo "WORKFLOW_RUN_ID: ${WORKFLOW_RUN_ID}"

# GitHub API endpoint to get the artifacts for the latest workflow run
ARTIFACTS_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runs/${WORKFLOW_RUN_ID}/artifacts"
echo "ARTIFACTS_URL: ${ARTIFACTS_URL}"

# Save the current IFS value
OLD_IFS=$IFS
# Set IFS to newline
IFS=$'\n'
# Tokenize the input string into an array
artifacts=($(curl -s -H "Accept: application/vnd.github.v3+json" -H "Authorization: token ${ACCESS_TOKEN}" ${ARTIFACTS_URL} | jq -r '.artifacts[] | "\(.id) \(.name)"'))
# Restore the original IFS value
IFS=$OLD_IFS

# Specify the list of artifact names to download
ARTIFACTS_TO_DOWNLOAD=("bcmrpi_build" "bcm2709_build" "bcm2711_build" "bcm2711_arm64_build")

# Loop through each artifact
for artifact in "${artifacts[@]}"; do
  # Extract artifact ID and name
  ARTIFACT_ID=$(echo $artifact | cut -d' ' -f1)
  ARTIFACT_NAME=$(echo $artifact | cut -d' ' -f2-)

  # Check if the artifact is in the list of artifacts to download
  if [[ " ${ARTIFACTS_TO_DOWNLOAD[@]} " =~ " ${ARTIFACT_NAME} " ]]; then
    echo ""
    echo "ARTIFACT_ID: ${ARTIFACT_ID}"
    echo "ARTIFACT_NAME: ${ARTIFACT_NAME}"

    # GitHub API endpoint to download the artifact
    DOWNLOAD_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/artifacts/${ARTIFACT_ID}/zip"

    # Download the artifact
    curl -L -o ${ARTIFACT_NAME}.zip -H "Accept: application/vnd.github.v3+json" -H "Authorization: token ${ACCESS_TOKEN}" ${DOWNLOAD_URL}

	# Extract the artifact
    unzip -o ${ARTIFACT_NAME}.zip
    tar -xvf ${ARTIFACT_NAME}.tar

    echo "Downloaded artifact: ${ARTIFACT_NAME}.zip"
  fi
done

echo "Installing kernel artifacts..."
mv boot/*.dtb ${ROOTFS_DIR}/boot/.
mv boot/*.img ${ROOTFS_DIR}/boot/.
mv boot/overlays/* ${ROOTFS_DIR}/boot/overlays/.
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


