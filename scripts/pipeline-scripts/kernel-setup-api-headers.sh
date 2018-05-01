## Jenkins pipeline step "Kernel Setup"
## TODO: make the kernel filename a var.

#un-tar the kernel and
#install the headers
wget https://s3-ap-southeast-2.amazonaws.com/autonux-linux/linux-4.14.22.tar.xz
tar xf linux-4.14.22.tar.xz
cd linux-4.14.22
make mrproper
make INSTALL_HDR_PATH=dest headers_install
find dest/include \( -name .install -o -name ..install.cmd \) -delete
cp -rv dest/include/* /usr/include
#end of step