#!/bin/sh

PRGNAM=re-alpine
VERSION=${VERSION:-2.03}

CWD=${CWD:-"$(  pwd )"}
TMP=${TMP:-/tmp/rpz}

SOURCE="${CWD}/$PRGNAM-$VERSION.tar.bz2"
SRCURL="http://downloads.sourceforge.net/project/$PRGNAM/$PRGNAM-$VERSION.tar.bz2"

IMAPLIBDIR=${IMAPLIBDIR:-/tmp/imap-c-client}
ARCH=${ARCH:-"$( uname -m)"}

if [ "$ARCH" = "i486" ]; then
  SLKCFLAGS="-O2 -march=i486 -mtune=i686"
  LIBDIRSUFFIX=""
elif [ "$ARCH" = "x86_64" ]; then
  SLKCFLAGS="-O2 -fPIC"
  LIBDIRSUFFIX="64"
else
  SLKCFLAGS="-O2"
  LIBDIRSUFFIX=""
fi

set -e
trap 'echo "$0 FAILED at line $LINENO!" | tee $TMP/${PRGNAM}-error.log' ERR
set -u

mkdir -p $TMP
cd $TMP
rm -rf ${PRGNAM}-${VERSION}

dnl() {
    SOURCE=$1
    SRCURL=$2
    if [ ! -e $SOURCE ]; then
       if ! [ "x${SRCURL}" == "x" ]; then
         echo "Downloading '$(basename ${SOURCE})'."
         wget --no-check-certificate -nv -T 30 -O "${SOURCE}" "${SRCURL}" || true
         if [ $? -ne 0 -o ! -s "${SOURCE}" ]; then
            echo "Downloading '$(basename ${SOURCE})' failed... aborting the build."
            mv -f "${SOURCE}" "${SOURCE}.FAIL"
            exit 1
         fi
         else
             echo "File '${SOURCE}' not available... aborting the build."
             exit 1
         fi
    fi
}

dnl "${SOURCE}" "${SRCURL}"

echo "Preparing source"

tar xvf $SOURCE

cd $PRGNAM-$VERSION

chown -R root:root .
find . \
 \( -perm 777 -o -perm 775 -o -perm 711 -o -perm 555 -o -perm 511 \) \
 -exec chmod 755 {} \; -o \
 \( -perm 666 -o -perm 664 -o -perm 600 -o -perm 444 -o -perm 440 -o -perm 400 \) \
 -exec chmod 644 {} \;

echo "Building"

# Configure:
LDFLAGS="-L/usr/lib${LIBDIRSUFFIX}" \
CFLAGS="$SLKCFLAGS" \
./configure \
  --with-ssl-dir=/usr \
  --with-ssl-certs-dir=/etc/ssl/certs \
  --with-c-client-target=slx \
  --disable-debug \
  --with-debug-level=0 \
  --without-tcl \
  --without-ldap \
  --build=$ARCH-slackware-linux

echo y | make EXTRACFLAGS="-fPIC" SSLTYPE=unix || exit 1

( cd imap/c-client
    strip -g c-client.a
    mkdir -p $IMAPLIBDIR/lib${LIBDIRSUFFIX}
    cp c-client.a $IMAPLIBDIR/lib${LIBDIRSUFFIX}
    mkdir -p $IMAPLIBDIR/include
    cp *.h $IMAPLIBDIR/include
)


exit 0
