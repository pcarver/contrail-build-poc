#!/bin/bash -xe

my_file="$(readlink -e "$0")"
my_dir="$(dirname $my_file)"

export WORKSPACE=${WORKSPACE:-$HOME}
cd $WORKSPACE
export CONTRAIL_BUILD_DIR=$WORKSPACE/build
export CONTRAIL_BUILDROOT_DIR=$WORKSPACE/buildroot

tar -xf step-2.tgz

pushd $my_dir
git clone https://github.com/juniper/contrail-build tools/build
git clone https://github.com/juniper/contrail-generateDS tools/generateds
git clone https://github.com/juniper/contrail-common src/contrail-common
# TODO: remove dependencies to controller
git clone https://github.com/juniper/contrail-controller controller-template

ln -s $CONTRAIL_BUILD_DIR build
ln -s $CONTRAIL_BUILDROOT_DIR buildroot
mkdir -p third_party
ln -s $CONTRAIL_BUILD_DIR/third_party/fysom-1.0.8 third_party/fysom-1.0.8

# tests don't work - remove SCons
# TODO: make different targets for test and install
rm -f src/contrail-common/base/test/SConscript

mkdir -p controller/src
pushd controller/src
ln -s ../../src/contrail-common/base base
ln -s ../../src/contrail-common/io io
ln -s ../../controller-template/src/http http
ln -s ../../controller-template/src/net net
ln -s ../../controller-template/src/bgp bgp
ln -s ../../controller-template/src/route route
ln -s ../../controller-template/src/db db
ln -s ../../controller-template/src/sandesh sandesh
popd
cp "$my_dir/SConscript.controller-src" controller/src/SConscript

# TODO: remove these links
mkdir -p build/include/base
pushd build/include/base
ln -s ../../../src/src/contrail-common/base/*.h .
popd
mkdir -p build/include/io
pushd build/include/io
ln -s ../../../src/src/contrail-common/io/*.h .
popd
mkdir -p build/debug/sandesh/common/dist

scons --root=$CONTRAIL_BUILDROOT_DIR install
scons --root=$CONTRAIL_BUILDROOT_DIR install sandesh:test
popd

tar -czf step-3.tgz $CONTRAIL_BUILD_DIR $CONTRAIL_BUILDROOT_DIR
rm -rf $CONTRAIL_BUILD_DIR $CONTRAIL_BUILDROOT_DIR
