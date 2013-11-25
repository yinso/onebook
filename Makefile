VPATH=src
BUILDDIR=lib
TESTDIR=test
CLIENT_DIR=client

BEANDIR=.
JSONDIR=.

COFFEE_SOURCES= $(wildcard $(VPATH)/*.coffee)
COFFEE_OBJECTS=$(patsubst $(VPATH)/%.coffee, $(BUILDDIR)/%.js, $(COFFEE_SOURCES))
CLIENT_COFFEE_SOURCES=$(wildcard $(CLIENT_DIR)/*.coffee)

TEST_COFFEE_SOURCES= $(wildcard $(TESTDIR)/*.coffee)
TEST_COFFEE_OBJECTS= $(patsubst $(TESTDIR)/%.coffee, $(TESTDIR)/%.js, $(TEST_COFFEE_SOURCES))

BEAN_FILES=$(wildcard $(BEANDIR)/*.bean)
JSON_FILES=$(patsubst $(BEANDIR)/%.bean, $(JSONDIR)/%.json, $(BEAN_FILES))

GRAMMAR_DIR=lib

GRAMMAR_FILES=$(wildcard $(GRAMMAR_DIR)/*.pegjs)

all: build

.PHONY: build
build: node_modules objects

.PHONY: objects
objects: $(JSON_FILES) $(COFFEE_OBJECTS) public/js/main.js

package.json: package.bean
	./node_modules/.bin/bean --source package.bean 

public/js/main.js: $(CLIENT_COFFEE_SOURCES) package.json
	amdee --source client/ --target public/js/main.js --recursive

.PHONY: test
test: build
	./bin/testlet

.PHONY: clean
clean:
	rm -f $(COFFEE_OBJECTS)

.PHONE: pristine
pristine: clean
	rm -rf node_modules

node_modules:
	npm install -d

$(BUILDDIR)/%.js: $(VPATH)/%.coffee
	coffee -o $(BUILDDIR) -c $<

$(TESTDIR)/%.js: $(TESTDIR)/%.coffee
	coffee -o $(TESTDIR) -c $<

.PHONY: watch
watch:
	coffee --watch -o $(BUILDDIR) -c $(VPATH)

.PHONY: start
start:	all
	./bin/onebook
