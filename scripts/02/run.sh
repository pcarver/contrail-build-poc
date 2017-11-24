#!/bin/bash -xe

my_file="$(readlink -e "$0")"
my_dir="$(dirname $my_file)"

export WORKSPACE=${WORKSPACE:-$HOME}
cd $WORKSPACE
export CONTRAIL_BUILD_DIR=$WORKSPACE/build
export CONTRAIL_BUILDROOT_DIR=$WORKSPACE/buildroot

tar -xf step-1.tgz

pushd "$my_dir"
git clone https://github.com/e-kuznetsov/build-contrail-third-party.git
pushd build-contrail-third-party
./build_third_party.sh $WORKSPACE/build
scons --root=$CONTRAIL_BUILDROOT_DIR install

mkdir -p $CONTRAIL_BUILD_DIR/third_party/fysom-1.0.8/fysom
cp third_party/fysom-1.0.8/fysom/__init__.py build/third_party/fysom-1.0.8/fysom/
cp -r third_party/go build/third_party/
cp -r third_party/cni_go_deps build/third_party/

popd
rm -rf build-contrail-third-party

popd
tar -czf step-2.tgz $CONTRAIL_BUILD_DIR $CONTRAIL_BUILDROOT_DIR
rm -rf $CONTRAIL_BUILD_DIR $CONTRAIL_BUILDROOT_DIR
