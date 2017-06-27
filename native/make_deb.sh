#!/bin/bash

set -e


if [ -z "$BROWSER_DEB_VERSION" ]; then
    VERSION=0.10.0
else
    VERSION=$BROWSER_DEB_VERSION
fi

if [ -z "$BROWSER_GIT_CHECKOUT" ]; then
    CHECKOUT=v0.10.0
else
    CHECKOUT=$BROWSER_GIT_CHECKOUT
fi

OUTPUT=$PWD

BUILD_PATH=deb_dist
DEB_PATH=$BUILD_PATH/blockstack-browser-$VERSION

LIB_PATH=/usr/local/lib/blockstack-browser

rm -rf /tmp/blockstack-browser

git clone https://github.com/blockstack/blockstack-browser.git
cd blockstack-browser
git checkout $CHECKOUT

npm install

./node_modules/.bin/gulp prod


mkdir deb_dist;

mkdir -p $DEB_PATH/DEBIAN
mkdir -p $DEB_PATH$LIB_PATH

echo "Package: blockstack-browser" > $DEB_PATH/DEBIAN/control
echo "Architecture: all" >> $DEB_PATH/DEBIAN/control
echo "Maintainer: Aaron Blankstein <aaron@blockstack.com>" >> $DEB_PATH/DEBIAN/control
echo "Depends: nodejs (>= 7.10.0)" >> $DEB_PATH/DEBIAN/control
echo "Priority: optional" >> $DEB_PATH/DEBIAN/control
echo "Version: $VERSION" >> $DEB_PATH/DEBIAN/control
echo "Description: Browser for the new decentralized internet." >> $DEB_PATH/DEBIAN/control

echo "#!/bin/bash" > $DEB_PATH/DEBIAN/postinst
echo "ln -s $LIB_PATH/corsproxy/node_modules/.bin/corsproxy /usr/local/bin/blockstack-cors-proxy" >> $DEB_PATH/DEBIAN/postinst
echo "ln -s $LIB_PATH/blockstack-browser /usr/local/bin/blockstack-browser" >> $DEB_PATH/DEBIAN/postinst


echo "#!/bin/bash" > $DEB_PATH/DEBIAN/postrm
echo "rm -f /usr/local/bin/blockstack-cors-proxy" >> $DEB_PATH/DEBIAN/postrm
echo "rm -f /usr/local/bin/blockstack-browser" >> $DEB_PATH/DEBIAN/postrm

chmod 0555 $DEB_PATH/DEBIAN/postrm
chmod 0555 $DEB_PATH/DEBIAN/postinst

echo "Copying gulped build"
cp -r ./build $DEB_PATH$LIB_PATH
mv $DEB_PATH$LIB_PATH/build $DEB_PATH$LIB_PATH/browser

cp native/blockstackProxy.js $DEB_PATH$LIB_PATH

echo "#!/bin/bash" > $DEB_PATH$LIB_PATH/blockstack-browser
echo "nodejs $LIB_PATH/blockstackProxy.js 8888 $LIB_PATH/browser" >> $DEB_PATH$LIB_PATH/blockstack-browser

chmod 0555 $DEB_PATH$LIB_PATH/blockstack-browser

echo "Install the CORS Proxy"
mkdir -p $DEB_PATH/usr/local/lib/blockstack-browser/corsproxy/node_modules
npm install corsproxy --prefix $DEB_PATH/usr/local/lib/blockstack-browser/corsproxy

echo "Creating dpkg"
fakeroot dpkg-deb --build $DEB_PATH

cp deb_dist/*.deb $OUTPUT
