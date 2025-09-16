# Set cache dir
ifndef XDG_CACHE_DIR
	XDG_CACHE_DIR = $(HOME)/.cache
endif
CACHE_DIR := $(XDG_CACHE_DIR)/crpreview

# Set other variables
BUILD_DIR := ./bin
SRC_DIR := ./src
NAME := crpreview
SRCS := $(shell find $(SRC_DIR) -name '*.cr')

TRASH_CMD := $(shell command -v trash 2> /dev/null)
ifndef TRASH_CMD
	TRASH_CMD := rm -rf
endif

ifeq ($(shell uname), Darwin)
export PKG_CONFIG_PATH := /opt/homebrew/opt/libarchive/lib/pkgconfig
endif

$(BUILD_DIR)/$(NAME): $(SRCS) clean
	mkdir -p $(BUILD_DIR)
	mkdir -p $(CACHE_DIR)
	crystal build $(SRC_DIR)/$(NAME).cr --no-debug --release -o $(BUILD_DIR)/$(NAME)

.PHONY: clean
clean:
	-$(TRASH_CMD) $(CACHE_DIR)

.PHONY: dev
dev: $(SRCS)
	mkdir -p $(BUILD_DIR)
	mkdir -p $(CACHE_DIR)
	crystal build $(SRC_DIR)/$(NAME).cr --progress -o $(BUILD_DIR)/$(NAME)

.PHONY: uninstall
uninstall:
	-$(TRASH_CMD) $(BUILD_DIR)

.PHONY: docs
docs: $(SRCS)
	crystal docs --progress
