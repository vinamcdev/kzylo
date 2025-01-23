#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "Requires root/sudo."
  exit 1
fi

usage() {
  echo "Usage: $0 -o <image_out> -s <size> -d <source_directory>"
  echo "  -o <image_out>: Where the disk image will be stored, including the filename as the disk image."
  echo "  -s <size>: Size of the disk image in MB (e.g., 512, 1024) Don't contain units or else your disk creation will continue until you interrupt it manually."
  echo "  -d <source_directory>: Directory containing files to copy onto the disk image."
  exit 1
}

while getopts "o:s:d:" opt; do 
  case $opt in 
    o) IMAGE_OUT="$OPTARG" ;;
    s) IMAGE_SIZE="$OPTARG" ;;
    d) SOURCE_DIR="$OPTARG" ;;
    *) usage ;;
  esac
done

if [[ -z "$IMAGE_OUT" || -z "$IMAGE_SIZE" || -z "$SOURCE_DIR" ]]; then
  usage
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Source directory does not exist: $SOURCE_DIR"
  exit 1
fi

echo "Creating a ${IMAGE_SIZE}MB disk image at $IMAGE_OUT..."
dd if=/dev/zero of="$IMAGE_OUT" bs=1M count="$IMAGE_SIZE" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
  echo "Failed to create disk image."
  exit 1
fi

LOOP_DEVICE=$(losetup --find --show "$IMAGE_OUT")
if [[ -z "$LOOP_DEVICE" ]]; then
  echo "Failed to create a loopback device."
  exit 1
fi

echo "Created loopback device: $LOOP_DEVICE"

echo "Partitioning and formatting the disk image."
parted -s "$LOOP_DEVICE" mklabel gpt mkpart primary fat32 1MiB 100% >/dev/null
PARTITION="${LOOP_DEVICE}p1"
echo "Allowing system to register partition."
sleep 1
echo "Formatting with vfat (fat32)..."
mkfs.vfat -F 32 "$PARTITION" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
  echo "Failed to format the disk image."
  losetup -d "$LOOP_DEVICE"
  exit 1
fi

MOUNT_DIR=$(mktemp -d)
mount "$PARTITION" "$MOUNT_DIR"

echo "Copying files from $SOURCE_DIR to the disk image..."
cp -r "$SOURCE_DIR"/* "$MOUNT_DIR"

echo "Cleaning up..."
umount "$MOUNT_DIR"
losetup -d "$LOOP_DEVICE"
rm -rf "$MOUNT_DIR"

echo "Disk image $IMAGE_OUT created successfully."