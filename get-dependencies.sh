#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    cmake    	 \
	python-jinja \
    sdl2

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano libdecor-mini

echo "Building OpenBoardView..."
echo "---------------------------------------------------------------"
git clone --recursive --depth 1 https://github.com/OpenBoardView/OpenBoardView ./OpenBoardView

mkdir -p ./AppDir/bin
cd ./OpenBoardView
if [ "${DEVEL_RELEASE-}" = 1 ]; then
	echo "Making nightly build of OpenBoardView..."
	echo "---------------------------------------------------------------"
	git rev-parse --short HEAD > ~/version
else
	echo "Making stable build of OpenBoardView..."
	echo "---------------------------------------------------------------"
	TAG=$(git tag | grep -vi 'rc\|alpha\|^R' | sort -nr | head -1)
	if [ -z "$TAG" ]; then
		TAG=$(git rev-parse --short HEAD)
	else
		git checkout "$TAG"
	fi
	echo "$TAG" > ~/version
fi
cmake -DCMAKE_BUILD_TYPE=Release ./
make -j"$(nproc)"
mv -v ./src/openboardview/openboardview ../AppDir/bin
