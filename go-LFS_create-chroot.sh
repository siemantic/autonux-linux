## 0.1 (repeatable)
##
##
## LFS chroot creation :: based on /opt as $LFS
##

## Essential System Directories
mkdir -pv /opt/{dev,proc,sys,run}

## Create Initial Device Nodes
mknod -m 600 /opt/dev/console c 5 1
mknod -m 666 /opt/dev/null c 1 3

## Mount and Populate /dev
mount -v --bind /dev /opt/dev

## Mount Virtual Kernel File Systems
mount -vt devpts devpts /opt/dev/pts -o gid=5,mode=620
mount -vt proc proc /opt/proc
mount -vt sysfs sysfs /opt/sys
mount -vt tmpfs tmpfs /opt/run

## In some host systems, /dev/shm is a symbolic link to /run/shm.
## The /run tmpfs was mounted above so in this case only a directory needs to be created.
if [ -h /opt/dev/shm ]; then
  mkdir -pv /opt/$(readlink /opt/dev/shm)
fi
