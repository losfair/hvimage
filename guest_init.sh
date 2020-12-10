#!/busybox sh

/busybox mkdir /proc /sys
/busybox mount -t proc proc /proc
/busybox mount -t sysfs sysfs /sys

IPADDR=`cat /proc/cmdline | awk -F 'ipaddr=' '{print $2}' | cut -d ' ' -f 1`
GATEWAY=`cat /proc/cmdline | awk -F 'gateway=' '{print $2}' | cut -d ' ' -f 1`
echo "IP address: $IPADDR"
echo "Gateway: $GATEWAY"

/busybox modprobe virtio_net

/busybox ip link set eth0 up
/busybox ip addr add "$IPADDR" dev eth0
/busybox ip route add default via "$GATEWAY" dev eth0

/busybox lsmod

/busybox umount /proc
/busybox umount /sys
/busybox mount -t proc proc /rootfs/proc
/busybox mount -t sysfs sysfs /rootfs/sys
/busybox mount -t devtmpfs devtmpfs /rootfs/dev

/busybox mkdir /rootfs/lib
/busybox mv /lib/modules /rootfs/lib/

exec /busybox chroot /rootfs /init
