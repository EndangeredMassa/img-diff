default: build

COFFEE=node_modules/.bin/coffee --js

SRCDIR = src
SRC = $(shell find $(SRCDIR) -type f -name '*.coffee' | sort)
LIBDIR = lib
LIB = $(SRC:$(SRCDIR)/%.coffee=$(LIBDIR)/%.js)

$(LIBDIR)/%.js: $(SRCDIR)/%.coffee
	@mkdir -p "$(@D)"
	$(COFFEE) <"$<" >"$@"

setup:
	npm install

clean:
	rm -rf lib

build: $(LIB)
	@./node_modules/.bin/npub prep lib

prepublish:
	./node_modules/.bin/npub prep

.PHONY: test
test: build
	@./node_modules/.bin/mocha --compilers coffee:coffee-script-redux/register --recursive test

