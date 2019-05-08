.PHONY: all
.PHONY: documentation
.PHONY: test
.PHONY: clean
.PHONY: test-frtos
.PHONY: test-bare
.PHONY: distclean

all:
	$(MAKE) -C tools $@
documentation:
	$(MAKE) -C tools $@
test-frtos:
	$(MAKE) -C tools $@
test-bare:
	$(MAKE) -C tools $@
clean:
	$(MAKE) -C tools $@
clean-test:
	$(MAKE) -C tools $@
distclean:
	$(MAKE) -C tools $@

test: test-bare
