APP_PATH= src

ODIN := $(shell which odin)

.PHONY:run
run:
	$(ODIN) run $(APP_PATH)