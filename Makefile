.PHONY: all
.PHONY: documentation
.PHONY: kernel
.PHONY: test
.PHONY: clean
.PHONY: clean-kernel
.PHONY: kernel-renode
.PHONY: test-renode
.PHONY: clean-kernel-renode
.PHONY: kernel-qemu
.PHONY: test-qemu
.PHONY: clean-kernel-qemu
.PHONY: distclean

all:
	$(MAKE) -C tools $@
documentation:
	$(MAKE) -C tools $@
test-renode:
	$(MAKE) -C tools $@
test-qemu:
	$(MAKE) -C tools $@
clean:
	$(MAKE) -C tools $@
clean-test:
	$(MAKE) -C tools $@
distclean:
	$(MAKE) -C tools $@

test: test-qemu
