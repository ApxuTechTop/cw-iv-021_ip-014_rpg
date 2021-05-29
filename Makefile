BUILD_DIR=builder
.PHONY: build
build:
	./$(BUILD_DIR)/CoronaBuilder.exe build --lua $(BUILD_DIR)/build.android.lua

.PHONY: tests
tests: tests.lua
	lua tests.lua

.PHONY: clean
clean:
	find bin -name '*.exe' -exec $(RM) '{}' \;
