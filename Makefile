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
