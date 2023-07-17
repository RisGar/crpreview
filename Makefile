BUILD_DIR := ./bin
SRC_DIR := ./src
CACHE_DIR := ~/.cache/crpreview
NAME := crpreview
SRCS := $(shell find $(SRC_DIR) -name '*.cr')

ifeq ($(shell uname), Darwin)
export PKG_CONFIG_PATH := /opt/homebrew/opt/libarchive/lib/pkgconfig
endif

$(BUILD_DIR)/$(NAME): $(SRCS) clean
	mkdir -p $(BUILD_DIR)
	mkdir -p $(CACHE_DIR)
	crystal build $(SRC_DIR)/$(NAME).cr --no-debug --release -o $(BUILD_DIR)/$(NAME)

.PHONY: clean
clean:
	rm -rf $(CACHE_DIR)/*

.PHONY: ci
ci: $(SRCS)
	mkdir -p $(BUILD_DIR)
	crystal build $(SRC_DIR)/$(NAME).cr --no-debug --release -Dci -o $(BUILD_DIR)/$(NAME)

.PHONY: dev
dev: $(SRCS)
	mkdir -p $(BUILD_DIR)
	mkdir -p $(CACHE_DIR)
	crystal build $(SRC_DIR)/$(NAME).cr --progress -o $(BUILD_DIR)/$(NAME)

.PHONY: uninstall
uninstall:
	rm -rf $(BUILD_DIR)

.PHONY: docs
docs: $(SRCS)
	crystal docs --progress
