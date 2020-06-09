#!/bin/bash

# Copyright 2020 DanTheMan827
#
# This file is part of self-squash.
#
# self-squash is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# self-squash is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see <https://www.gnu.org/licenses/>.

OFFSET=0
BUNDLE_NAME=""

if [ "$1" == "unpack" ]; then
  head -c $OFFSET "$0" | \
  sed -e "s/^OFFSET=$OFFSET$/OFFSET=0/" -e "s/^BUNDLE_NAME=\\\"$BUNDLE_NAME\\\"$/BUNDLE_NAME=\\\"\\\"/" > launcher.sh && \
  chmod +x launcher.sh && \

  tail "-c+$(($OFFSET + 1))" "$0" > squash.fs && \
  unsquashfs squash.fs && \
  cp squashfs-root/Makefile .

  exit $?
fi

BUNDLE_PWD="$(pwd)"
BUNDLE_BIN="$(readlink -f "$0")"
BUNDLE_DIR="$(dirname "$BUNDLE_BIN")"
BUNDLE_TMP="/tmp/$BUNDLE_NAME.tmp"
BUNDLE_MNT="$BUNDLE_TMP/mount"

mkdir -p "$BUNDLE_MNT"

BUNDLE_LOOP="`losetup -f`"
losetup -r -o $OFFSET "$BUNDLE_LOOP" "$BUNDLE_BIN"
mount -t squashfs -o ro "$BUNDLE_LOOP" "$BUNDLE_MNT"

crash_catcher(){
  source "$BUNDLE_MNT/start.sh"
}

tty >/dev/null || uistop

crash_catcher "$@"

cd /
umount "$BUNDLE_MNT"
losetup -d "$BUNDLE_LOOP"
rm -rf "$BUNDLE_TMP"

sync; echo 3 > /proc/sys/vm/drop_caches

tty >/dev/null || touch "/var/startmcp.flag"

exit 0
