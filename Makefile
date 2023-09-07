.PHONY: all
.PHONY: documentation
.PHONY: test
.PHONY: clean
.PHONY: test-frtos test-frtos64
.PHONY: test-bare test-bare64
.PHONY: distclean

all:
	$(MAKE) -Orecurse -C tools $@
documentation:
	$(MAKE) -C tools $@
clean:
	$(MAKE) -C tools $@
clean-test:
	$(MAKE) -C tools $@
distclean:
	$(MAKE) -C tools $@