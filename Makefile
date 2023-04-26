BUILD_DIR := ./bin
SRC_DIR := ./src
NAME := crpreview
SRCS := $(shell find $(SRC_DIR) -name '*.cr')

$(BUILD_DIR)/crtangle: $(SRCS)
	mkdir -p $(BUILD_DIR)
	crystal build $(SRC_DIR)/$(NAME).cr --no-debug --release --progress -o $(BUILD_DIR)/$(NAME)

.PHONY: uninstall
uninstall:
	rm -rf $(BUILD_DIR)

.PHONY: docs
docs: $(SRCS)
	crystal docs --progress
