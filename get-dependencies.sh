#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    cmake    \
    libdecor \
    python   \
    sdl2

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here

# if you also have to make nightly releases check for DEVEL_RELEASE = 1
#
# if [ "${DEVEL_RELEASE-}" = 1 ]; then
# 	nightly build steps
# else
# 	regular build steps
# fi
echo "Making nightly build of OpenBoardView..."
echo "---------------------------------------------------------------"
REPO="https://github.com/OpenBoardView/OpenBoardView"
VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
git clone --recursive --depth 1 "$REPO" ./OpenBoardView
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin
cd ./OpenBoardView
cmake -DCMAKE_BUILD_TYPE=Release .
make -j$(nproc)
mv -v bin/openboardview ../AppDir/bin
