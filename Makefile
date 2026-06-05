PWD=$$(pwd)
SCRIPT_DIR=$(shell cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJ_ROOT=.
TOOLS_DIR=$(PROJ_ROOT)/tools

# Automatically find all .typ files
TYPST_SRCS := $(shell find hugo/content -name "*.typ" ! -name "*diagram.typ")
# Track compilation using stamp files instead of exact SVG names
TYPST_STAMPS := $(TYPST_SRCS:.typ=.stamp)

all: dev

.PHONY:
init:
	cd "$(PROJ_ROOT)/hugo" && npm install

.PHONY:
dev: $(TYPST_STAMPS)
	cd "$(PROJ_ROOT)/hugo" && npm run dev

# Compile the .typ file into multiple SVGs using the {p} template, then touch the stamp file
$(TYPST_STAMPS): %.stamp : %.typ
	typst compile $< "$*-{p}.svg"
	@touch $@

.PHONY:
build: $(TYPST_STAMPS)
	cd "$(PROJ_ROOT)/hugo" && npm run build

.PHONY:
clean:
	git clean -fdx
	find hugo/content -name "*.svg" -exec rm -f {} +
	find hugo/content -name "*.stamp" -exec rm -f {} +