## 0.5 (once)
##
##
## Glibc
##

## apply patch to make build store files in 'standard' locations:
patch -Np1 -i ../glibc-2.27-fhs-1.patch

## create a compatibility symlink to avoid references to /tools in the final glibc:
ln -sfv /tools/lib/gcc /usr/lib

## Determine the GCC include directory and create a symlink for LSB compliance:
case $(uname -m) in
    i?86)    GCC_INCDIR=/usr/lib/gcc/$(uname -m)-pc-linux-gnu/7.3.0/include
            ln -sfv ld-linux.so.2 /lib/ld-lsb.so.3
    ;;
    x86_64) GCC_INCDIR=/usr/lib/gcc/x86_64-pc-linux-gnu/7.3.0/include
            ln -sfv ../lib/ld-linux-x86-64.so.2 /lib64
            ln -sfv ../lib/ld-linux-x86-64.so.2 /lib64/ld-lsb-x86-64.so.3
    ;;
esac

rm -f /usr/include/limits.h

## Build it:

mkdir -v build
cd       build

## Prepare for compilation:

CC="gcc -isystem $GCC_INCDIR -isystem /usr/include" \
../configure --prefix=/usr                          \
             --disable-werror                       \
             --enable-kernel=3.2                    \
             --enable-stack-protector=strong        \
             libc_cv_slibdir=/lib
unset GCC_INCDIR

##
make

## the test suite for Glibc is considered critical. Do not skip it under any circumstance.
make check

## Glibc will complain about the absence of /etc/ld.so.conf. Prevent this warning with:
touch /etc/ld.so.conf

## Fix the generated Makefile to skip an unneeded sanity check that fails in the LFS partial environment:
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile

##
make install

## Install the configuration file and runtime directory for nscd:
cp -v ../nscd/nscd.conf /etc/nscd.conf
mkdir -pv /var/cache/nscd

## Install the systemd support files for nscd:
install -v -Dm644 ../nscd/nscd.tmpfiles /usr/lib/tmpfiles.d/nscd.conf
install -v -Dm644 ../nscd/nscd.service /lib/systemd/system/nscd.service

## Individual locales can be installed using the localedef program.
## E.g., the first localedef command below combines the /usr/share/i18n/locales/cs_CZ charset-independent locale definition with the /usr/share/i18n/charmaps/UTF-8.gz charmap
## definition and appends the result to the /usr/lib/locale/locale-archive file.
## The following instructions will install the minimum set of locales necessary for the optimal coverage of tests:
mkdir -pv /usr/lib/locale
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030

## In addition, install the locale for your own country, language and character set.
## Alternatively, install all locales listed in the glibc-2.27/localedata/SUPPORTED file
## (it includes every locale listed above and many more) at once with the following time-consuming command:
make localedata/install-locales

## use the localedef command to create and install locales not listed in the glibc-2.27/localedata/SUPPORTED file in the unlikely case they are needed:
localedef


##
## Configuring Glibc
##

## The /etc/nsswitch.conf file needs to be created because the Glibc defaults do not work well in a networked environment:
cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

## Adding time zone data:
tar -xf ../../tzdata2018c.tar.gz

ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward pacificnew systemv; do
    zic -L /dev/null   -d $ZONEINFO       -y "sh yearistype.sh" ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix -y "sh yearistype.sh" ${tz}
    zic -L leapseconds -d $ZONEINFO/right -y "sh yearistype.sh" ${tz}
done

cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
## use New York because POSIX requires the daylight savings time rules to be in accordance with US rules:
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO

## One way to determine the local time zone is to run the following script:
tzselect
## You can make this change permanent for yourself by appending the line
##        TZ='Australia/Sydney'; export TZ
## to the file '.profile' in your home directory; then log out and log in again.
## Here is that TZ value again, this time on standard output so that you
## can use the /usr/bin/tzselect command in shell scripts:
## Australia/Sydney

## create the /etc/localtime file by running:
ln -sfv /usr/share/zoneinfo/<xxx> /etc/localtime

## Configuring the Dynamic Loader:
## Create a new file /etc/ld.so.conf by running the following:
cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF

## The dynamic loader can also search a directory and include the contents of files found there
## To add this capability run the following commands:
cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF

mkdir -pv /etc/ld.so.conf.d
