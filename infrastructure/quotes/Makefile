BUILD_DIR=build
APPS=quotes
LIBS=common-utils
STATIC_BASE=front-end/public
TARGET=./target
STATIC_PATHS=css
STATIC_ARCHIVE=$(BUILD_DIR)/static.tgz
INSTALL_TARGETS=$(addsuffix .install, $(LIBS))
APP_JARS=$(addprefix $(BUILD_DIR)/, $(addsuffix .jar, $(APPS)))

all: $(BUILD_DIR) $(APP_JARS) $(STATIC_ARCHIVE)

static: $(STATIC_ARCHIVE)

.PHONY: all test clean

test:
	lein midje

clean:
	rm -rf $(BUILD_DIR) $(TARGET)

$(APP_JARS): | $(BUILD_DIR)
	lein uberjar && cp target/uberjar/*-standalone.jar $@

$(STATIC_ARCHIVE): | $(BUILD_DIR)
	# tar -c -C $(STATIC_BASE) -z -f $(STATIC_ARCHIVE) $(STATIC_PATHS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)
