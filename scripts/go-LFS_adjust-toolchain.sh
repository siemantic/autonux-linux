## 0.6 (once)
##
##
## Adjusting the Toolchain
##

cd
mv -v /tools/bin/{ld,ld-old}
mv -v /tools/$(uname -m)-pc-linux-gnu/bin/{ld,ld-old}
mv -v /tools/bin/{ld-new,ld}
ln -sv /tools/bin/ld /tools/$(uname -m)-pc-linux-gnu/bin/ld

##
## CAREFUL! - /tools/x86_64-autonux-linux-gnu/bin - contained the ONLY ld (and ld.bfd) linked to the correct location:
##
## readelf -l ld
## [Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]
##

##
## Amend the GCC specs file so that it points to the new dynamic linker.
## Simply deleting all instances of “/tools” should leave us with the correct path to the dynamic linker:
gcc -dumpspecs | sed -e 's@/tools@@g'                   \
    -e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
    -e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' >      \
    `dirname $(gcc --print-libgcc-file-name)`/specs
	
## It is imperative at this point to ensure that the basic functions (compiling and linking) of the adjusted toolchain are working as expected:
echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'

## There should be no errors, and the output of the last command will be:
[Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]

## Continue verification:
grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
## output
/usr/lib/../lib/crt1.o succeeded
/usr/lib/../lib/crti.o succeeded
/usr/lib/../lib/crtn.o succeeded

grep -B1 '^ /usr/include' dummy.log
## output
include <...> search starts here:
/usr/include

## !!SEARCH!! results of: grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
## need to look like this:
SEARCH_DIR("/usr/lib")
SEARCH_DIR("/lib")
## NOT like this:
cat dummy.log | grep SEARCH
SEARCH_DIR("=/tools/x86_64-autonux-linux-gnu/lib64");
SEARCH_DIR("/tools/lib");
SEARCH_DIR("=/tools/x86_64-autonux-linux-gnu/lib");
##
## edit/check file: /tools/lib/gcc/x86_64-pc-linux-gnu/7.3.0/specs - make sure it doesn't contain any 'tools' and DOES include the desired /usr/lib && /lib
##

grep "/lib.*/libc.so.6 " dummy.log
## output
attempt to open /lib/libc.so.6 succeeded

grep found dummy.log
## output
found ld-linux-x86-64.so.2 at /lib/ld-linux-x86-64.so.2

rm -v dummy.c a.out dummy.log
##end##
