## 0.4 (once)
##
##
## Install Linux API Headers
##

## cd /sources
## cd "linux-kernel-version-directory" VERSION!

make mrproper

make INSTALL_HDR_PATH=dest headers_install
find dest/include \( -name .install -o -name ..install.cmd \) -delete
cp -rv dest/include/* /usr/include

##
## Install Man-pages (match the version with the kernel version!)
##

make install
