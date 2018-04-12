## 0.2 (repeatable)
##
##
## LFS enter the chroot :: based on /opt as $LFS
##

chroot "$LFS" /tools/bin/env -i \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
    /tools/bin/bash --login +h

##
## P.S:  "x86_64-autonux-linux-gnu"
##

##
## IF reboot(ed) / re-entering the chroot env then:
##

## Mount and Populate /dev && Virtual Kernel File Systems
mount -v --bind /dev /opt/dev
mount -vt devpts devpts /opt/dev/pts -o gid=5,mode=620
mount -vt proc proc /opt/proc
mount -vt sysfs sysfs /opt/sys
mount -vt tmpfs tmpfs /opt/run

if [ -h /opt/dev/shm ]; then
  mkdir -pv /opt/$(readlink /opt/dev/shm)
fi
