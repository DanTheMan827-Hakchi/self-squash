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
# along with self-squash.  If not, see <https://www.gnu.org/licenses/>.

# Change this to the name of the bundle, alpha-numeric, no spaces.
BUNDLE_NAME := self-squash
FS_FILES := $(shell find "squashfs-root" -type f)

all: $(BUNDLE_NAME).sh

$(BUNDLE_NAME).sh: squash.fs launcher.sh
	$(RM) "$@"
	OFFSET=0 && \
	NEWOFFSET=0 && \
	cp launcher.sh "$@" && \
	while true; do \
	  NEWOFFSET="$$(echo -n "`cat "$@" | wc -c`")" && \
	  sed -e "s/^BUNDLE_NAME=\\\"\\\"$$/BUNDLE_NAME=\\\"$(BUNDLE_NAME)\\\"/" launcher.sh > "$@" && \
	  sed -e "s/^OFFSET=0$$/OFFSET=$$NEWOFFSET/" -i "$@" && \
	  OFFSET="$$(echo -n "$$(cat "$@" | wc -c)")" && \
	  [ $$NEWOFFSET -eq $$OFFSET ] && [ $$OFFSET -gt 0 ] && echo "$$OFFSET == $$NEWOFFSET" && break ; \
	  echo "$$OFFSET != $$NEWOFFSET" ; \
	done
	cat squash.fs >> "$@"
	chmod +x "$@"

squash.fs: squashfs-root/Makefile $(FS_FILES)
	$(RM) "$@"
	cd squashfs-root && \
	mksquashfs * "../$@" -comp xz -Xdict-size 1M -b 1M -all-root

squashfs-root/Makefile: Makefile
	cat "$<" > "$@"

clean:
	$(RM) $(BUNDLE_NAME).sh squash.fs squashfs-root/Makefile

.PHONY: all clean
