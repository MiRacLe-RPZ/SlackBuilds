#!/bin/sh

set -eu

cd usr/share/doc/PKGNAM-VERSION/SlackBuild/ && OUTPUT=/tmp sh ./PKGNAM.SlackBuild && /sbin/upgradepkg --install-new /tmp/PKGNAM-VERSION-ARCH-netinstall.PKGTYPE
