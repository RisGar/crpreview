BUILD_DIR := ./bin
SRC_DIR := ./src
NAME := crpreview
SRCS := $(shell find $(SRC_DIR) -name '*.cr')

$(BUILD_DIR)/$(NAME): $(SRCS)
	mkdir -p $(BUILD_DIR)
	crystal build $(SRC_DIR)/$(NAME).cr --no-debug --release -o $(BUILD_DIR)/$(NAME)

.PHONY: dev
dev: $(SRCS)
	mkdir -p $(BUILD_DIR)
	crystal build $(SRC_DIR)/$(NAME).cr --progress -o $(BUILD_DIR)/$(NAME)

.PHONY: uninstall
uninstall:
	rm -rf $(BUILD_DIR)

.PHONY: docs
docs: $(SRCS)
	crystal docs --progress
