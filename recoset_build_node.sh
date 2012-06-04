#!/bin/bash

# Create dirs if they're not yet there
mkdir -p ~/local/lib
mkdir -p ~/local/include
mkdir -p ~/local/bin

#############################################################################
# First, build v8

######## RELEASE
mkdir -p build/v8-release
rm -f build/v8-release/libv8-*.so
scons -j8 -C build/v8-release -Y ../../deps/v8 mode=release library=shared soname=on snapshot=on visibility=default arch=x64

# Install to the library directory
NODELIB=`ls build/v8-release/libv8-*.so`
NODENAME=`basename $NODELIB`
echo node library is $NODELIB
echo node library name is $NODENAME
cp -a $NODELIB ~/local/lib/

# Link to libnode-v8.so
rm -f ~/local/lib/libnode-v8.so
ln -sf $NODENAME ~/local/lib/libnode-v8.so

######## DEBUG
mkdir -p build/v8-debug
rm -f build/v8-debug/libv8_g*.so
scons -j8 -C build/v8-debug -Y ../../deps/v8 mode=debug library=shared soname=on snapshot=on visibility=default arch=x64

# Install to the library directory
NODELIBG=`ls build/v8-debug/libv8_g-*.so`
NODENAMEG=`basename $NODELIBG`
echo node debug library is $NODELIBG
echo node debug library name is $NODENAMEG
cp -a $NODELIBG ~/local/lib/

# Link to libnode-v8.so
rm -f ~/local/lib/libnode-v8_g.so
ln -sf $NODENAMEG ~/local/lib/libnode-v8_g.so


######## COMMON

# Install include files
rm -rf ~/local/include/v8
cp -a deps/v8/include/ ~/local/include/v8




#############################################################################
# now build and install node

rm -rf ~/local/include/node
rm -f ~/local/bin/node*
rm -rf ./out ./node ./node_g


JOBS=8 ./configure --shared-v8 --shared-v8-libname=node-v8 --shared-v8-includes=$HOME/local/include/v8 --gdb --shared-v8-libpath=$HOME/local/lib --debug --prefix=$HOME/local
JOBS=8 make -k --jobs=8 JOBS=8 || JOBS=8 make -k --jobs=8 JOBS=8 || make
echo
echo "installing"
make install

cp -a deps/v8/include/* ~/local/include/node

