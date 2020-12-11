#!/bin/sh

. ./hvimage_config || exit 1

echo "hvimage: Building ramdisk."

rm -rf hvimage.initrd
mkdir hvimage.initrd || exit 1
cp -r "$ROOTFS_PATH" ./hvimage.initrd/rootfs || exit 1
mkdir ./hvimage.initrd/lib || exit 1
cp "$(dirname $0)/busybox" ./hvimage.initrd/busybox || exit 1
cp "$(dirname $0)/guest_init.sh" ./hvimage.initrd/init || exit 1
cp -r "$(dirname $0)/modules" ./hvimage.initrd/lib/ || exit 1
chmod +x ./hvimage.initrd/busybox ./hvimage.initrd/init || exit 1

cd hvimage.initrd || exit 1
find . 2>/dev/null | cpio -o -H newc -R root:root | gzip -6 > "../hvimage.initrd.img" || exit 1
cd .. || exit 1

cp "$(dirname $0)"/vmlinuz* ./hvimage.vmlinuz || exit 1

if [ "$BUILD_DISK_IMAGE" = "1" ]; then
    echo "hvimage: Building image."
    rm -rf hvimage.build hvimage.build.img
    mkdir hvimage.build || exit 1
    
    cp "$(dirname $0)"/vmlinuz* hvimage.build/vmlinuz || exit 1
    cp ./hvimage.initrd.img ./hvimage.build/initrd.img || exit 1
    mkdir -p ./hvimage.build/boot/grub || exit 1
    cat "$(dirname $0)/grub.cfg" | sed "s~__DISK_IMAGE_IPADDR__~$DISK_IMAGE_IPADDR~g" | sed "s~__DISK_IMAGE_GATEWAY__~$DISK_IMAGE_GATEWAY~g" > ./hvimage.build/boot/grub/grub.cfg
    fakeroot mke2fs -d ./hvimage.build hvimage.build.img "$DISK_IMAGE_SIZE" || exit 1
fi

echo "hvimage: Build completed."
