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
echo "Building OpenBoardView..."
echo "---------------------------------------------------------------"
git clone --recursive https://github.com/OpenBoardView/OpenBoardView ./OpenBoardView
cd ./OpenBoardView && (
	if [ "${DEVEL_RELEASE-}" = 1 ]; then
		echo "Making nightly build of OpenBoardView..."
		echo "---------------------------------------------------------------"
		git rev-parse --short HEAD > ~/version
	else
		echo "Making stable build of OpenBoardView..."
		echo "---------------------------------------------------------------"
		TAG=$(git tag | grep -vi 'rc\|alpha\|^R' | sort -nr | head -1)
		git checkout "$TAG"
		echo "$TAG" > ~/version
	fi
	cmake -DCMAKE_BUILD_TYPE=Release ./
	make -j"$(nproc)"
	ls -lA ./
	ls -lA ./src/openboardview
)

mkdir -p ./AppDir/bin
mv -v ./OpenBoardView/src/openboardview/openboardview ./AppDir/bin
