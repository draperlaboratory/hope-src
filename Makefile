.PHONY: all
.PHONY: documentation
.PHONY: kernel
.PHONY: test
.PHONY: clean
.PHONY: clean-kernel
.PHONY: distclean

all:
	$(MAKE) -C tools $@
documentation:
	$(MAKE) -C tools $@
kernel:
	$(MAKE) -C tools $@
test:
	$(MAKE) -C tools $@
clean:
	$(MAKE) -C tools $@
clean-kernel:
	$(MAKE) -C tools $@
distclean:
	$(MAKE) -C tools $@
