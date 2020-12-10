#!/bin/sh

qemu-system-x86_64 --enable-kvm -m 512M --kernel "$(dirname $0)"/vmlinuz* --initrd hvimage.initrd.img -nographic -append "console=ttyS0 ipaddr=$IPADDR gateway=$GATEWAY"
