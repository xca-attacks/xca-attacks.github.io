PWD=$$(pwd)
SCRIPT_DIR=$(shell cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJ_ROOT=.
TOOLS_DIR=$(PROJ_ROOT)/tools

# Automatically find all .typ files and define their .svg targets
TYPST_SRCS := $(shell find hugo/content -name "*.typ" ! -name "*diagram.typ")
TYPST_SVGS := $(TYPST_SRCS:.typ=.svg)

all: dev

.PHONY:
init:
	cd "$(PROJ_ROOT)/hugo" && npm install

.PHONY:
dev: $(TYPST_SVGS)
	cd "$(PROJ_ROOT)/hugo" && npm run dev

$(TYPST_SVGS): %.svg : %.typ
	typst compile $< --format svg

.PHONY:
build: $(TYPST_SVGS)
	cd "$(PROJ_ROOT)/hugo" && npm run build

.PHONY:
clean:
	git clean -fdx
	find hugo/content -name "*.svg" -exec rm {} +
