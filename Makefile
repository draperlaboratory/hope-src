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
kernel-renode:
	$(MAKE) -C tools kernel
kernel-qemu:
	$(MAKE) -C tools kernel CONFIG=hifive SIM=qemu
test-renode:
	$(MAKE) -C tools test
test-qemu:
	$(MAKE) -C tools test CONFIG=hifive SIM=qemu
clean:
	$(MAKE) -C tools $@
clean-kernel-renode:
	$(MAKE) -C tools clean-kernel
clean-kernel-qemu:
	$(MAKE) -C tools clean-kernel CONFIG=hifive SIM=qemu
distclean:
	$(MAKE) -C tools $@

kernel: kernel-renode
clean-kernel: clean-kernel-renode
test: test-renode
