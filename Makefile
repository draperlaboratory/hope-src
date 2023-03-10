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
test-frtos:
	$(MAKE) -C tools $@
test-frtos64:
	$(MAKE) -C tools $@
test-bare:
	$(MAKE) -C tools $@
test-bare64:
	$(MAKE) -C tools $@
clean:
	$(MAKE) -C tools $@
clean-test:
	$(MAKE) -C tools $@
distclean:
	$(MAKE) -C tools $@

test: test-bare test-frtos test-bare64 test-frtos64
