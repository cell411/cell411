ifeq ($(PARSE_FLAVOR),)
export PARSE_FLAVOR=parse
endif

all: executeSql


createSchema:       destroyAndCreate
createConstraints:  createSchema
createShipSchema:   createConstraints
dumpSchema:			  	createShipSchema
convertData:        dumpSchema
executeSql:         convertData



%: %.mjs
	@echo $<:1:running
	set -o pipefail; node $< 2>&1 | tee out.$@.out | tee -a all.out

header:
	@echo all.out:1:output | tee all.out

SHELL:=/bin/bash

ctags:
	ctags *.mjs *.js --language-force=javascript

convertData:       header
createSchema:      header
createShipSchema:  header
destroyAndCreate:  header
executeSql:        header
createConstraints: header
