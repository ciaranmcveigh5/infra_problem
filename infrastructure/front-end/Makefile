BUILD_DIR=build
APPS=front-end
LIBS=common-utils
STATIC_BASE=./public
STATIC_PATHS=css
STATIC_ARCHIVE=$(BUILD_DIR)/static.tgz
INSTALL_TARGETS=$(addsuffix .install, $(LIBS))
APP_JARS=$(addprefix $(BUILD_DIR)/, $(addsuffix .jar, $(APPS)))

all: $(BUILD_DIR) $(APP_JARS) $(STATIC_ARCHIVE)

libs: $(INSTALL_TARGETS)

# %.libs:
# 	cd common-utils && lein install

static: $(STATIC_ARCHIVE)

%.install:
	cd common-utils && lein install

%.test:
	lein midje

clean:
	rm -rf $(BUILD_DIR) $(addsuffix /target, newsfeed)

$(APP_JARS): | $(BUILD_DIR)
	lein uberjar && cp target/uberjar/*-standalone.jar $@

$(STATIC_ARCHIVE): | $(BUILD_DIR)
	tar -c -C $(STATIC_BASE) -z -f $(STATIC_ARCHIVE) $(STATIC_PATHS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)