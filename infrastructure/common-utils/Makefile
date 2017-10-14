LIBS=common-utils
INSTALL_TARGETS=$(addsuffix .install, $(LIBS))

libs: $(INSTALL_TARGETS)

%.install:
	lein install
